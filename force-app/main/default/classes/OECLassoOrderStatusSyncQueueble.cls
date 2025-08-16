global class OECLassoOrderStatusSyncQueueble implements Queueable, Database.AllowsCallouts
{
    
    public List<Order> ordList;
    CalloutData__c calloutData ;
  
    global OECLassoOrderStatusSyncQueueble(Set<ID> orderIDList, CalloutData__c cd){ 
        
        System.debug('------>> in OECLassoOrderStatusSyncQueueble constructor');
        ordList = [SELECT id, AccountId, Business_Line__c, status,Lasso_Event_ID__c,CancelledStatusProcessedForLasso__c,Processed_For_Archive__c from order where status = 'Cancelled' and id in:orderIDList];
        
        System.debug('orderIDList------>>'+orderIDList.size());
        calloutData=cd;

    }

    global void execute(QueueableContext BC) { 
           
        System.debug('------>> in Execute of OECLassoOrderStatusSyncQueueble');   
        for(Order ord : ordList)
        {    
           
           System.debug('Order Details --->'+
                         'ID :'+ord.Id+
                         'Status :'+ord.Status+
                         'Processed_For_Archive__c:'+ord.Processed_For_Archive__c+
                         'CancelledStatusProcessedForLasso__c:'+ord.CancelledStatusProcessedForLasso__c+
                         'Lasso_Event_ID__c:'+ord.Lasso_Event_ID__c
           );
           
           if(String.isNotBlank(ord.Lasso_Event_ID__c) && !ord.CancelledStatusProcessedForLasso__c && ord.status == 'Cancelled') 
           {
           
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
                   req2.setEndpoint(replaceDynamic(ord.Lasso_Event_ID__c, calloutData.EndPointURL__c));
                   req2.setMethod('PUT');
                   //req2.setHeader('Accept', 'application/json');
                   req2.setHeader('Content-Type', 'application/json');
                   //req2.setHeader('X-OEX-SF-Account-ID', ord.AccountId);
                   //req2.setHeader('X-OEX-SF-Account-ID', '0010200000HiGGx');// '0010200000Lz27DAAR');
                   req2.setHeader('X-OEX-Int-Account-ID', calloutData.AccountId__c);
                   req2.setHeader('X-OEX-Int-Authorization',idTokenString);
                   String body; 
                   
                   body = '{ '+
                                   '"status":"'+'canceled"'+ 
                                   ',"salesforceOrderId":"'+ord.Id+'"'+ 
                                  '}';

                          
                   boolean syncFailed = false;
                   String eventString ;
                   String statusSyncMessage;
                   String successCancelStatus;
                   String archiveStatus;
                   //String successTeamArchiveStatus;
                                 
                   System.debug('Body------------->> '+Body);
                   req2.setBody(body);
                   HttpResponse res2 = http.send(req2);
                    
                   System.debug('Res2------------->> '+res2.toString());
                   JSONParser jpar2 = JSON.createParser(res2.getBody());
                   
                   
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
                           System.debug('successCancelStatus ------------->>'+successCancelStatus);
                       } 
                       if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'archiveStatus'){
                           jpar2.nextToken();
                           archiveStatus = jpar2.getText();
                           System.debug('archiveStatus ------------->>'+archiveStatus);
                       }      
                           
                           
                   }
                   System.debug('String.isNotBlank(statusSyncMessage)---------->>'+String.isNotBlank(statusSyncMessage));
                   if(String.isNotBlank(statusSyncMessage) || String.isNotBlank(successCancelStatus))
                   {
                       System.debug('inside upate order ---------->>1');
                       updateOrd =  [Select Id, StatusSyncMessage__c from Order where Id = :ord.Id];
                       
                       if(String.isNotBlank(statusSyncMessage) ){
                           updateOrd.Lasso_Cancel_Sync_Status__c = statusSyncMessage;
                           updateOrd.CancelledStatusProcessedForLasso__c = true;
                           updateOrd.Lasso_Sync_Datetime__c = System.now();
                       }
                       if (String.isNotBlank(successCancelStatus)){
                           updateOrd.Lasso_Cancel_Sync_Status__c = successCancelStatus;
                           updateOrd.CancelledStatusProcessedForLasso__c = true;
                           updateOrd.Lasso_Sync_Datetime__c = System.now();
                       }
                       if (String.isNotBlank(archiveStatus)) {
                            updateOrd.Team_Archive_Message__c = archiveStatus;
                            updateOrd.CancelledStatusProcessedForLasso__c = true;
                            updateOrd.Lasso_Sync_Datetime__c = System.now();
                            
                       }
                       update updateOrd; 
                       System.debug('inside OECLassoOrderStatusSyncQueueble order ---------->>2: Order Id'+updateOrd.Id);
                   }
                    
              }

          }
        }  
          
    }

    public String replaceDynamic(String LassoEventID, String endpointURL){
        String target = '{eventId}';
        String finalEndpoint =  endpointURL.replace(target, LassoEventID);
        System.debug('finalEndpoint ------------------>>> '+finalEndpoint);
        return finalEndpoint;
    }
       

}