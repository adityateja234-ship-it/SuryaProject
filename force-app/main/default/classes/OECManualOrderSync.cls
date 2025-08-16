global class OECManualOrderSync implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    Map<id,Order> IdOrderMapBatch=new Map<id,Order>();
    public String accessToken;
    CalloutData__c calloutData ;
    Contact pm;
    Contact coPM;
    private static String GMTTimeZone = 'UTC';   
    global OECManualOrderSync(Map<id,Order> IdOrderMap, CalloutData__c cd){ 
        
        IdOrderMapBatch=IdOrderMap;
        calloutData=cd;
        //getAccessToken(outBoundCallName);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        
        return Database.getQueryLocator([SELECT id,OrderNumber, Description,AccountId, End_Date_Time__c, EventNotes__c,Order_TimeZone__c,Start_Date_Time__c, Event_Type_OE_Defined__c, OEC_Event_Name__c,Name,TimeZone__c,region__c,Business_Line__c, Project_Manager_2__c,Project_Manager__c from order where status = 'In Progress' and id in:IdOrderMapBatch.keySet()]);
    }
    
    global void execute(Database.BatchableContext BC, List<Order> scope) { 
           
        for(Order ord : scope)
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
               findProjectManagers(ord);
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
               body = body+ addProjectManagers(); 
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
                   
                   updateOrd =  [Select Id,OE_Central_URL__c,SyncStatus__c from Order where Id = :orderId];
                   updateOrd.OE_Central_URL__c = eventString;
                   updateOrd.SyncStatus__c='Synced';
                   updateOrd.Sync_Datetime__c = System.now();
                   updateOrd.OECEventId__c = eventId;
                   updateOrd.OECExternalEventId__c = externalEventId;
                   if(String.isBlank(ord.Order_TimeZone__c))
                       updateOrd.Order_TimeZone__c = GMTTimeZone;
                   update updateOrd; 
                   
               }
               else //if (syncFailed)
               {
                   updateOrd =  [Select Id,SyncStatus__c, Sync_Error_Message__c from Order where Id = :ord.Id];
                   updateOrd.SyncStatus__c='Failed'; 
                   updateOrd.Sync_Error_Message__c=errorMsg;
                   update updateOrd;
               }   
               
               
                
          }
          else
          {
             
             updateOrd =  [Select Id,SyncStatus__c, Sync_Error_Message__c from Order where Id = :ord.Id];
             updateOrd.SyncStatus__c='Failed'; 
             updateOrd.Sync_Error_Message__c='Authentication Failed';
             update updateOrd;
          } 
          
        }  
          
    }
    global void finish(Database.BatchableContext BC){
    
    }
    global void getAccessToken(String outBoundCallName){
    
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

}