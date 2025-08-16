// ************************************************************************************************//
//
//  Developer By : Nilesh Bharti 'Salesforce Consultant' (nilesh.bharti@openexc.com)
//  Created on : 13/09/2024
//  JIRA:- OEP-11091
//  
//  Last Modified on : 13/09/2024
//  OEP-11992
//  
//  Description :
//  This Queueable send Account details to OEI when some fields are modified and status will be 'Active Customer'.
//
// ************************************************************************************************ //

global class SalesforceOEINetsuiteAccountIntegration2 implements Queueable, Database.AllowsCallouts{
    
    static String apiEnvironment;
    static CalloutData__c calloutData;
    Set<Id> accountIds = new Set<Id>();                
    
    public SalesforceOEINetsuiteAccountIntegration2(Set<Id> accountIds) {
        this.accountIds = accountIds;
    }
    
    public void execute(QueueableContext context){
        
        List<Account> oldAccount = [SELECT Id, Account_Status__c, CurrencyIsoCode, Name, Ghost_Update__c, Netsuite_External_Name__c, Netsuite_Creation_Message__c,
                      billingAddressId__c,BillingCountry, BillingState, BillingStreet, BillingCity, BillingStateCode, BillingPostalCode,
                      BillingCountryCode, ParentId, ShippingCountry, ShippingState, shippingAddressId__c, 
                      ShippingCountryCode, ShippingStateCode, ShippingCity, 
                      ShippingPostalCode, ShippingStreet
                      FROM Account WHERE Id IN :accountIds for Update];
        
        loadCalloutParams();
        System.debug('Callout parameters: ' + calloutData);
        
        Set<Id> parentIds = new Set<Id>();
        for (Account acc : oldAccount) if (acc.ParentId != null) parentIds.add(acc.ParentId);
        
        Map<Id, String> parentNetSuiteIds = new Map<Id, String>();
        if (!parentIds.isEmpty()) {
            for (Account p : [SELECT Id, Netsuite_External_Name__c FROM Account WHERE Id IN :parentIds]) {
                parentNetSuiteIds.put(p.Id, p.Netsuite_External_Name__c);
            }
        }        
        
        for (Account accId : oldAccount) {
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(calloutData.AuthenticationURL__c);
            req.setMethod('POST');
            
            Blob headerValue = Blob.valueOf(calloutData.UserName__c + ':' + calloutData.UserPassword__c);
            String authorizationValue = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationValue);
            
            HttpResponse res;
            String idTokenString = '';
            Account updateAccount = new Account();
            res = http.send(req);
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
                
                String accountId = accId.Id;
                String account15Digits = accountId.substring(0, 15);
                String body = '{' +
                    '"externalId":"'+ accId.Id +'",' +
                    '"externalId18Digits":"'+ account15Digits +'",' +
                    '"companyName":"'+ accId.Name +'",';
                
                body += '"parentId":"' + (accId.ParentId != null ? parentNetSuiteIds.get(accId.ParentId) : 'null') + '",';
                
                boolean addressbookAdded = false;
                
                //boolean hasBillingDetails = accId.billingAddressId__c != null;
                boolean hasBillingDetails = accId.BillingCountry != null || accId.BillingCity != null || accId.BillingStreet != null ||
                    accId.BillingState != null || accId.BillingPostalCode != null;
                
                //boolean hasShippingDetails = accId.shippingAddressId__c != null;
                boolean hasShippingDetails = accId.ShippingCountry != null || accId.ShippingCity != null || accId.ShippingStreet != null ||
                    accId.ShippingState != null || accId.ShippingPostalCode != null;
                
                if (hasBillingDetails || hasShippingDetails || !hasBillingDetails || !hasShippingDetails) {
                    body += '"addressBook":[';
                    
                    if (hasBillingDetails) {
                        body += '{' +
                            '"addressId":"' + accId.billingAddressId__c + '",' +
                            '"defaultBilling": true,' +
                            '"defaultShipping": false,' +
                            '"country":"' + accId.BillingCountryCode + '",' +
                            '"addr1":"' + stringProcessor(accId.BillingStreet) + '",' +
                            '"city":"' + accId.BillingCity + '",' +
                            '"state":"' + accId.BillingStateCode + '",' +
                            '"zip":"' + accId.BillingPostalCode + '"' +
                            '}';
                        addressbookAdded = true;
                    }else{
                        body += '{' +
                            '"addressId":"' + accId.billingAddressId__c + '",' +
                            '"defaultBilling": false,' +
                            '"defaultShipping": false,' +
                            '"country":"' + accId.BillingCountryCode + '",' +
                            '"addr1":"' + stringProcessor(accId.BillingStreet) + '",' +
                            '"city":"' + accId.BillingCity + '",' +
                            '"state":"' + accId.BillingStateCode + '",' +
                            '"zip":"' + accId.BillingPostalCode + '"' +
                            
                            '}';
                        addressbookAdded = true;
                    }
                    
                    body += ',';
                    
                    if (hasShippingDetails) {
                        body += '{' +
                            '"addressId":"' + accId.shippingAddressId__c + '",' +
                            '"defaultBilling": false,' +
                            '"defaultShipping": true,' +
                            '"country":"' + accId.ShippingCountryCode + '",' +
                            '"addr1":"' + stringProcessor(accId.ShippingStreet) + '",' +
                            '"city":"' + accId.ShippingCity + '",' +
                            '"state":"' + accId.ShippingStateCode + '",' +
                            '"zip":"' + accId.ShippingPostalCode + '"' +                            
                            '}';
                        addressbookAdded = true;
                    }else{
                        body += '{' +
                            '"addressId":"' + accId.shippingAddressId__c + '",' +
                            '"defaultBilling": false,' +
                            '"defaultShipping": false,' +
                            '"country":"' + accId.ShippingCountryCode + '",' +
                            '"addr1":"' + stringProcessor(accId.ShippingStreet) + '",' +
                            '"city":"' + accId.ShippingCity + '",' +
                            '"state":"' + accId.ShippingStateCode + '",' +
                            '"zip":"' + accId.ShippingPostalCode + '"' +
                            '}';
                        addressbookAdded = true;
                    }
                    
                    if (addressbookAdded) {
                        body += ']';
                    }
                }
                
                body += '}';
                
                body = body.substring(0, body.length() - 1) + '}';
                System.debug('Request body for account updation: ' + body);
                req2.setBody(body);
                String shippingAddressId;
                String billingAddressId;
                String netsuitId;
                String errorMessage;
                
                HttpResponse res2;
                try {
                    DateTime startTime = System.now();
                    res2 = http.send(req2);
                    DateTime endTime = System.now();
                    
                    // Calculate the time difference in milliseconds
                    Long timeTakenMillis = endTime.getTime() - startTime.getTime();
                    Long timeTakenSeconds = timeTakenMillis / 1000;
                    
                    System.debug('Total time taken: ' + timeTakenSeconds + ' seconds');
                    
                    System.debug('Response Status Code: ' + res2.getStatusCode() + ' - ' + res2.getBody());
                    
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
                        
                        if(data.containsKey('shippingAddressId')){
                            shippingAddressId = (String)data.get('shippingAddressId');
                        }
                        
                        if(data.containsKey('billingAddressId')){
                            billingAddressId = (String)data.get('billingAddressId');
                        }
                        if(data.containsKey('internalId')){
                            netsuitId = (String)data.get('internalId');
                        }
                        
                        if(String.isNotBlank(accId.Id)){
                            updateAccount =  [Select Id, billingAddressId__c, shippingAddressId__c, Netsuite_External_Name__c, Ghost_Update__c
                                              FROM Account where Id = :accId.Id];
                            
                            if(String.isNotBlank(shippingAddressId)){
                                updateAccount.shippingAddressId__c = shippingAddressId;
                            }
                            if(String.isNotBlank(billingAddressId)){
                                updateAccount.billingAddressId__c = billingAddressId;
                            }
                            if(String.isNotBlank(netsuitId)){
                                updateAccount.Netsuite_External_Name__c = netsuitId;
                            }
                            if(updateAccount != null){
                                updateAccount.Netsuite_Creation_Message__c = 'Account Record Updated Successfully.';
                                update updateAccount;
                            }
                        }
                    } else {
                        System.debug('Failed to update account :- ' + res2.getStatusCode() + ' - ' + res2.getStatus() + ' - ' + res2.getBody());
                        updateAccount = [SELECT Id, Netsuite_Creation_Message__c FROM Account WHERE Id =:accId.Id];
                        updateAccount.Netsuite_Creation_Message__c = 'Updation failed :- ' + res2.getBody();
                        update updateAccount;
                    }
                } catch (Exception e) {
                    System.debug('Something strange :- ' + e.getMessage());
                    updateAccount = [SELECT Id, Netsuite_Creation_Message__c FROM Account WHERE Id =:accId.Id];
                    updateAccount.Netsuite_Creation_Message__c = 'Something Wrong at Updation :- ' + errorMessage;
                    update updateAccount;
                }
            } else {
                System.debug('Authentication failed: ' + res.getStatusCode() + ' - ' + res.getStatus() + ' - ' + res.getBody());
                updateAccount = [SELECT Id, Netsuite_Creation_Message__c FROM Account WHERE Id =:accId.Id];
                updateAccount.Netsuite_Creation_Message__c = 'Authentication failed at Updation :- ' + res.getBody();
                update updateAccount;
            }
        }
    }
    
    public static String stringProcessor(String description) {
        if (String.isEmpty(description)) return 'null';
        description = description.replaceAll('[\\r\\n]+', ' ');
        description = description.replaceAll('\\\\', ' ');  // Remove any literal backslash '\'
        description = description.replaceAll('\"', ' ');    // Remove double quotes '\"'
        return description;
    }
    
    public static void loadCalloutParams() {
        
        Integration_Configuration__mdt ic = [SELECT API_Environment__c from Integration_Configuration__mdt];
        apiEnvironment = ic.API_Environment__c;
        
        if (apiEnvironment == 'QA'){
            OECCallOuts__mdt callouts = [SELECT QAAccountId__c, QAAuthURL__c, QACreateAccountEndpointURL__c, QAPassword__c, QAUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            calloutData = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QACreateAccountEndpointURL__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);             
        }
        else if (apiEnvironment == 'Prod'){
            OECCallOuts__mdt callouts = [SELECT ProdAccountId__c, ProdAuthURL__c, ProductionCreateAccountEndpointURL__c, ProdPassword__c, ProdUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            calloutData = new CalloutData__c(AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProductionCreateAccountEndpointURL__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);              
        }
        else {
            OECCallOuts__mdt callouts = [SELECT DevAccountId__c, DevAuthURL__c, StageCreateAccountEndpointURL__c, DevPassword__c, DevUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            calloutData = new CalloutData__c(AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.StageCreateAccountEndpointURL__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
        }
    }
    
}