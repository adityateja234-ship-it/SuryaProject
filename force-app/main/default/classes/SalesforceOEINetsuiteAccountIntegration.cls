// ************************************************************************************************//
//
//  Developer By : Nilesh Bharti 'Salesforce Consultant' (nilesh.bharti@openexc.com)
//  Created on : 12/09/2024
//  JIRA:- OEP-11091
//  
//  Last Modified on : 12/09/2024
//  
//  Description :
//  This Queueable send Account details to OEI when any of the new Record is created as 'Active Customer'.
//
// ************************************************************************************************ //

global class SalesforceOEINetsuiteAccountIntegration implements Queueable, Database.AllowsCallouts {
    
    static String apiEnvironment;
    static CalloutData__c calloutData;
    Set<Id> accountIds = new Set<Id>();
    
    public SalesforceOEINetsuiteAccountIntegration(Set<Id> accountIds) {
        this.accountIds = accountIds;
    }
    
    public void execute(QueueableContext context) {
        List<Account> accounts = [SELECT Id, Account_Status__c, CurrencyIsoCode, Name, Ghost_Update__c, Netsuite_External_Name__c,
                        billingAddressId__c, BillingCountry, BillingState, BillingStreet, BillingCity, BillingStateCode, BillingPostalCode,
                        BillingCountryCode, ParentId, shippingAddressId__c, ShippingCountry, ShippingState,
                        ShippingCountryCode, ShippingStateCode, ShippingCity, ShippingPostalCode, ShippingStreet
                        FROM Account WHERE Id IN :accountIds for Update];
        
        loadCalloutParams();
        System.debug('Callout parameters: ' + calloutData);
        
        Set<Id> parentIds = new Set<Id>();
        for (Account acc : accounts) if (acc.ParentId != null) parentIds.add(acc.ParentId);
        
        Map<Id, String> parentNetSuiteIds = new Map<Id, String>();
        if (!parentIds.isEmpty()) {
            for (Account p : [SELECT Id, Netsuite_External_Name__c FROM Account WHERE Id IN :parentIds]) {
                parentNetSuiteIds.put(p.Id, p.Netsuite_External_Name__c);
            }
        }
        
        for (Account acc : accounts) {
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
                
                String accountId = acc.Id;
                String account15Digits = accountId.substring(0, 15);
                
                String body = '{' +
                    '"externalId":"' + acc.Id + '",' +
                    '"externalId18Digits":"' + account15Digits + '",' +
                    '"companyName":"' + acc.Name + '",';
                
                body += '"parentId":"' + (acc.ParentId != null ? parentNetSuiteIds.get(acc.ParentId) : 'null') + '",';
                
                boolean addressbookAdded = false;
                
                //boolean hasBillingDetails = acc.billingAddressId__c == null;
                boolean hasBillingDetails = acc.BillingCountry != null || acc.BillingCity != null || acc.BillingStreet != null ||
                    acc.BillingState != null || acc.BillingPostalCode != null;
                
                //boolean hasShippingDetails = acc.shippingAddressId__c == null;
                boolean hasShippingDetails = acc.ShippingCountry != null || acc.ShippingCity != null || acc.ShippingStreet != null ||
                    acc.ShippingState != null || acc.ShippingPostalCode != null;
                
                if (hasBillingDetails || hasShippingDetails || !hasBillingDetails || !hasShippingDetails) {
                    body += '"addressBook":[';
                    
                    if (hasBillingDetails) {
                        body += '{' +
                            '"addressId":"' + acc.billingAddressId__c + '",' +
                            '"defaultBilling": true,' +
                            '"defaultShipping": false,' +
                            '"country":"' + acc.BillingCountryCode + '",' +
                            '"addr1":"' + stringProcessor(acc.BillingStreet) + '",' +
                            '"city":"' + acc.BillingCity + '",' +
                            '"state":"' + acc.BillingStateCode + '",' +
                            '"zip":"' + acc.BillingPostalCode + '"' +
                            '}';
                        addressbookAdded = true;
                    }else{
                        body += '{' +
                            '"addressId":"' + acc.billingAddressId__c + '",' +
                            '"defaultBilling": false,' +
                            '"defaultShipping": false,' +
                            '"country":"' + acc.BillingCountryCode + '",' +
                            '"addr1":"' + stringProcessor(acc.BillingStreet) + '",' +
                            '"city":"' + acc.BillingCity + '",' +
                            '"state":"' + acc.BillingStateCode + '",' +
                            '"zip":"' + acc.BillingPostalCode + '"' +
                            '}';
                        addressbookAdded = true;
                    }
                    
                    //if (hasBillingDetails && hasShippingDetails) {
                        body += ',';
                    //}
                    
                    if (hasShippingDetails) {
                        body += '{' +
                            '"addressId":"' + acc.shippingAddressId__c + '",' +
                            '"defaultBilling": false,' +
                            '"defaultShipping": true,' +
                            '"country":"' + acc.ShippingCountryCode + '",' +
                            '"addr1":"' + stringProcessor(acc.ShippingStreet) + '",' +
                            '"city":"' + acc.ShippingCity + '",' +
                            '"state":"' + acc.ShippingStateCode + '",' +
                            '"zip":"' + acc.ShippingPostalCode + '"' +
                            '}';
                        addressbookAdded = true;
                    }else{
                        body += '{' +
                            '"addressId":"' + acc.shippingAddressId__c + '",' +
                            '"defaultBilling": false,' +
                            '"defaultShipping": false,' +
                            '"country":"' + acc.ShippingCountryCode + '",' +
                            '"addr1":"' + stringProcessor(acc.ShippingStreet) + '",' +
                            '"city":"' + acc.ShippingCity + '",' +
                            '"state":"' + acc.ShippingStateCode + '",' +
                            '"zip":"' + acc.ShippingPostalCode + '"' +
                            '}';
                        addressbookAdded = true;
                    }
                    
                    if (addressbookAdded) {
                        body += ']';
                    }
                }
                
                body += '}';
                body = body.substring(0, body.length() - 1) + '}';
                
                System.debug('Request body for account creation: ' + body);
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
                    
                    System.debug('Account creation response status code: ' + res2.getStatusCode() + ' - ' + res2.getBody());
                    
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
                        
                        if(String.isNotBlank(acc.Id)){
                            updateAccount =  [Select Id, billingAddressId__c, shippingAddressId__c, Netsuite_External_Name__c, Ghost_Update__c,
                                              Netsuite_Creation_Message__c
                                              FROM Account where Id = :acc.Id];
                            
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
                                updateAccount.Netsuite_Creation_Message__c = 'Account Record Created Successfully.';
                                update updateAccount;
                            }
                        }
                    } else {
                        System.debug('Failed to create account :- ' + res2.getStatusCode() + ' - ' + res2.getStatus() + ' - ' + res2.getBody());
                        updateAccount = [SELECT Id, Netsuite_Creation_Message__c, Ghost_Update__c FROM Account WHERE Id =:acc.Id];
                        updateAccount.Netsuite_Creation_Message__c = 'Creation failed :- ' + res2.getBody();
                        update updateAccount;
                    }
                } catch (Exception e) {
                    System.debug('Something strange :- ' + e.getMessage());
                    updateAccount = [SELECT Id, Netsuite_Creation_Message__c FROM Account WHERE Id =:acc.Id];
                    updateAccount.Netsuite_Creation_Message__c = 'Something Wrong at Creation :- ' + errorMessage;
                    update updateAccount;
                }
            } else {
                updateAccount = [SELECT Id, Netsuite_Creation_Message__c, Ghost_Update__c FROM Account WHERE Id =:acc.Id];
                System.debug('Authentication failed :- ' + res.getStatusCode() + ' - ' + res.getStatus() + ' - ' + res.getBody());
                updateAccount.Netsuite_Creation_Message__c = 'Authentication failed at Creation :- ' + res.getBody();
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