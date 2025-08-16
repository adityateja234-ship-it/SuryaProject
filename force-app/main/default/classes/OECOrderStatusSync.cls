global class OECOrderStatusSync implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    Map<id,Order> IdOrderMapBatch=new Map<id,Order>();
    public String accessToken;
    CalloutData__c calloutData ;
    Contact pm;
    Contact coPM;
    private static String GMTTimeZone = 'UTC';   
    global OECOrderStatusSync(Map<id,Order> IdOrderMap, CalloutData__c cd){ 
        
        System.debug('------>> in constructor');
        IdOrderMapBatch=IdOrderMap;
        calloutData=cd;

    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('------>> in QueryLocator');
        return Database.getQueryLocator([SELECT id, AccountId, Business_Line__c, status,OECEventID__c,CancelledStatusProcessedForOEC__c from order where status = 'Cancelled' and id in:IdOrderMapBatch.keySet()]);
    }
    
    global void execute(Database.BatchableContext BC, List<Order> scope) { 
           
        System.debug('------>> in Execute');   
        for(Order ord : scope)
        {    
           
           System.debug('Order Details --->'+
                         'ID :'+ord.Id+
                         'Status :'+ord.Status  
           );
           
           if(String.isNotBlank(ord.OECEventID__c) && !ord.CancelledStatusProcessedForOEC__c ){
           
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
                   req2.setEndpoint(replaceDynamic(ord.OECEventID__c, calloutData.EndPointURL__c));
                   req2.setMethod('PATCH');
                   //req2.setHeader('Accept', 'application/json');
                   req2.setHeader('Content-Type', 'application/json');
                   //req2.setHeader('X-OEX-SF-Account-ID', ord.AccountId);
                   //req2.setHeader('X-OEX-SF-Account-ID', '0010200000HiGGx');// '0010200000Lz27DAAR');
                   req2.setHeader('X-OEX-Int-Account-ID', calloutData.AccountId__c);
                   req2.setHeader('X-OEX-Int-Authorization',idTokenString);
                  
                   String body = '{ '+
                                  '"businessLine":"'+ord.Business_Line__c+'",'+ 
                                   '"status":"'+'CANCELLED'+ 
                                   '","subAccountId":"'+ord.AccountId+'"'+ 
                                  '}';
                                  
                            
                   boolean syncFailed = false;
                   String eventString ;
                   String statusSyncMessage;
                                 
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
                       
                           
                   }
                   if(String.isNotBlank(statusSyncMessage) )
                   {
                       
                       updateOrd =  [Select Id, StatusSyncMessage__c from Order where Id = :ord.Id];
                       updateOrd.StatusSyncMessage__c = statusSyncMessage;
                       updateOrd.CancelledStatusProcessedForOEC__c = true;
                       update updateOrd; 
                       
                   }
                    
              }

          }
        }  
          
    }
    
    public String replaceDynamic(String oecEventId, String endpointURL){
        String target = '{eventId}';
        String finalEndpoint =  endpointURL.replace(target, oecEventId);
        System.debug('finalEndpoint ------------------>>> '+finalEndpoint);
        return finalEndpoint;
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
    global void getAccessToken(String outBoundCallName){
    
        //select 
        
    }
       

}