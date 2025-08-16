public class OECOrderTeamsCreationQueueble implements Queueable, Database.AllowsCallouts {
    public List<Order> ordList ; 
    CalloutData__c calloutData;
    public OECOrderTeamsCreationQueueble(Set<ID> orderIDList, CalloutData__c teamscd){
        System.debug('ordList --------->>'+orderIDList);
        calloutData = teamscd;
        this.ordList = [SELECT id, Account_Legal_Entity__c,OE_Central_URL__c,Order_Process__c,OEC_Event_Name__c, Start_Date_Time__c, Region__c, OrderNumber, teams_created__c,Project_Manager__c,Project_Manager__r.Email , Project_Manager_2__c,Project_Manager_2__r.Email , AccountId, Business_Line__c, status,OECEventID__c, Account.Name from order where id in:orderIDList];
        System.debug('ordList --------->>'+ordList);
    }
    public void execute(QueueableContext context) {

        System.debug('------>> in Execute of OECOrderTeamsCreationQuable');   
        for(Order ord : ordList)
        {    
           
           System.debug('Order Details --->'+
                         'ID :'+ord.Id+
                         'Status :'+ord.Status  +
                         'Project Manager :'+ord.Project_Manager__c
           );
           
           if(ord.teams_created__c == 'Pending' ){
           
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
                   String managersString;
                   if(isManagersAttached(ord)){
                       managersString = getManagersString(ord);
                   }
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
                   req2.setHeader('Content-Type', 'application/json');
                   req2.setHeader('X-OEX-Int-Account-ID', calloutData.AccountId__c);
                   req2.setHeader('X-OEX-Int-Authorization',idTokenString);
                  
                   String body = '{ '+
                                  '"businessLine":"'+ord.Business_Line__c+'",'+
                                  '"eventName":"'+ord.OEC_Event_Name__c+'",'+ 
                                  '"oeNumber":"'+ord.OrderNumber+'",'+
                                  '"client":"'+ord.Account.Name+'",'+
                                  '"region":"'+ord.Region__c+'",'+
                                  '"oecCentralURL":"'+ord.OE_Central_URL__c+'",'+
                                  '"eventStartDate":"'+ord.Start_Date_Time__c+'",'+
                                  '"salesforceOrderId":"'+ord.Id+'",';
                                  
                               if(String.isNotBlank(ord.Account_Legal_Entity__c))   
                                  body = body +'"accountLegalEntity":"'+ord.Account_Legal_Entity__c+'"';
                               else    
                                  body = body +'"accountLegalEntity":"'+'Any'+'"';
 
                                  
                   if(String.isNotBlank(managersString))
                       body = body + ', "owners":['+managersString +']';
                   body = body + '}';
                                  
                            
                   boolean syncFailed = false;
                   String eventString ;
                   String teamCreationMessage;
                   String teamCreationErrorMessage;
                   String teamId;
                   
                                 
                   System.debug('Body------------->> '+Body);
                   req2.setBody(body);
                   HttpResponse res2 = http.send(req2);
                    
                   System.debug('Res2------------->> '+res2.toString());
                   JSONParser jpar2 = JSON.createParser(res2.getBody());
                   
                   
                   while(jpar2.nextToken() != NULL){
                       System.debug('---->' + jpar2.getText());
                       
                       if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'message'){
                           jpar2.nextToken();
                           teamCreationMessage = jpar2.getText();
                           System.debug('message ------------->>'+teamCreationMessage);
                       }
                       if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'errorMessages'){
                           jpar2.nextToken();
                           jpar2.nextToken();
                           teamCreationErrorMessage = jpar2.getText();
                           System.debug('errorMsg---------->>'+teamCreationMessage);
    
                        
                       }
                       if((jpar2.getCurrentToken() == JSONTOKEN.FIELD_NAME) && jpar2.getText() == 'teamId'){
                           jpar2.nextToken();
                           teamId = jpar2.getText();
                           System.debug('teamId---------->>'+teamId);
    
                        
                       }
                       
                           
                   }
                   if(String.isNotBlank(teamCreationErrorMessage) )
                   {
                       
                       updateOrd =  [Select Id, Team_Creation_Error_Message__c,Order_Process__c,teams_created__c from Order where Id = :ord.Id];
                       
                       updateOrd.Team_Creation_Error_Message__c = teamCreationErrorMessage;
                       updateOrd.teams_created__c = 'Failed';
                       updateOrd.Order_Process__c = 'ProcessForLasso';
                       update updateOrd; 
                       
                   }
                   else
                   {
                       updateOrd =  [Select Id,teams_created__c,Team_Creation_Error_Message__c,Order_Process__c from Order where Id = :ord.Id];
                       updateOrd.teams_created__c = 'Created';
                       updateOrd.Team_ID_Created__c = teamId;
                       updateOrd.Order_Process__c = 'ProcessForLasso';
                       if(String.isNotBlank(updateOrd.Team_Creation_Error_Message__c))
                           updateOrd.Team_Creation_Error_Message__c = '';

                       update updateOrd;
                   }
                    
              }

          }
        }  
    }
    
    private boolean isManagersAttached(Order ord){
        if( (String.isNotBlank(ord.Project_Manager__r.Email)) || (String.isNotBlank(ord.Project_Manager_2__r.Email)))
            return true;
        else return false;     
    }
    
    private String getManagersString(Order ord){
        String managersString ='';
        boolean projManager1Exist = false;
        if(String.isNotBlank(ord.Project_Manager__c)){
            System.debug('String.isNotBlank(ord.Project_Manager__c)----------------->>');
            managersString = '"'+ord.Project_Manager__r.Email+'"';
            projManager1Exist = true;
        }
        if (String.isNotBlank(ord.Project_Manager_2__c))
        {
            if (projManager1Exist){
                managersString = managersString+ ' , ';
            }
            managersString = managersString +'"' +ord.Project_Manager_2__r.Email+'"';
        
        }
        System.debug ('managersString ---------->>:'+managersString);
        return managersString;
    }
}