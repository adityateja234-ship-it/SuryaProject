global class OECOpportunityMSTeamsServiceQueueble implements Queueable, Database.AllowsCallouts
{
    
    public List<Opportunity> oppList;
    CalloutData__c calloutData ;
  
    global OECOpportunityMSTeamsServiceQueueble(Set<ID> oppIDList, CalloutData__c cd){ 
        
        System.debug('------>> in constructor');
        oppList = [SELECT id, Owner.Name, Expected_Services__c,Account.Name, Processed_For_MSTeams_ClosedWon__c, Name, Amount,Type, Opportunity_Type__c, Opportunity_Subtype__c,Closed_Won_Reason__c,Closed_Comments__c,  StageName from Opportunity where id in:oppIDList FOR UPDATE];
        
        System.debug('orderIDList------>>'+oppList.size());
        calloutData=cd;
 
    }

    global void execute(QueueableContext BC) { 
           
        System.debug('------>> in Execute'); 
        List<Opportunity> opportunityList = new List<Opportunity>();  
        for(Opportunity opp : oppList)
        {    
           
           System.debug('Order Details --->'+
                         ' ID :'+ opp.Id+
                         ' Type :'+opp.Opportunity_Type__c+
                         ' Account.Name:'+Account.Name+
                         ' Name:'+ opp.Name+
                         ' Amount:'+opp.Amount+
                         ' Opportunity_Subtype__c:'+ opp.Opportunity_Subtype__c+
                         ' Closed_Won_Reason__c:'+ opp.Closed_Won_Reason__c+
                         ' Closed_Won_Comments__c:'+ opp.Closed_Comments__c
                                    );
           

          if( opp.StageName == 'Closed Won' && !opp.Processed_For_MSTeams_ClosedWon__c)
    
              {
           
               Http http = new Http();
               HttpRequest req = new HttpRequest();
               
               req.setEndpoint(calloutData.AuthenticationURL__c);
               req.setMethod('POST');
               
               
               //Blob headerValue = Blob.valueof(calloutData.UserName__c+':'+calloutData.UserPassword__c);
                
               //String authorizationValue = 'Basic '+EncodingUtil.base64Encode(headerValue);
               req.setHeader('Content-Type','application/x-www-form-urlencoded');
                
               
               System.debug('Req------------>>'+req);
                  
               
               String body;    
               /*
               body = //'client_id=74a605bc-d920-42c6-aaf1-2a8ebec971ca&'+ 
                          
                                   'client_id='+calloutData.UserName__c+'&'+ 
                       
                                   'client_secret='+calloutData.UserPassword__c+'&'+ 
                                   //'client_secret=uoy8Q~V9wlhgXhdDZr5YQOCumjBJGJ0pqKbq6abm&'+
                                   'resource=https://graph.microsoft.com&'+ 
                                    'grant_type=password&'+
                                    'username=globalAdmin@v8w4f.onmicrosoft.com&'+
                                    'password=M4nj-nVwfN6x7Un';
               */
               body =              'client_id='+calloutData.clientId__c+'&'+                       
                                   'client_secret='+calloutData.clientSecret__c+'&'+ 
                                   'scope=https://graph.microsoft.com/.default&'+ 
                                   //'resource=https://graph.microsoft.com/&'+
                                   'grant_type=password&'+
                                   //'username=globalAdmin@v8w4f.onmicrosoft.com&'+
                                   //'password=M4nj-nVwfN6x7Un';
                                   
                                   'username='+calloutData.UserName__c+ '&'+
                                   'password='+calloutData.UserPassword__c;
                                    
                                    
               System.debug('Body------------>>'+body);
               //String ss = EncodingUtil.urlEncode(body, 'UTF-8');
                              
               req.setBody(body);                   
               HttpResponse res = http.send(req);
               
               Order updateOrd = new Order();
               // Add condition to verify the status code then process the rest else set status to failed in the Order
               if (res.getStatusCode() == 200) 
               {
               
                   System.debug('Res------------->> '+res.toString());
                   JSONParser jpar = JSON.createParser(res.getBody());
                   
                   String accessTokenString;
                   while(jpar.nextToken() != NULL){
                       System.debug('---->' + jpar.getText());
                       if((jpar.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar.getText() == 'access_token'){
                           jpar.nextToken();
                           accessTokenString = jpar.getText();
                           System.debug('accessTokenString ------------->>'+accessTokenString);
                       }
                           
                   }

                   
                   HttpRequest req2 = new HttpRequest();
                   req2.setEndpoint(calloutData.EndPointURL__c);
                   req2.setMethod('POST');
                   req2.setHeader('Content-Type', 'application/json');
                   //req2.setHeader('Content-Type', 'application/html');
                   req2.setHeader('Authorization','Bearer '+accessTokenString);
                   req2.setHeader('Accept', '*/*');
                   //req2.setHeader('Scopes','User.ReadWrite.All');
                   String body2; 
                   
                   /*
                   String opportunityString = 'Account Name : '+opp.Account.Name+
                                              +'<br/>'+' Opportunity Name : '+opp.name+
                                              +'<br/>'+' Opportunity amount : ' +opp.Amount+
                                              +'<br/>'+' Opportunity Type : ' +opp.Opportunity_Type__c+
                                              +'<br/>'+' Opportunity Subtype : ' +opp.Opportunity_Subtype__c+
                                              +'<br/>'+' Closed Won Reason : ' +opp.Closed_Won_Reason__c+
                                              +'<br/>'+' closed Won Comments : ' +opp.Closed_Comments__c;
                                              
                  
                   String opportunityString = 'Account Name : '+opp.Account.Name+
                                              +'\n'+' Opportunity Name : '+opp.name+
                                              +'\n'+' Opportunity amount : ' +opp.Amount+
                                              +'\n'+' Opportunity Type : ' +opp.Opportunity_Type__c+
                                              +'\n'+' Opportunity Subtype : ' +opp.Opportunity_Subtype__c+
                                              +'\n'+' Closed Won Reason : ' +opp.Closed_Won_Reason__c+
                                              +'\n'+' Closed Won Comments : ' +opp.Closed_Comments__c;
                                              
                                        
                   String opportunityString = 'Account Name : '+opp.Account.Name+
                                              +'\\n'+' Opportunity Name : '+opp.name+
                                              +'\\n'+' Opportunity amount : ' +opp.Amount+
                                              +'\\n'+' Opportunity Type : ' +opp.Opportunity_Type__c+
                                              +'\\n'+' Opportunity Subtype : ' +opp.Opportunity_Subtype__c+
                                              +'\\n'+' Closed Won Reason : ' +opp.Closed_Won_Reason__c+
                                              +'\\n'+' Closed Won Comments : ' +opp.Closed_Comments__c;                           
                   */
                    String baseUrl = URL.getOrgDomainUrl().toExternalForm();
                    baseUrl = baseUrl+'/'+OPP.id;
                    String opportunityString = '<b> '; 
                    
                    if (String.isNotBlank(opp.Expected_Services__c))
                            opportunityString = opportunityString + 'A '+ opp.Expected_Services__c;
                               
                            opportunityString = opportunityString+ ' Opportunity has just been closed won by '+ opp.Owner.Name+ '. Share your big Win with the team!</b>'+
                             
                            '<br> <b> Account Name : </b> '+opp.Account.Name+
                            '<br> <b> Opportunity Name :</b> '+opp.Name+
                            '<br> <b> Opportunity Type :</b> ' +opp.Opportunity_Type__c+
                            '<br> <b> Opportunity Subtype :</b> ' +opp.Opportunity_Subtype__c;
                    if (opp.Amount != null)                 
                              opportunityString = opportunityString+'<br><b> Opportunity amount :</b> ' +opp.Amount;
                    if (String.isNotBlank(opp.Closed_Won_Reason__c))  
                              opportunityString = opportunityString+'<br><b> Closed Won Reason :</b> ' +opp.Closed_Won_Reason__c;
                    if (String.isNotBlank(opp.Closed_Comments__c))          
                              opportunityString = opportunityString+'<br><b> Closed Won Comments :</b> ' +opp.Closed_Comments__c;
                              
                              opportunityString = opportunityString+'<br><b> Salesforce Link:</b> <a>'+baseUrl+'</a>';
                   
                   /*
                       body2 = '{ '+
                                  '"AccountName":"'+opp.Account.Name+'",' +
                                  '"We are successfully created the messagge in Test environment":"'+opp.Account.Name +'"'+
                                '}';
                    */            
                   
                       body2 = '{ "body" : { '+
                                 '"contentType" : "html",' +
                                 '"content" :"'+opportunityString+'" }'  +
                                '}';
                   
                   /*
                       body2 =  '{"from":{"user":{ "id":"81af5944-ac03-4768-abcc-b4c65f0a51f8","displayName":"Raju Cherukuri","userIdentityType":"aadUser"}},'+
                       
                               '"body" : { '+
                                 '"content" : "Hellow world" }'  +
                                '}';
             
             
                   
                   {
                           "from":{
                              "user":{
                                 "id":"81af5944-ac03-4768-abcc-b4c65f0a51f8",
                                 "displayName":"Raju Cherukuri",
                                 "userIdentityType":"aadUser"
                              }
                           },
                           "body":{
                              "contentType":"html",
                              "content":"Hello World"
                           }
                        }
                        */
                   
                   boolean syncFailed = false;
                   String eventString ;
                   String statusSyncMessage;
                   String successCancelStatus;
                   String successTeamArchiveStatus;
                                 
                   System.debug('Body2------------->> '+body2);
                   req2.setBody(body2);
                   HttpResponse res2 = http.send(req2);
                    
                   System.debug('Res2------------->> '+res2.toString());
                   
                   if (res.getStatusCode() == 200 || res.getStatusCode() == 201) 
                   {
                       Opportunity op = [select id,Processed_For_MSTeams_ClosedWon__c from Opportunity where id = :opp.id];
                       op.Processed_For_MSTeams_ClosedWon__c=true;
                       opportunityList.add(op);
                   }  
                   JSONParser jpar2 = JSON.createParser(res2.getBody());
                   
                   /*
                   while(jpar2.nextToken() != NULL){
                       System.debug('---->' + jpar2.getText());
                       
                       if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'message'){
                           jpar2.nextToken();
                           statusSyncMessage = jpar2.getText();
                           System.debug('message ------------->>'+statusSyncMessage);
                       }
                       if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'errorMessages'){
                           jpar2.nextToken();
                           jpar2.nextToken();
                           statusSyncMessage = jpar2.getText();
                           System.debug('errorMsg---------->>'+statusSyncMessage);  
                       }
                       if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'status'){
                           jpar2.nextToken();
                           successCancelStatus = jpar2.getText();
                           System.debug('statusSyncMessage ------------->>'+statusSyncMessage);
                       }
                       if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'archiveStatus'){
                           jpar2.nextToken();
                           successTeamArchiveStatus = jpar2.getText();
                           System.debug('successTeamArchiveStatus ------------->>'+successTeamArchiveStatus);
                       }           
                           
                   }
                   System.debug('String.isNotBlank(statusSyncMessage)---------->>'+String.isNotBlank(statusSyncMessage));
                   if(String.isNotBlank(statusSyncMessage) || String.isNotBlank(successTeamArchiveStatus))
                   {
                       
                       System.debug('inside upate order ---------->>1');
                       updateOrd =  [Select Id, StatusSyncMessage__c from Order where Id = :ord.Id];
                       
                       if(String.isNotBlank(statusSyncMessage)){
                           updateOrd.StatusSyncMessage__c = statusSyncMessage;
                           updateOrd.CancelledStatusProcessedForOEC__c = true;
                       }
                       if(String.isNotBlank(successTeamArchiveStatus)){
                           updateOrd.Team_Archive_Message__c = successTeamArchiveStatus;
                           updateOrd.Processed_For_Archive__c = true;
                       }
                       update updateOrd; 
                       System.debug('inside upate order ---------->>2: Order Id'+updateOrd.Id);
                       
                       
                   }

                    */
              }

          }
        } 
        
        update opportunityList; 
          
    }
    

}