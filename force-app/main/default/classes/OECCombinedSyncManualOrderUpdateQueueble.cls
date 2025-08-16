global class OECCombinedSyncManualOrderUpdateQueueble implements Queueable, Database.AllowsCallouts{
    
    static CalloutData__c calloutData;
    public List<Order> ords;
    public boolean validForUpdate;
    private Map<Id,Order> triggerOldmapVar = new map<Id,Order>();
    public String createOEC = 'false';
    public String createLasso = 'false';
    public String createTeam = 'false';
    
    global OECCombinedSyncManualOrderUpdateQueueble(Set<ID> orderIDList, map<Id,Order> triggerOldmap, String ctOEC, String ctLasso, String crtTeam){
        ords = [SELECT id,OrderNumber,Account.Name, Department__c, Channel_Agency_Referral__c, Channel_Agency_Referral__r.Name, RecordType.Name, OECEventID__c, teams_created__c, CancelledStatusProcessedForLasso__c, CancelledStatusProcessedForOEC__c, 
                Lasso_Event_ID__c, Account.Primary_Account_Manager__c, Account.Legal_Entity__c, Description,AccountId, End_Date_Time__c, EventNotes__c,Order_TimeZone__c,Start_Date_Time__c, Event_Type_OE_Defined__c,OEC_Event_Name__c, 
                Lasso_New_Sync_Status__c, Name,TimeZone__c,OE_Central_URL__c,SyncStatus__c,Sync_Error_Message__c,Sync_Retry_Count__c,recordtypeid,CreatedBy.Name, Business_Line__c, 
                Status,Sync_to_OEC__c,Account.External_Sync__c, region__c, Project_Manager_2__c, Order_Process__c, ProcessedForLasso__c, No_Staff_Required__c, Project_Manager__c,
                Requester_Contact__r.FirstName,Requester_Contact__r.LastName,Requester_Contact__r.Email from order where status = 'In Progress' and id in:orderIDList];
        triggerOldmapVar = triggerOldmap;
        createOEC = ctOEC;
        createLasso = ctLasso;
        createTeam = crtTeam;
    }
    
    global void execute(QueueableContext BC) {
        loadCalloutParams();
        String GMTTimeZone = 'UTC';
        System.debug('calloutData------>>'+calloutData);
        
        for(Order ord : ords){
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(calloutData.AuthenticationURL__c);
            req.setMethod('POST');
            Blob headerValue = Blob.valueof(calloutData.UserName__c+':'+calloutData.UserPassword__c);
            String authorizationValue = 'Basic '+EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization',authorizationValue);
            HttpResponse res = http.send(req);
            Order updateOrd = new Order();
            
            if (res.getStatusCode() == 200){
                JSONParser jpar = JSON.createParser(res.getBody());
                String idTokenString;
                while(jpar.nextToken() != NULL){
                    if((jpar.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar.getText() == 'idToken'){
                        jpar.nextToken();
                        idTokenString = jpar.getText();
                    }
                }
                
                HttpRequest req2 = new HttpRequest();
                req2.setEndpoint(calloutData.EndPointURL__c);
                req2.setMethod('PUT');
                req2.setHeader('Content-Type', 'application/json');
                req2.setHeader('X-OEX-SF-Account-ID', ord.AccountId);
                req2.setHeader('X-OEX-Int-Account-ID', calloutData.AccountId__c);
                req2.setHeader('X-OEX-Int-Authorization',idTokenString);
                req2.setTimeout(120000);
                
                String body = getBodyString(ord,triggerOldmapVar) ;
                System.debug('Body in Update Call------------------------------->>'+body);
                
                String orderId;
                String eventString;
                String eventId;
                String externalEventId;
                String oecErrorMsg;
                String teamId;
                String teamsErrorMsg;
                String lassoId;
                String lassoEventUrl;
                String lassoErrorMsg;
                String errorMsg;
                
                req2.setBody(body);
                HttpResponse res2 = http.send(req2);
                System.debug('Response for update StatusCode ------------->> '+res2.getStatusCode());
                System.debug('Response for update body ------------->> '+res2.getBody());
                JSONParser jpar2 = JSON.createParser(res2.getBody());
                
                while(jpar2.nextToken() != NULL){
                    
                    if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'orderId'){
                        jpar2.nextToken();
                        orderId = jpar2.getText();
                    }                    
                    if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'eventLink'){
                        jpar2.nextToken();
                        eventString = jpar2.getText();
                    }                    
                    if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'eventId'){
                        jpar2.nextToken();
                        eventId = jpar2.getText();
                    }
                    if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'externalEventId'){
                        jpar2.nextToken();
                        externalEventId = jpar2.getText();
                    }
                    if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'oecEvent'){
                        jpar2.nextToken();
                        oecErrorMsg = jpar2.getText();
                    }
                    if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'teamId'){
                        jpar2.nextToken();
                        teamId = jpar2.getText();
                    }
                    if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'teams'){
                        jpar2.nextToken();
                        teamsErrorMsg = jpar2.getText();
                    }                    
                    if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'lassoId'){
                        jpar2.nextToken();
                        lassoId = jpar2.getText();
                    }
                    if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'lassoEventUrl'){
                        jpar2.nextToken();
                        lassoEventUrl = jpar2.getText();
                    }
                    if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'lassoEvent'){ 
                        jpar2.nextToken();
                        lassoErrorMsg = jpar2.getText();
                    }
                    if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'errorMessages'){
                        jpar2.nextToken();
                        jpar2.nextToken();
                        errorMsg = jpar2.getText();
                    }
                }
                
                if(String.isNotBlank(orderId)){
                    updateOrd =  [SELECT Id, OE_Central_URL__c, SyncStatus__c, Sync_Datetime__c, OECEventId__c, 
                                  Lasso_Event_ID__c, Lasso_URL__c, Lasso_Sync_Datetime__c, Lasso_New_Sync_Status__c, ProcessedForLasso__c, 
                                  Team_ID_Created__c, teams_created__c, Order_TimeZone__c, Sync_Error_Message__c, Lasso_Error_Message__c, 
                                  Team_Creation_Error_Message__c
                                  FROM Order WHERE Id = :orderId
                                 ];
                    
                    if(String.isNotBlank(eventString) && eventString !='null' && eventId != 'null'  && String.isBlank(oecErrorMsg)){
                        updateOrd.OE_Central_URL__c = eventString;
                        updateOrd.SyncStatus__c = 'Synced';
                        updateOrd.Sync_Datetime__c = System.now();
                        updateOrd.OECEventId__c = eventId;
                        updateOrd.Sync_Error_Message__c = '';
                    }
                    if(String.isNotBlank(lassoId) && lassoId != 'null'){
                        updateOrd.Lasso_Event_ID__c = lassoId;
                        updateOrd.Lasso_URL__c = lassoEventUrl;
                        updateOrd.Lasso_Sync_Datetime__c = System.now();
                        updateOrd.Lasso_New_Sync_Status__c = 'Synced';
                        updateOrd.ProcessedForLasso__c = true;
                        updateOrd.Lasso_Error_Message__c = '';
                    }
                    if(String.isNotBlank(teamId) && String.isBlank(teamsErrorMsg)){
                        updateOrd.Team_ID_Created__c = teamId;
                        updateOrd.teams_created__c = 'Created';
                        updateOrd.Team_Creation_Error_Message__c = '';
                    }
                    if(String.isNotBlank(oecErrorMsg)){
                        updateOrd.Sync_Error_Message__c = oecErrorMsg;
                    }
                    if(String.isNotBlank(lassoErrorMsg)){
                        updateOrd.Lasso_Error_Message__c = lassoErrorMsg;
                    }
                    if(String.isNotBlank(teamsErrorMsg)){
                        updateOrd.Team_Creation_Error_Message__c = teamsErrorMsg;
                    }
                    update updateOrd;
                }
                else{
                    updateOrd =  [SELECT Id, SyncStatus__c, Sync_Error_Message__c FROM Order WHERE Id = :ord.Id];
                    updateOrd.Sync_Error_Message__c = errorMsg;
                    update updateOrd;
                }
            }
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
            
            dlsTZ = TimeZones__mdt.getAll();
            for(String timezoneName : dlsTZ.keySet()){
                if(dlsTZ.get(timezoneName).TimeZone_Name__c == tzn)
                    return dlsTZ.get(timezoneName).TimeZone_Value__c;
            }
            
            standardTZ = StandardTimeZone__mdt.getAll();
            for(String timezoneName : standardTZ.keySet()){
                if(standardTZ.get(timezoneName).TimeZone_Name__c == tzn)
                    return standardTZ.get(timezoneName).TimeZone_Value__c;
            }
        }
        return GMTTimezoneName;
    }
    
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
        return managersBody;
    }
    
    private static String removeBothProjectManagers(Order ord){
        
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
            managersBody = ', "removedDeliveryTeamMembers": [';
            
            if (pmExist){
                managersBody = managersBody + '{ "deliveryTeamMemberRole": "'+'PROJECT_MANAGER" ';
                if(String.isNotblank(pm.email))
                    managersBody = managersBody + ', "email": "'+pm.email+'"';
                if(String.isNotblank(pm.FirstName))
                    managersBody = managersBody + ', "firstName": "'+pm.FirstName+'"';
                if(String.isNotblank(pm.LastName))
                    managersBody = managersBody + ', "lastName": "'+pm.LastName+'"';  
                managersBody = managersBody + ', "active": true';
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
                managersBody = managersBody + ', "active": true';
            }
        }
        if (pmExist || copmExist)
            managersBody = managersBody +'}]';
        return managersBody;
    }
    
    private static String removeProjectManagers(Order ord){
        
        boolean pmExist = false;
        Contact pm;
        if (String.isNotblank(ord.Project_Manager__c))  
            pm = [select email,FirstName,LastName from Contact where id = :ord.Project_Manager__c];
        
        String managersBody ='';
        if( pm != null) {
            if (String.isNotblank(pm.email) || String.isNotblank(pm.LastName) || String.isNotblank(pm.FirstName)){
                pmExist = true;
            }  
        }
        if(pmExist){
            managersBody = ', "removedDeliveryTeamMembers": [';
            
            if (pmExist){
                managersBody = managersBody + '{ "deliveryTeamMemberRole": "'+'PROJECT_MANAGER" ';
                if(String.isNotblank(pm.email))
                    managersBody = managersBody + ', "email": "'+pm.email+'"';
                if(String.isNotblank(pm.FirstName))
                    managersBody = managersBody + ', "firstName": "'+pm.FirstName+'"';
                if(String.isNotblank(pm.LastName))
                    managersBody = managersBody + ', "lastName": "'+pm.LastName+'"';  
                managersBody = managersBody + ', "active": true';
            }
        }
        if (pmExist)
            managersBody = managersBody +'}]';
        return managersBody;
    }
    
    private static String removeCoProjectManagers(Order ord){
        
        boolean copmExist = false;
        Contact coPM;
        if (String.isNotblank(ord.Project_Manager_2__c))    
            coPM = [select email,FirstName,LastName from Contact where id = :ord.Project_Manager_2__c];
        
        String managersBody ='';
        if(coPM != null) {
            if (String.isNotblank(coPM.email) || String.isNotblank(coPM.LastName) || String.isNotblank(coPM.FirstName)){
                copmExist = true;
            }
        }
        if(copmExist){
            managersBody = ', "removedDeliveryTeamMembers": [';
            
            if (copmExist){
                managersBody = managersBody + '{ "deliveryTeamMemberRole": "'+'CO_PROJECT_MANAGER" ';
                if(String.isNotblank(coPM.email))
                    managersBody = managersBody + ', "email": "'+coPM.email+'"';
                if(String.isNotblank(coPM.FirstName))
                    managersBody = managersBody + ', "firstName": "'+coPM.FirstName+'"';
                if(String.isNotblank(coPM.LastName))
                    managersBody = managersBody + ', "lastName": "'+coPM.LastName+'"';  
                managersBody = managersBody + ', "active": true';
            }
        }
        if (copmExist)
            managersBody = managersBody +'}]';
        return managersBody;
    }
    
    public static void loadCalloutParams(){
        
        Integration_Configuration__mdt ic = [SELECT API_Environment__c from Integration_Configuration__mdt];
        String apiEnvironment;
        apiEnvironment = ic.API_Environment__c;
        
        if (apiEnvironment == 'QA'){
            OECCallOuts__mdt callouts = [SELECT QACombinedCreateEventEndpointURL__c,QALassoOrderCancelEndpoint__c, QAMSTeamsArchiveEndpointURL__c,QATeamsCreationEndpointURL__c, QACancelEndpointURL__c, QAAccountId__c,QAAuthURL__c,QAEndpointURL__c,QAPassword__c,QAUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            calloutData = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QACombinedCreateEventEndpointURL__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);
        }
        else if (apiEnvironment == 'Prod'){
            OECCallOuts__mdt callouts = [SELECT ProdCombinedCreateEventEndpointURL__c,ProductionLassoOrderCancelEndpoint__c,ProdMSTeamsArchiveEndpointURL__c,ProdTeamsCreationEndpointURL__c,ProdCancelEndpointURL__c, ProdAccountId__c,ProdAuthURL__c,ProdEndpointURL__c,ProdPassword__c,ProdUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            calloutData = new CalloutData__c(AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProdCombinedCreateEventEndpointURL__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);
        }
        else {
            OECCallOuts__mdt callouts = [SELECT StageCombinedCreateEventEndpointURL__c,StageLassoOrderCancelEndpoint__c,StageMSTeamsArchiveEndpointURL__c, StageTeamsCreationEndpointURL__c,StageCancelEndpointURL__c, DevAccountId__c,DevAuthURL__c,DevEndpointURL__c,DevPassword__c,DevUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            calloutData = new CalloutData__c(AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.StageCombinedCreateEventEndpointURL__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
        }
    }
    
    public String getBodyString(Order ord, map<Id,Order> triggerOldmap){
        
        String ed = ord.End_Date_Time__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String sd = ord.Start_Date_Time__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String timeZoneValue = findTimeZoneValue(ord.Order_TimeZone__c);
        System.debug('timeZoneValue ---> '+timeZoneValue);
        
        String body = '{'+
            '"endDateTime":"'+ed+'",'+
            '"oeNumber":"'+(ord.OrderNumber).replaceFirst( '^0+', '')+'",'+
            '"lassoTimezone":"'+ord.Order_TimeZone__c+'",'+    
            '"name":"'+ord.Name+'",';
        
        if(String.isNotBlank(ord.Region__c) && (ord.Region__c == 'AMER' || ord.Region__c == 'APAC' || ord.Region__c == 'EMEA'))
            body = body+ '"region":"'+ord.Region__c+'",';
        
        if(String.isNotBlank(ord.Business_Line__c) && (ord.Business_Line__c != 'None'))
            body = body+ '"businessLine":"'+ord.Business_Line__c+'",';
        
        if(String.isNotBlank(ord.Account.Legal_Entity__c))
            body = body+ '"accountLegalEntity":"'+ord.Account.Legal_Entity__c+'",';
        
        if(String.isNotBlank(ord.Lasso_Event_ID__c))
            body = body+ '"lassoEventId":"'+ord.Lasso_Event_ID__c+'",';
        
        if(String.isNotBlank(ord.OE_Central_URL__c))
            body = body+ '"oecEventLink":"'+ord.OE_Central_URL__c+'",';
        
        if(String.isNotBlank(ord.OECEventId__c))
            body = body+ '"oecEventId":"'+ord.OECEventId__c+'",';
        
        body= body+    '"startDateTime":"'+sd+'",'+
            '"timeZone":"'+timeZoneValue+'",'+
            '"type":"'+ord.Event_Type_OE_Defined__c+'",'+
            '"createOEC":"'+createOEC+'",'+
            '"createLasso":"'+createLasso+'",'+
            '"createTeams":"'+createTeam+'",'+ // Added by Nilesh Bharti as Part of OEP-18254
            '"orderId":"'+ ord.Id+'"';
        body = body+ addProjectManagers(ord);
        if(ord.Project_Manager__c != triggerOldmap.get(ord.Id).Project_Manager__c && ord.Project_Manager_2__c != triggerOldmap.get(ord.Id).Project_Manager_2__c){
            body = body+ removeBothProjectManagers(triggerOldmap.get(ord.Id));
        }
        else if(ord.Project_Manager__c != triggerOldmap.get(ord.Id).Project_Manager__c){
            body = body+ removeProjectManagers(triggerOldmap.get(ord.Id));
        }
        else if(ord.Project_Manager_2__c != triggerOldmap.get(ord.Id).Project_Manager_2__c){
            body = body+ removeCoProjectManagers(triggerOldmap.get(ord.Id));
        }
        body = body+ addRequestorContract(ord);
        body = body+ ',"lassoEventName":"[ '+ (ord.OrderNumber).replaceFirst( '^0+', '') +' ] '+ ord.Region__c +' '+ord.Account.Name+' - '+ord.Name+' - SF Synced",';
        body = body+ '"clientName":"'+ord.Account.Name+'"';
        if(String.isNotBlank(ord.Account.Primary_Account_Manager__c))
            body = body+ ',"accountManager":"'+ord.Account.Primary_Account_Manager__c+'"';
        
        // Add the Channel field only if the name is 'Zoom' --- added by Nilesh Bharti as Part of OEP-18164
        if (String.isNotBlank(ord.Channel_Agency_Referral__c) && ord.Channel_Agency_Referral__c == '001d0000010b5x0AAA') {
            body = body + ',"lassoEventType":"'+ord.Channel_Agency_Referral__r.Name+'"';
        }
        
        // Calculating dateTime based on Order Timezone --- added by Nilesh Bharti as Part of OEP-17933
        String startDateTimeInOrderTimeZone = ord.Start_Date_Time__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', timeZoneValue);
        String endDateTimeInOrderTimeZone = ord.End_Date_Time__c.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', timeZoneValue);
        body = body + ',"lassoStartDateTime":"'+startDateTimeInOrderTimeZone+'"';
        body = body + ',"lassoEndDateTime":"'+endDateTimeInOrderTimeZone+'"';
        
        // Added by Nilesh Bharti as Part of OEP-17772
        if(String.isNotBlank(ord.Department__c))
            body = body + ',"department":"'+ord.Department__c+'"';
        
        body = body + '}';
        return body;
    }
    
    private static String addRequestorContract(Order ord){
        
        String requestorContract = ', "coordinators": [{';
        if(String.isNotblank(ord.Requester_Contact__r.Email))
            requestorContract = requestorContract + '"username": "'+ord.Requester_Contact__r.Email+'",';
        if(String.isNotblank(ord.Requester_Contact__r.FirstName))    
            requestorContract = requestorContract + ' "firstName": "'+ord.Requester_Contact__r.FirstName+' ",';
        if(String.isNotblank(ord.Requester_Contact__r.LastName))     
            requestorContract = requestorContract + ' "lastName": "'+ord.Requester_Contact__r.LastName+'"';
        
        requestorContract = requestorContract +'}]';
        return requestorContract;
    }
}