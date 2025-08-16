global class OECCombinedOrderStatusSyncQueueble implements Queueable, Database.AllowsCallouts{
    
    public List<Order> ordList;
    CalloutData__c calloutData ;
    
    global OECCombinedOrderStatusSyncQueueble(Set<ID> orderIDList, CalloutData__c cd){
        ordList = [SELECT id, AccountId, Business_Line__c, status,OECEventID__c, Lasso_Event_ID__c, CancelledStatusProcessedForOEC__c,Processed_For_Archive__c from order where id in:orderIDList];
        System.debug('orderIDList------>>'+orderIDList.size());
        calloutData = cd;
    }
    
    global void execute(QueueableContext BC) {
        
        System.debug('calloutData------>>'+calloutData);
        for(Order ord : ordList){
            
            System.debug('Order Details --->'+
                         'ID :'+ord.Id+
                         'Status :'+ord.Status+
                         'Processed_For_Archive__c:'+ord.Processed_For_Archive__c+
                         'CancelledStatusProcessedForOEC__c:'+ord.CancelledStatusProcessedForOEC__c+
                         'OECEventID__c:'+ord.OECEventID__c
                        );
            if(ord.status == 'Cancelled' || ord.status == 'Paid' || ord.status == 'Delivered' || ord.status == 'Awaiting Confirmation' || ord.status == 'Ready to Bill' || ord.status == 'Invoice Sent'){
                
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                
                req.setEndpoint(calloutData.AuthenticationURL__c);
                req.setMethod('POST');
                Blob headerValue = Blob.valueof(calloutData.UserName__c+':'+calloutData.UserPassword__c);
                String authorizationValue = 'Basic '+EncodingUtil.base64Encode(headerValue);
                req.setHeader('Authorization',authorizationValue);
                HttpResponse res = http.send(req);
                System.debug('Response for IDToken StatusCode ------------->> '+res.getStatusCode());
                Order updateOrd = new Order();
                
                if (res.getStatusCode() == 200) {
                    JSONParser jpar = JSON.createParser(res.getBody());
                    String idTokenString;
                    while(jpar.nextToken() != NULL){
                        if((jpar.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar.getText() == 'idToken'){
                            jpar.nextToken();
                            idTokenString = jpar.getText();
                            System.debug('idTokenString ------------->> '+idTokenString);
                        }
                    }
                    
                    HttpRequest req2 = new HttpRequest();
                    req2.setEndpoint(calloutData.EndPointURL__c);
                    req2.setMethod('POST');
                    req2.setHeader('Content-Type', 'application/json');
                    req2.setHeader('X-OEX-Int-Account-ID', calloutData.AccountId__c);
                    req2.setHeader('X-OEX-Int-Authorization',idTokenString);
                    req2.setTimeout(120000);
                    
                    String body;
                    String statusStr = getStatusString(ord);
                    body = '{ '+
                        '"businessLine":"'+ord.Business_Line__c+'",'+                                   
                        '"status":"'+ statusStr + 
                        '","subAccountId":"'+ord.AccountId+'"'+
                        ',"salesforceOrderId":"'+ord.Id+'"'+ 
                        ',"eventId":"'+ord.OECEventID__c+'"'+
                        ',"lassoEventId":"'+ord.Lasso_Event_ID__c+'"'+ 
                        '}';
                    
                    boolean syncFailed = false;
                    String eventString ;
                    String oecStatusSyncMessage;
                    String lassoStatusSyncMessage;
                    String archiveStatus;
                    String statusSyncMessage;
                    
                    System.debug('Body in Cancel Call------------------------------->>'+body);
                    
                    req2.setBody(body);
                    HttpResponse res2 = http.send(req2);
                    System.debug('Response for StatusCode ------------->> '+res2.getStatusCode());
                    System.debug('Response for Body ------------->> '+res2.getBody());
                    JSONParser jpar2 = JSON.createParser(res2.getBody());
                    
                    while(jpar2.nextToken() != NULL){
                        if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'oecStatus'){
                            jpar2.nextToken();
                            oecStatusSyncMessage = jpar2.getText();
                            System.debug('oecStatusSyncMessage ------------->>'+oecStatusSyncMessage);
                        }
                        if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'errorMessages'){
                            jpar2.nextToken();
                            jpar2.nextToken();
                            statusSyncMessage = jpar2.getText();
                            System.debug('errorMsg---------->>'+statusSyncMessage);  
                        }
                        if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'lassoStatus'){
                            jpar2.nextToken();
                            lassoStatusSyncMessage = jpar2.getText();
                            System.debug('lassoStatusSyncMessage ------------->>'+lassoStatusSyncMessage);
                        } 
                        if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'teamsStatus'){
                            jpar2.nextToken();
                            archiveStatus = jpar2.getText();
                            System.debug('archiveStatus ------------->>'+archiveStatus);
                        }
                    }
                    
                    if(String.isNotBlank(oecStatusSyncMessage) || String.isNotBlank(lassoStatusSyncMessage) || String.isNotBlank(archiveStatus)){
                        updateOrd =  [SELECT Id, StatusSyncMessage__c, CancelledStatusProcessedForOEC__c, Sync_Datetime__c,
                                      Lasso_Cancel_Sync_Status__c, CancelledStatusProcessedForLasso__c, Lasso_Sync_Datetime__c,
                                      Team_Archive_Message__c, Processed_For_Archive__c
                                      FROM Order WHERE Id = :ord.Id];
                        String statusString;
                        if (res2.getStatusCode() == 200) {
                            if(String.isNotBlank(oecStatusSyncMessage) && oecStatusSyncMessage != 'null' ){
                                updateOrd.StatusSyncMessage__c = oecStatusSyncMessage;
                                updateOrd.CancelledStatusProcessedForOEC__c = true;
                                updateOrd.Sync_Datetime__c = System.now();
                            }
                            if(String.isNotBlank(lassoStatusSyncMessage)  && lassoStatusSyncMessage != 'null' ){
                                updateOrd.Lasso_Cancel_Sync_Status__c = lassoStatusSyncMessage;
                                updateOrd.CancelledStatusProcessedForLasso__c = true;
                                updateOrd.Lasso_Sync_Datetime__c = System.now();
                            }
                            if(String.isNotBlank(archiveStatus) && archiveStatus != 'null'){
                                updateOrd.Team_Archive_Message__c = archiveStatus;
                                updateOrd.Processed_For_Archive__c = true;
                            }
                        }
                        else{
                            System.debug('Other than 200-----------------------');
                            updateOrd.StatusSyncMessage__c = statusSyncMessage;
                            updateOrd.Lasso_Cancel_Sync_Status__c = statusSyncMessage;
                            updateOrd.Team_Archive_Message__c = statusSyncMessage;
                        }
                        update updateOrd;
                    }
                }
            }
        }
    }
    
    public String getStatusString(Order ord){
        if (ord.status == 'Cancelled')
            return 'CANCELLED';
        else if(ord.status == 'Invoice Sent')
            return 'INVOICE_SENT';
        else if(ord.status == 'Ready to Bill')
            return 'READY_TO_BILL';
        else if(ord.status == 'Paid')
            return 'PAID';
        else if(ord.status == 'Awaiting Confirmation')
            return 'AWAITING_CONFIRMATION';
        else
            return 'DELIVERED';
    }
}