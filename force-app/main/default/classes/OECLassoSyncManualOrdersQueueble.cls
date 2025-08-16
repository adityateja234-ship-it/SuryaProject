global class OECLassoSyncManualOrdersQueueble  implements Queueable, Database.AllowsCallouts{

    static CalloutData__c calloutData;
    public List<Order> ords;
    
    //-- delete after testing
    //Set<ID> orderIDList2 = new Set<ID>();
    
    // -- delete after testing 
    
    
    //public static void callManualOrderSync( Set<ID> orderIDList){
    
    global OECLassoSyncManualOrdersQueueble(Set<ID> orderIDList){ 
        
        System.debug('------>> in constructor');
        ords = [SELECT id,OrderNumber, ProcessedForLasso__c, Description,OE_Central_URL__c,Account_Legal_Entity__c,Lasso_New_Sync_Status__c,AccountId, Account.Name, Account.Primary_Account_Manager__c,End_Date_Time__c, EventNotes__c,Order_TimeZone__c,Start_Date_Time__c, Event_Type_OE_Defined__c, OEC_Event_Name__c,Name,TimeZone__c,region__c,Business_Line__c, Project_Manager_2__c,Project_Manager__c from order where status = 'In Progress' and id in:orderIDList];
       
        System.debug('orderIDList------>>'+orderIDList.size());

        //orderIDList2= orderIDList;

    }
    
     global void execute(QueueableContext BC) { 
        //List<Order> ords = [SELECT id,OrderNumber, Description,AccountId, End_Date_Time__c, EventNotes__c,Order_TimeZone__c,Start_Date_Time__c, Event_Type_OE_Defined__c, OEC_Event_Name__c,Name,TimeZone__c,region__c,Business_Line__c, Project_Manager_2__c,Project_Manager__c from order where status = 'In Progress' and id in:orderIDList];
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
                         'TimeZone__c :'+ord.TimeZone__c +
                         'Account.Name :'+ Account.Name+
                         'Lasso_New_Sync_Status__c'+ord.Lasso_New_Sync_Status__c
           );  
           
           System.debug('Lasso_New_Sync_Status__c'+ord.Lasso_New_Sync_Status__c);
                      
           if(ord.Lasso_New_Sync_Status__c == 'Never Synced'){
               
               
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
                                  '"endDate":"'+ed+'",'+
                                  '"externalCode":"'+(ord.OrderNumber).replaceFirst( '^0+', '')+'",'+
                                  '"name":"[ '+ (ord.OrderNumber).replaceFirst( '^0+', '') +' ] '+ ord.Region__c +' '+ord.Account.Name+' - '+ord.OEC_Event_Name__c+' - SF Synced",';
                                  
                            
                   if(String.isNotBlank(ord.Region__c) && (ord.Region__c == 'AMER' || ord.Region__c == 'APAC' || ord.Region__c == 'EMEA'))               
                          body = body+ '"region":"'+ord.Region__c+'",';    
                          
                   if(String.isNotBlank(ord.Business_Line__c) && (ord.Business_Line__c != 'None'))
                          body = body+ '"businessline":"'+ord.Business_Line__c+'",';          
                          
                   if(String.isNotBlank(ord.Account_Legal_Entity__c))
                          body = body+ '"account Legal Entity":"'+ord.Account_Legal_Entity__c+'",';    
                          
                   if(String.isNotBlank(ord.OE_Central_URL__c))
                          body = body+ '"oecUrl":"'+ord.OE_Central_URL__c+'",'; 
                          
                   //if(String.isNotBlank(ord.Description))
                   //       body = body+ '"description":"'+ord.Description+'",'; 
                          
                                                   
                   body= body+    '"startDate":"'+sd+'",'+
                                  '"clientName":"'+ord.Account.Name+'",'+               
                                  //'"timezone":"'+timeZoneValue+'",'+\
                                  '"timezone":"'+ord.Order_TimeZone__c+'",'+                                   
                                  '"accountManager":"'+ord.Account.Primary_Account_Manager__c+'",'+ 
                                  '"type":"'+ord.Event_Type_OE_Defined__c+'",'+
                                  //'"oecUrl":"'+ ord.OE_Central_URL__c+'",'+ 
                                  //'"description":"'+ ord.Description+'",'+ 
                                  '"salesforceOrderId":"'+ ord.Id+'"';
                   body = body+ addProjectManagers(ord); 
                   body = body + '}';

                   String lassoId;
                   String lassoURL;
                   String lassoError;
                                 
                   System.debug('Body of Lasso Sync------------->> '+body);
                   req2.setBody(body);
                   HttpResponse res2 = http.send(req2);
                    
                   System.debug('Res2------------->> '+res2.toString());
                   JSONParser jpar2 = JSON.createParser(res2.getBody());
                   
                   
                   while(jpar2.nextToken() != NULL){
                       System.debug('---->' + jpar2.getText());
                       
                       if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'id'){
                           jpar2.nextToken();
                           lassoId = jpar2.getText();
                           System.debug('lassoId ------------->>'+lassoId);
                       }
                       if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'lassoEventUrl'){
                           jpar2.nextToken();
                           lassoURL = jpar2.getText();
                           System.debug('lassoURL ------------->>'+lassoURL);
                       }
                       if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'errorMessages')
                       {
                           jpar2.nextToken();
                           jpar2.nextToken();
                           lassoError = jpar2.getText();
                           System.debug('lassoError ------------->>'+lassoError);
                       }    
                   }
                   if(String.isNotBlank(lassoId))
                   {
                       
                       updateOrd =  [Select Lasso_New_Sync_Status__c,Order_Process__c,Lasso_URL__c, Lasso_Sync_Datetime__c,ProcessedForLasso__c from Order where Id = :ord.Id];
                       updateOrd.Lasso_URL__c = lassoURL;
                       updateOrd.Lasso_New_Sync_Status__c='Synced';
                       updateOrd.Lasso_Sync_Datetime__c = System.now();
                       updateOrd.ProcessedForLasso__c = true;
                       updateOrd.Order_Process__c = 'Done';
                       updateOrd.Lasso_Event_ID__c = lassoId;
                       update updateOrd; 
                       
                   }
                   else //if (syncFailed)
                   {
                       updateOrd =  [Select Id,Lasso_New_Sync_Status__c, Order_Process__c,Lasso_Sync_Datetime__c,ProcessedForLasso__c from Order where Id = :ord.Id];
                       updateOrd.Lasso_New_Sync_Status__c='Not Synced';
                       updateOrd.Lasso_Sync_Datetime__c = System.now();
                       //updateOrd.Sync_Error_Message__c=errorMsg;
                       updateOrd.ProcessedForLasso__c = true;
                       updateOrd.Order_Process__c = 'Done';
                       //updateOrd.Lasso_Error_Message__c = lassoError;
                       update updateOrd;
                   }   
                   
                   
                    
              }
              else
              {
                 
                       updateOrd =  [Select Id,Lasso_New_Sync_Status__c, Order_Process__c,Lasso_Sync_Datetime__c,ProcessedForLasso__c from Order where Id = :ord.Id];
                       updateOrd.Lasso_New_Sync_Status__c='Not Synced';
                       updateOrd.Lasso_Sync_Datetime__c = System.now();
                       //updateOrd.Sync_Error_Message__c=errorMsg;
                       updateOrd.ProcessedForLasso__c = true;
                       updateOrd.Order_Process__c = 'Done';
                       update updateOrd;
              } 
              
         } //(Lasso_New_Sync_Status__c == 'Never Synced')
        } 
        
        //System.enqueueJob(new FibonacciDepthQueueable(fibonacciSequenceStep, nMinus1));
        //System.enqueueJob(new (orderIDList2));   

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
            managersBody = ', "projectManagers": [';
            
            if (pmExist){
                if(String.isNotblank(pm.email))
                  managersBody = managersBody+'"' +pm.email+'"';
            }
            if (pmExist && copmExist)
                managersBody = managersBody + ',';
            if (copmExist){
                if(String.isNotblank(coPM.email))
                  managersBody = managersBody +'"'+coPM.email+'"';
            }
        }
        if (pmExist || copmExist)
            managersBody = managersBody +']';
        System.debug('managersBody------------------>>'+managersBody);
        return managersBody;
    } 

     public static void loadCalloutParams(){
    
        Integration_Configuration__mdt ic = [SELECT API_Environment__c from Integration_Configuration__mdt];
        String apiEnvironment;
        apiEnvironment = ic.API_Environment__c;
        
        System.debug('API Environment getting connected is -----> :'+apiEnvironment); 
        //CalloutData__c cd;

        if (apiEnvironment == 'QA'){
            OECCallOuts__mdt callouts = [SELECT QA_LassoOrderCreationEndpoint__c, QAAccountId__c,QAAuthURL__c,QAPassword__c,QAUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            //OECCallOuts__mdt callouts = [SELECT QAAccountId__c,QAAuthURL__c,QAEndpointURL__c,QAPassword__c,QAUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            calloutData = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QA_LassoOrderCreationEndpoint__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);
                 
        }
        else if (apiEnvironment == 'Prod'){
            OECCallOuts__mdt callouts = [SELECT ProductionLassoOrderCreationEndpoint__c, ProdAccountId__c,ProdAuthURL__c,ProdPassword__c,ProdUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            calloutData = new CalloutData__c(AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProductionLassoOrderCreationEndpoint__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);
                    }
        else {
            
            OECCallOuts__mdt callouts = [SELECT StageLassoCreateEventEndPointURL__c, DevAccountId__c,DevAuthURL__c,DevPassword__c,DevUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
           
            calloutData = new CalloutData__c(AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.StageLassoCreateEventEndPointURL__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
            
        }
                
    }
    @future(callout=true)
    public static void callOrderTeamsCreationSync( Set<ID> orderIDList){
    
    }
}