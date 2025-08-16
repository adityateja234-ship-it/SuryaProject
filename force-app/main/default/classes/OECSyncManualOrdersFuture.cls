global class OECSyncManualOrdersFuture {

    static CalloutData__c calloutData;
    static CalloutData__c cancelledcd;
    static CalloutData__c teamscd;

    @future(callout=true)
    public static void callManualOrderSync( Set<ID> orderIDList){
        List<Order> ords = [SELECT id,OrderNumber, Description,AccountId, Order_Process__c,End_Date_Time__c, EventNotes__c,Order_TimeZone__c,Start_Date_Time__c, Event_Type_OE_Defined__c, OEC_Event_Name__c,Name,TimeZone__c,region__c,Business_Line__c, Project_Manager_2__c,Project_Manager__c,Requester_Contact__r.FirstName,Requester_Contact__r.LastName,Requester_Contact__r.Email from order where status = 'In Progress' and id in:orderIDList for update];
        loadCalloutParams();
        String GMTTimeZone = 'UTC';
        for(Order ord : ords)
        {    
           
           System.debug('Order Details --->'+
                         'ID :'+ord.Id+
                         'OrderNumber :'+(ord.OrderNumber).replaceFirst( '^0+', '')+
                         'AccountId :'+ord.AccountId+
                         'Start_Date_Time__c :'+ord.Start_Date_Time__c+
                         'End_Date_Time__c :'+ord.End_Date_Time__c+
                         'Name :'+ord.Name+
                         'OEC_Event_Name__c :'+ord.OEC_Event_Name__c+
                         'Event_Type_OE_Defined__c :'+ord.Event_Type_OE_Defined__c+
                         'TimeZone__c :'+ord.TimeZone__c  
           );
           
           Http http = new Http();
           HttpRequest req = new HttpRequest();
           
           req.setEndpoint(calloutData.AuthenticationURL__c);
           req.setMethod('POST');
           
           
           Blob headerValue = Blob.valueof(calloutData.UserName__c+':'+calloutData.UserPassword__c);
            
           String authorizationValue = 'Basic '+EncodingUtil.base64Encode(headerValue);
           req.setHeader('Authorization',authorizationValue);
           
           System.debug('Req------------>>'+req);
           HttpResponse res = http.send(req);
           Order updateOrd = new Order();
           // Add condition to verify the status code then process the rest else set status to failed in the Order
           if (res.getStatusCode() == 200) 
           {
           
               System.debug('Res------------->> '+res.toString());
               JSONParser jpar = JSON.createParser(res.getBody());
               
               String idTokenString;
               while(jpar.nextToken() != NULL){
                   //System.debug('---->' + jpar.getText());
                   if((jpar.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar.getText() == 'idToken'){
                       jpar.nextToken();
                       idTokenString = jpar.getText();
                       System.debug('idTokenString ------------->>'+idTokenString);
                   }
                       
               }
               //findProjectManagers(ord);
               HttpRequest req2 = new HttpRequest();
               req2.setEndpoint(calloutData.EndPointURL__c);
               req2.setMethod('POST');
               //req2.setHeader('Accept', 'application/json');
               req2.setHeader('Content-Type', 'application/json');
               req2.setHeader('X-OEX-SF-Account-ID', ord.AccountId);
               req2.setHeader('X-OEX-Int-Account-ID', calloutData.AccountId__c);
               req2.setHeader('X-OEX-Int-Authorization',idTokenString);
            
               String ed = ord.End_Date_Time__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
               String sd = ord.Start_Date_Time__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
               
               String timeZoneValue = findTimeZoneValue(ord.Order_TimeZone__c);
                        
               String body = '{'+
                              '"endDateTime":"'+ed+'",'+
                              '"oeNumber":"'+(ord.OrderNumber).replaceFirst( '^0+', '')+'",'+
                              '"name":"'+ord.OEC_Event_Name__c+'",';
                              
                        
               if(String.isNotBlank(ord.Region__c) && (ord.Region__c == 'AMER' || ord.Region__c == 'APAC' || ord.Region__c == 'EMEA'))               
                      body = body+ '"region":"'+ord.Region__c+'",';    
                      
               if(String.isNotBlank(ord.Business_Line__c) && (ord.Business_Line__c != 'None'))
                      body = body+ '"businessLine":"'+ord.Business_Line__c+'",';          
               //if(String.isNotBlank(ord.EventNotes__c))               
                      //body = body+ '"note":"'+ord.EventNotes__c+'",';       
               //if(String.isNotBlank(ord.Description) )              
               //       body = body+ '"publicDescription":"'+ord.Description+'",';  
                                               
               body= body+    '"startDateTime":"'+sd+'",'+
                              '"timeZone":"'+timeZoneValue+'",'+
                              '"type":"'+ord.Event_Type_OE_Defined__c+'",'+
                              '"orderId":"'+ ord.Id+'"';
               body = body+ addProjectManagers(ord); 
               body = body+ addRequestorContract(ord);
               body = body + '}';
               String eventString ;
               String orderId;
               String eventId;
               String externalEventId;
               String errorMsg;
               boolean syncFailed = false;
                             
               System.debug('Body------------->> '+Body);
               req2.setBody(body);
               HttpResponse res2 = http.send(req2);
                
               System.debug('Res2------------->> '+res2.toString());
               JSONParser jpar2 = JSON.createParser(res2.getBody());
               
               
               while(jpar2.nextToken() != NULL){
                   System.debug('---->' + jpar2.getText());
                   
                   if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'eventLink'){
                       jpar2.nextToken();
                       eventString = jpar2.getText();
                       System.debug('eventString ------------->>'+eventString);
                   }
                   if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'orderId'){
                       jpar2.nextToken();
                       orderId = jpar2.getText();
                       System.debug('orderId ------------->>'+orderId);
                   }
                   if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'eventId'){
                       jpar2.nextToken();
                       eventId = jpar2.getText();
                       System.debug('eventId ------------->>'+eventId);
        
                   }
                   if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'externalEventId'){
                       jpar2.nextToken();
                       externalEventId = jpar2.getText();
                       System.debug('externalEventId ------------->>'+externalEventId);
                   }
           
                   if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'errorMessages'){
                       jpar2.nextToken();
                       jpar2.nextToken();
                       errorMsg = jpar2.getText();
                       System.debug('errorMsg---------->>'+errorMsg);
                       syncFailed = true;
                    
                   }
                   
                       
               }
               if(String.isNotBlank(eventString) && String.isNotBlank(orderId))
               {
                   
                   updateOrd =  [Select Id,OE_Central_URL__c, Order_Process__c, SyncStatus__c from Order where Id = :orderId];
                   updateOrd.OE_Central_URL__c = eventString;
                   updateOrd.SyncStatus__c='Synced';
                   updateOrd.Sync_Datetime__c = System.now();
                   updateOrd.OECEventId__c = eventId;
                   updateOrd.OECExternalEventId__c = externalEventId;
                   updateOrd.Order_Process__c = 'ProcessForTeams';
                   if(String.isBlank(ord.Order_TimeZone__c))
                       updateOrd.Order_TimeZone__c = GMTTimeZone;
                   update updateOrd; 
                   
               }
               else //if (syncFailed)
               {
                   updateOrd =  [Select Id,SyncStatus__c, Order_Process__c,Sync_Error_Message__c from Order where Id = :ord.Id];
                   updateOrd.SyncStatus__c='Failed'; 
                   updateOrd.Sync_Error_Message__c=errorMsg;
                   updateOrd.Order_Process__c = 'ProcessForTeams';
                   update updateOrd;
               }   
               
               
                
          }
          else
          {
             
             updateOrd =  [Select Id,SyncStatus__c, Sync_Error_Message__c,Order_Process__c from Order where Id = :ord.Id];
             updateOrd.SyncStatus__c='Failed'; 
             updateOrd.Sync_Error_Message__c='Authentication Failed';
             updateOrd.Order_Process__c = 'ProcessForTeams';
             update updateOrd;
          } 
          
        }  

    }
   global static void getAccessToken(String outBoundCallName){
    
        //select 
        
    }
    public static String findTimeZoneValue(String tzn){
          
       String GMTTimezoneName = 'UTC';
      
       if(String.isNotBlank(tzn)){
           System.debug('tzn ----->>'+tzn);
           
           Map<String,TimeZones__mdt> dlsTZ ;
           Map<String,StandardTimeZone__mdt> standardTZ ;
        
           TimeZoneConfiguration__mdt tt = [SELECT TimeZoneType__c from TimeZoneConfiguration__mdt];
           String timeZoneType = tt.TimeZoneType__c;
           System.debug('timeZoneType ----->>'+timeZoneType);
           String timeZoneValue ;  
           //if (timeZoneType == 'DaylightSaving'){
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
    /*
    private static void findProjectManagers(Order ord){
    
       if (String.isNotblank(ord.Project_Manager__c))  
           pm = [select email,FirstName,LastName from Contact where id = :ord.Project_Manager__c];
       if (String.isNotblank(ord.Project_Manager_2__c))    
           coPM = [select email,FirstName,LastName from Contact where id = :ord.Project_Manager_2__c];
        
    }     */
    private static String addProjectManagers(Order ord){
        boolean pmExist = false;
        boolean copmExist = false;
        Contact pm;
        Contact coPM;
       if (String.isNotblank(ord.Project_Manager__c))  
           pm = [select email,FirstName,LastName from Contact where id = :ord.Project_Manager__c];
       if (String.isNotblank(ord.Project_Manager_2__c))    
           coPM = [select email,FirstName,LastName from Contact where id = :ord.Project_Manager_2__c];
           
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

     public static void loadCalloutParams(){
    
        Integration_Configuration__mdt ic = [SELECT API_Environment__c from Integration_Configuration__mdt];
        String apiEnvironment;
        apiEnvironment = ic.API_Environment__c;
        
        System.debug('API Environment getting connected is -----> :'+apiEnvironment); 
        //CalloutData__c cd;

        if (apiEnvironment == 'QA'){
            OECCallOuts__mdt callouts = [SELECT QATeamsCreationEndpointURL__c, QACancelEndpointURL__c, QAAccountId__c,QAAuthURL__c,QAEndpointURL__c,QAPassword__c,QAUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            //OECCallOuts__mdt callouts = [SELECT QAAccountId__c,QAAuthURL__c,QAEndpointURL__c,QAPassword__c,QAUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            calloutData = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QAEndpointURL__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);
            teamscd = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QATeamsCreationEndpointURL__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);
            cancelledcd = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QACancelEndpointURL__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);
            
        }
        else if (apiEnvironment == 'Prod'){
            OECCallOuts__mdt callouts = [SELECT ProdTeamsCreationEndpointURL__c,ProdCancelEndpointURL__c, ProdAccountId__c,ProdAuthURL__c,ProdEndpointURL__c,ProdPassword__c,ProdUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            calloutData = new CalloutData__c(AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProdEndpointURL__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);
            teamscd = new CalloutData__c (AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProdTeamsCreationEndpointURL__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);
            cancelledcd = new CalloutData__c (AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProdCancelEndpointURL__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);
        }
        else {
            
            OECCallOuts__mdt callouts = [SELECT StageTeamsCreationEndpointURL__c,StageCancelEndpointURL__c, DevAccountId__c,DevAuthURL__c,DevEndpointURL__c,DevPassword__c,DevUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            System.debug('StageTeamsCreationEndpointURL__c----------->>'+callouts.StageTeamsCreationEndpointURL__c);
            calloutData = new CalloutData__c(AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.DevEndpointURL__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
            teamscd = new CalloutData__c (AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.StageTeamsCreationEndpointURL__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
            System.debug('teamscd.StageTeamsCreationEndpointURL__c----------->>'+teamscd.EndPointURL__c);
            cancelledcd = new CalloutData__c (AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.StageCancelEndpointURL__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
        }
                
    }
    @future(callout=true)
    public static void callOrderTeamsCreationSync( Set<ID> orderIDList){
    
    }
}