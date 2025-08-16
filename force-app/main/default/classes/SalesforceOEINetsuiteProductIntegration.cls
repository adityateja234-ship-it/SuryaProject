// ************************************************************************************************//
//
//  Developer By : Nilesh Bharti 'Salesforce Consultant' (nilesh.bharti@openexc.com)
//  Created on : 08/10/2024
//  JIRA:- OEP-11872
//  
//  Last Modified on : 08/10/2024
//  
//  Description : 
//  When create new Product in Salesforce this Queueable send details to OEI.
//  
// ***********************************************************************************************//

global class SalesforceOEINetsuiteProductIntegration implements Queueable, Database.AllowsCallouts {
    
    static String apiEnvironment;
    static CalloutData__c calloutData;
    Set<Id> productIds = new Set<Id>();
    
    public SalesforceOEINetsuiteProductIntegration(Set<Id> productIds) {
        this.productIds = productIds;
    }
    
    public void execute(QueueableContext context) {
        
        List<Product2> prdList = [SELECT Id, Name, Description, Family, Sub_Product_Family__c, OE_Product_Name__c, Product_Ticket_Number__c,
                                  Product_Legal_Entity__c, IsActive, Revenue_Recognition_Rule__c, Rev_Rec_Forecast_Rule__c, Netsuite_Id__c
                                  FROM Product2 WHERE Id =:productIds for Update];
        System.debug('Product retrieved for create: ' + prdList);
        
        loadCalloutParams();
        System.debug('Callout parameters: ' + calloutData);
        
        for(Product2 prd : prdList){
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(calloutData.AuthenticationURL__c);
            req.setMethod('POST');
            
            Blob headerValue = Blob.valueOf(calloutData.UserName__c + ':' + calloutData.UserPassword__c);
            String authorizationValue = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationValue);
            
            HttpResponse res;
            String idTokenString = '';
            Product2 updateProduct = new Product2();
            
            DateTime startTime1 = System.now();
            res = http.send(req);
            DateTime endTime1 = System.now();
            Long timeTakenMillis1 = endTime1.getTime() - startTime1.getTime();
            Long timeTakenSeconds1 = timeTakenMillis1 / 1000;
            
            System.debug('Total time taken: ' + timeTakenSeconds1 + ' seconds');
            
            res = http.send(req);
            System.debug('Authentication response status code: ' + res.getStatusCode());
            
            if (res.getStatusCode() == 200) {
                
                Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                
                if (tokenResponse.get('idToken') != null) {
                    idTokenString = (String)tokenResponse.get('idToken');
                } else{
                    System.debug('Authentication token not found in response.');
                }
                
                HttpRequest req2 = new HttpRequest();
                req2.setEndpoint(calloutData.EndPointURL__c);
                req2.setMethod('POST');
                req2.setHeader('Content-Type', 'application/json');
                req2.setHeader('X-OEX-Int-Account-ID', calloutData.AccountId__c);
                req2.setHeader('X-OEX-Int-Authorization', idTokenString);
                req2.setTimeout(120000);
                
                String productDescription;
                if(String.isNotblank(prd.Description))
                	productDescription = stringProcessor(prd.Description);
                else
                    productDescription = 'null';
                
                String body = '{' +
                    '"itemId":"' + prd.OE_Product_Name__c + '",' +
                    '"displayName":"' + prd.Name + '",' +
                    '"custItem1":"' + prd.Family + '",' +
                    '"salesDescription":"' + productDescription + '",' +
                    '"revenueRecognitionRule":' + (prd.Revenue_Recognition_Rule__c == 'OE Immediate' ? '"4"' : '"3"') + ',' +
                    '"revRecForecastRule":' + (prd.Rev_Rec_Forecast_Rule__c == 'OE Immediate' ? '"4"' : '"3"') + ',' +
                    '"externalId":"' + prd.Id + '",';
                
                if(prd.IsActive == true){
                    body += '"inactive": false';
                }else{
                    body += '"inactive": true';
                }
                
                body += '}';
                
                body = body.substring(0, body.length() - 1) + '}';
                System.debug('Request body for Product Updation: ' + body);
                
                req2.setBody(body);
                String netsuitId;
                String errorMessage;
                
                HttpResponse res2;
                try {
                    DateTime startTime = System.now();
                    res2 = http.send(req2);
                    DateTime endTime = System.now();
                    Long timeTakenMillis = endTime.getTime() - startTime.getTime();
                    Long timeTakenSeconds = timeTakenMillis / 1000;
                    
                    System.debug('Total time taken: ' + timeTakenSeconds + ' seconds');
                    
                    System.debug('Product creation response status code: ' + res2.getStatusCode() + ' - ' + res2.getBody());
                    
                    Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res2.getBody());
                    
                    Map<String, Object> data;
                    Map<String, Object> error;
                    if(jsonResponse.containsKey('data')){
                        data = (Map<String, Object>) jsonResponse.get('data');
                    }
                    else if(jsonResponse.containsKey('error')){
                        error = (Map<String, Object>) jsonResponse.get('error');
                        errorMessage = (String)error.get('message');
                    }
                    else{
                        errorMessage = res2.getBody();
                    }
                    
                    if (res2.getStatusCode() == 200 && data.get('internalId') != null) {
                        
                        if(data.containsKey('internalId')){
                            netsuitId = (String)data.get('internalId');
                            System.debug('netsuitId------------------------------->>'+netsuitId);
                        }
                        
                        if(String.isNotBlank(prd.Id)){
                            updateProduct =  [Select Id, Ghost_Update__c, Netsuite_Id__c
                                              FROM Product2 where Id = :prd.Id];
                            
                            if(String.isNotBlank(netsuitId)){
                                System.debug('isNotBlank(netsuitId) =========>'+netsuitId);
                                updateProduct.Netsuite_Id__c = netsuitId;
                            }
                            if(updateProduct != null){
                                updateProduct.Netsuite_Creation_Message__c = 'Product Record Created Successfully.';
                                update updateProduct;
                            }
                        }
                    } else {
                        System.debug('Failed to create product :- ' + res2.getStatusCode() + ' - ' + res2.getStatus() + ' - ' + res2.getBody());
                        updateProduct = [SELECT Id, Netsuite_Creation_Message__c, Ghost_Update__c FROM Product2 WHERE Id = :prd.Id];
                        updateProduct.Netsuite_Creation_Message__c = 'Creation failed :- ' + res2.getBody();
                        update updateProduct;
                    }
                } catch (Exception e) {
                    System.debug('Something strange :- ' + e.getMessage());
                    updateProduct = [SELECT Id, Netsuite_Creation_Message__c, Ghost_Update__c FROM Product2 WHERE Id = :prd.Id];
                    updateProduct.Netsuite_Creation_Message__c = 'Something Wrong at Creation :- ' + errorMessage;
                    update updateProduct;
                    //throw new AuraHandledException(e.getMessage());
                }
            } else {
                System.debug('Authentication failed :- ' + res.getStatusCode() + ' - ' + res.getStatus() + ' - ' + res.getBody());
                updateProduct = [SELECT Id, Netsuite_Creation_Message__c, Ghost_Update__c FROM Product2 WHERE Id = :prd.Id];
                updateProduct.Netsuite_Creation_Message__c = 'Authentication failed at Creation :- ' + res.getBody();
                update updateProduct;
            }
        }
    }
    
    public static String stringProcessor(String description) {
        
        //System.debug('description description description ::::::: ' + description);
        // Replace newlines (both \n and \r) with a custom separator (e.g., " <p> ")
        //description = description.replaceAll('[\\r\\n]+', ' *newline* ');
        description = description.replaceAll('[\\r\\n]+', ' ');
        description = description.replaceAll('\\\\', ' ');  // Remove any literal backslash '\'
        description = description.replaceAll('\"', ' ');    // Remove double quotes '\"'
        //System.debug('description ::::::: ' + description);
        return description;
        
    }
    
    public static void loadCalloutParams() {
        
        Integration_Configuration__mdt ic = [SELECT API_Environment__c from Integration_Configuration__mdt];
        apiEnvironment = ic.API_Environment__c;
        
        if (apiEnvironment == 'QA'){
            System.debug('Inside QA apiEnvironment');
            OECCallOuts__mdt callouts = [SELECT QAAccountId__c, QAAuthURL__c, QACreateProductEndpointURL__c, QAPassword__c, QAUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            calloutData = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QACreateProductEndpointURL__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);             
        }
        else if (apiEnvironment == 'Prod'){
            OECCallOuts__mdt callouts = [SELECT ProdAccountId__c, ProdAuthURL__c, ProductionCreateProductEndpointURL__c, ProdPassword__c, ProdUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            calloutData = new CalloutData__c(AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProductionCreateProductEndpointURL__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);              
        }
        else {
            OECCallOuts__mdt callouts = [SELECT DevAccountId__c, DevAuthURL__c, StageCreateProductEndpointURL__c, DevPassword__c, DevUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            calloutData = new CalloutData__c(AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.StageCreateProductEndpointURL__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
        }
    }
    
}