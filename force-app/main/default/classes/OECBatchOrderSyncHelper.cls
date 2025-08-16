public class OECBatchOrderSyncHelper {


    String apiCalloutName = 'OECManualOrderCreation';
    String apiEnvironment;
    CalloutData__c cd;
    Cache.OrgPartition orgPart = Cache.Org.getPartition('local.StoreIDToken');
    Contact pm;
    Contact coPM;
    public CalloutData__c getCalloutData(){
        return cd;
    }
    public OECBatchOrderSyncHelper(){ 
    
        cd = loadCalloutParams();

    } 
    
    public void processOrders(List<Order> orders){

        String idToken = getAccessToken();
        if(String.isNotBlank(idToken)){
            for(Order ord : orders){
                if(validOrderToProcess(ord)){
                    syncOrder(idToken,ord);
                
                }
            
            }
        }
        else {
            System.debug('ID Token received from API is invalid hence closing');

        }

    }
    /**
    Finds the right Order needs to be synced back to OEC
    */
    public boolean validOrderToProcess(Order ord){
    
        System.debug(
            'ord.RecordType.Name:'+ Schema.SObjectType.Order.getRecordTypeInfosById().get(ord.recordtypeid).getname()+
            '- ord.CreatedBy.Name:'+ord.CreatedBy.Name+
            '- ord.Business_Line__c:'+ord.Business_Line__c+
            '- ord.Status:'+ord.Status+
            '- ord.Sync_to_OEC__c:'+ord.Sync_to_OEC__c+
            '- ord.Account.External_Sync__c'+ord.Account.External_Sync__c
        );
 
        if(Schema.SObjectType.Order.getRecordTypeInfosById().get(ord.recordtypeid).getname() == 'Corporate_StreamLinks_Order' || 
                Schema.SObjectType.Order.getRecordTypeInfosById().get(ord.recordtypeid).getname() == 'Corporate_Knovio_Order')
        {        

            return false;// We will not process Corporate_StreamLinks_Order orders
        }
        else if (ord.CreatedBy.Name == 'API Integration User') 
        {

            return false;// We will not process Order created by API Integration User
        }
        /*
        else if (ord.Business_Line__c != 'OE Connect' && 
                 ord.Business_Line__c != 'OE Conference' &&
                 ord.Business_Line__c != 'Corporate Services' ) 
        {

            return false; // We will not process any business line other than above
        } */
        else if (ord.Status != 'In Progress')
        {

            return false;
        }
        else if (ord.Sync_to_OEC__c == False)
        {

            return false;
        }
        else if(ord.Account.External_Sync__c != true)
        {

            return false;     
        }                
        return true;        
                    
    }
    
    private CalloutData__c loadCalloutParams(){
    
        Integration_Configuration__mdt ic = [SELECT API_Environment__c from Integration_Configuration__mdt];
        apiEnvironment = ic.API_Environment__c;
        
        System.debug('API Environment getting connected is -----> :'+apiEnvironment); 
        CalloutData__c cd;

        if (apiEnvironment == 'QA'){
            OECCallOuts__mdt callouts = [SELECT QAAccountId__c,QAAuthURL__c,QAEndpointURL__c,QAPassword__c,QAUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            cd = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QAEndpointURL__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);
        }
        else if (apiEnvironment == 'Prod'){
            OECCallOuts__mdt callouts = [SELECT ProdAccountId__c,ProdAuthURL__c,ProdEndpointURL__c,ProdPassword__c,ProdUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            cd = new CalloutData__c(AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProdEndpointURL__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);
        }
        else {
            OECCallOuts__mdt callouts = [SELECT DevAccountId__c,DevAuthURL__c,DevEndpointURL__c,DevPassword__c,DevUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            cd = new CalloutData__c(AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.DevEndpointURL__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
        }
        return cd;
        
    }
    
    public String getAccessToken(){
           
       return getIDToken();       
       
    }
    private String getIDToken(){
   
        
        DateTime expiry = (DateTime)orgPart.get('expiry');
        String IDToken = (String)orgPart.get('IDToken');
        //System.debug('In getIDToken method ----------->> System.now():'+ system.now()+' - expiry date time:'+expiry+' - IDToken:'+IDToken); 
        //System.debug('Retrieved IDToken:'+IDToken+'-Expiry:'+expiry); 
        if (String.isNotBlank(IDToken) && (system.now() < expiry )){

            return IDToken;// returns the IDToken from platform cache
        
        }
        else {
            return getFreshToken();// returns the new token after fetchig        
        }
        
    }
    private void storeIdToken(String idTokenString){
        
        orgPart.put('IDToken',idTokenString);
        orgPart.put('expiry',system.now().addSeconds(3600));
    
    }
    private String getFreshToken(){
    

       String idTokenString;
       Http http = new Http();
       HttpRequest req = new HttpRequest();

       req.setEndpoint(cd.AuthenticationURL__c);
       req.setMethod('POST');
       
       Blob headerValue = Blob.valueof(cd.UserName__c+':'+cd.UserPassword__c);
        
       String authorizationValue = 'Basic '+EncodingUtil.base64Encode(headerValue);
       req.setHeader('Authorization',authorizationValue);
       
       System.debug('Req------------>>'+req);
       HttpResponse res = http.send(req);
       Order updateOrd = new Order();

       if (res.getStatusCode() == 200) 
       {
       
           //System.debug('Res------------->> '+res.toString());
           JSONParser jpar = JSON.createParser(res.getBody());
           //System.debug('jpar------------->>'+jpar);
           
           while(jpar.nextToken() != NULL){
               
               if((jpar.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar.getText() == 'idToken'){
                   jpar.nextToken();
                   idTokenString = jpar.getText();
                   //System.debug('idTokenString ------------->>'+idTokenString);
               }
                   
           }
           storeIdToken(idTokenString);
          
           return idTokenString; 
        }  
        else return null;
    
    }
    private void syncOrder(String idTokenString, Order ord){
       findProjectManagers(ord);
       //Map<String,TimeZones__mdt> tz = TimeZones__mdt.getAll(); 
       Http http = new Http();
       HttpRequest req = new HttpRequest();
       req.setEndpoint(cd.EndPointURL__c);
       req.setMethod('POST');
       
       req.setHeader('Content-Type', 'application/json');
       req.setHeader('X-OEX-SF-Account-ID', ord.AccountId);
       req.setHeader('X-OEX-Int-Account-ID', cd.AccountId__c);
       //req.setHeader('X-OEX-Int-Account-ID', ord.AccountId);
       req.setHeader('X-OEX-Int-Authorization',idTokenString);
    
       String ed = ord.End_Date_Time__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
       String sd = ord.Start_Date_Time__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
       
       String timeZoneValue = findTimeZoneValue(ord.Order_TimeZone__c);
       
       
       
       String body = '{'+
                      '"endDateTime":"'+ed+'",'+
                      '"oeNumber":"'+(ord.OrderNumber).replaceFirst( '^0+', '')+'",'+
                      '"name":"'+ord.OEC_Event_Name__c+'",'+                                      
                      '"startDateTime":"'+sd+'",'+
                      '"timeZone":"'+timeZoneValue+'",'+
                      '"type":"'+ord.Event_Type_OE_Defined__c+'",'+
                      '"orderId":"'+ ord.Id+'",';
                      
           if(String.isNotBlank(ord.Region__c) && (ord.Region__c == 'AMER' || ord.Region__c == 'APAC' || ord.Region__c == 'EMEA'))               
                      body = body+ '"region":"'+ord.Region__c+'",';  
                      
           if(String.isNotBlank(ord.Business_Line__c) && (ord.Business_Line__c != 'None')){
                      body = body+ '"businessLine":"'+ord.Business_Line__c+'"';  
           }            
           body = body+ addProjectManagers();   
           body = body+ addRequestorContract(ord);                             
           body = body+'}';
                      
       String eventString ;
       String orderId;
       String eventId;
       String externalEventIdl;
       String errorMsg;
       boolean syncFailed = false;
       Order updateOrd;              
       System.debug('Body------------->> '+Body);
       req.setBody(body);
       HttpResponse res = http.send(req);
        
       System.debug('Res------------->> '+res.toString());
       JSONParser jpar = JSON.createParser(res.getBody());
       
       
       while(jpar.nextToken() != NULL){

           
           if((jpar.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar.getText() == 'eventLink'){
               jpar.nextToken();
               eventString = jpar.getText();
               System.debug('eventString ------------->>'+eventString);
           }
           if((jpar.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar.getText() == 'orderId'){
               jpar.nextToken();
               orderId = jpar.getText();
           }
           if((jpar.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar.getText() == 'eventId'){
               jpar.nextToken();
               eventId = jpar.getText();

           }
           if((jpar.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar.getText() == 'externalEventIdl'){
               jpar.nextToken();
               externalEventIdl = jpar.getText();
           }
           if((jpar.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar.getText() == 'errorMessages'){
               jpar.nextToken();
               jpar.nextToken();
               errorMsg = jpar.getText();
               System.debug('errorMsg---------->>'+errorMsg);
               syncFailed = true;
            
           }

               
       }
       if(String.isNotBlank(eventString) && String.isNotBlank(orderId))// Sync success
       {
            updateSyncedOrder(orderId,eventString,eventId,externalEventIdl,ord);
       }
       else //if (syncFailed)
       {
           updateFailedOrder(ord,errorMsg);
       }   
       
       
        
    }

    public static String findTimeZoneValue(String tzn){
          
       String GMTTimezoneName = 'UTC';
      
       if(String.isNotBlank(tzn)){
           
           Map<String,TimeZones__mdt> dlsTZ ;
           Map<String,StandardTimeZone__mdt> standardTZ ;
        
           TimeZoneConfiguration__mdt tt = [SELECT TimeZoneType__c from TimeZoneConfiguration__mdt];
           String timeZoneType = tt.TimeZoneType__c;

           String timeZoneValue ;  
           //if (timeZoneType == 'DaylightSaving'){  // Irrespective of Time zone we need to send the Timezone value.
               dlsTZ = TimeZones__mdt.getAll();
               for(String timezoneName : dlsTZ.keySet()){
                    System.debug('dlsTZ.get(timezoneName).TimeZone_Name__c ----->>'+dlsTZ.get(timezoneName).TimeZone_Name__c);
                    if(dlsTZ.get(timezoneName).TimeZone_Name__c == tzn)
                        return dlsTZ.get(timezoneName).TimeZone_Value__c;
                                    
               }
           //}    
           
           //else{
               standardTZ = StandardTimeZone__mdt.getAll();
               for(String timezoneName : standardTZ.keySet()){
                    System.debug('standardTZ.get(timezoneName).TimeZone_Name__c ----->>'+standardTZ.get(timezoneName).TimeZone_Name__c);
                    if(standardTZ.get(timezoneName).TimeZone_Name__c == tzn)
                        return standardTZ.get(timezoneName).TimeZone_Value__c;
                                    
               }
           //}
      }
      return GMTTimezoneName;     
    }  
     
    private void updateSyncedOrder (String orderId, String eventString, String eventId, String externalEventId, Order ord){
    
           Decimal retryCount = ord.Sync_Retry_Count__c;     
           
           Order updateOrd =  [Select Id,OE_Central_URL__c,SyncStatus__c,Sync_Retry_Count__c,OECEventId__c,OECExternalEventId__c from Order where Id = :orderId];
           updateOrd.OE_Central_URL__c = eventString;
           updateOrd.SyncStatus__c='Synced';
           updateOrd.Sync_Datetime__c = System.now();
           updateOrd.OECEventId__c = eventId;
           updateOrd.OECExternalEventId__c = externalEventId;
           updateOrd.Sync_Retry_Count__c = retryCount+1;
           updateOrd.Sync_Error_Message__c='';

           update updateOrd;  
           
    }
    
    private void updateFailedOrder (Order ord, String errorMsg){
           

           order updateOrd =  [Select Id,Sync_Retry_Count__c,SyncStatus__c, Sync_Error_Message__c from Order where Id = :ord.Id];
           Decimal retryCount = updateOrd.Sync_Retry_Count__c;
 
           
           if (retryCount == 4)
               updateOrd.SyncStatus__c='Error'; 
               
           updateOrd.Sync_Error_Message__c=errorMsg;           
           updateOrd.Sync_Retry_Count__c = retryCount+1;
           update updateOrd; 

    
    }
    private void findProjectManagers(Order ord){
    
       if (String.isNotblank(ord.Project_Manager__c))  
           pm = [select email,FirstName,LastName from Contact where id = :ord.Project_Manager__c];
       if (String.isNotblank(ord.Project_Manager_2__c))    
           coPM = [select email,FirstName,LastName from Contact where id = :ord.Project_Manager_2__c];
       
       /*
       System.debug('pm.FirstName------------>>'+pm.FirstName);
       System.debug('pm.LastName------------>>'+pm.LastName);
       System.debug('pm.email------------>>'+pm.email);
    
    
       System.debug('coPM.FirstName------------>>'+coPM.FirstName);
       System.debug('coPM.LastName------------>>'+coPM.LastName);
       System.debug('coPM.email------------>>'+coPM.email);
       */ 
    }    
    private String addProjectManagers(){
        boolean pmExist = false;
        boolean copmExist = false;
        String managersBody ='';
        if( pm != null) {
            if (String.isNotblank(pm.email) || String.isNotblank(pm.LastName) || String.isNotblank(pm.FirstName)){
                pmExist = true;
            }  
        } 
        if(coPM != null) {
            if (String.isNotblank(coPM.email) || String.isNotblank(coPM.LastName) || String.isNotblank(coPM.FirstName)){
                copmExist = true;
            }
        }
        if(pmExist || copmExist){
            managersBody = ', "deliveryTeamMembers": [';
            
            if (pmExist){
                managersBody = managersBody + '{ "deliveryTeamMemberRole": "'+'PROJECT_MANAGER" ';
                if(String.isNotblank(pm.email))
                  managersBody = managersBody + ', "email": "'+pm.email+'"';
                if(String.isNotblank(pm.FirstName))
                  managersBody = managersBody + ', "firstName": "'+pm.FirstName+'"';
                if(String.isNotblank(pm.LastName))
                  managersBody = managersBody + ', "lastName": "'+pm.LastName+'"';  
            }
            if (pmExist && copmExist)
                managersBody = managersBody + '},';
            if (copmExist){
                managersBody = managersBody + '{ "deliveryTeamMemberRole": "'+'CO_PROJECT_MANAGER" ';
                if(String.isNotblank(coPM.email))
                  managersBody = managersBody + ', "email": "'+coPM.email+'"';
                if(String.isNotblank(coPM.FirstName))
                  managersBody = managersBody + ', "firstName": "'+coPM.FirstName+'"';
                if(String.isNotblank(coPM.LastName))
                  managersBody = managersBody + ', "lastName": "'+coPM.LastName+'"';  
            }
        }
        if (pmExist || copmExist)
            managersBody = managersBody +'}]';
        System.debug('managersBody------------------>>'+managersBody);
        return managersBody;
    }

    private static String addRequestorContract(Order ord){

        //quester_Contact__r.FirstName,Requester_Contact__r.LastName,Requester_Contact__r.Email
           
        String requestorContract = ', "coordinators": [{';
        if(String.isNotblank(ord.Requester_Contact__r.Email))
            requestorContract = requestorContract + '"username": "'+ord.Requester_Contact__r.Email+'",';
        if(String.isNotblank(ord.Requester_Contact__r.FirstName))    
            requestorContract = requestorContract + ' "firstName": "'+ord.Requester_Contact__r.FirstName+' ",';
        if(String.isNotblank(ord.Requester_Contact__r.LastName))     
            requestorContract = requestorContract + ' "lastName": "'+ord.Requester_Contact__r.LastName+'"';  
        
        requestorContract = requestorContract +'}]';
        System.debug('requestorContract------------------>>'+requestorContract);
        return requestorContract;
        
      
    }
    
}