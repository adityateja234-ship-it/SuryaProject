// ************************************************************************************************//
//
//  Developer By : Nilesh Bharti 'Salesforce Consultant' (nilesh.bharti@openexc.com)
//  Created on : 05/11/2024
//  JIRA:- OEP-12783
//  
//  Last Modified on : 05/11/2024
//  
//  Description :
//  This Queueable send 'Ready to Bill' Order details along with related products to OEI.
//
// ************************************************************************************************ //

global class SalesforceOEINetsuiteOrderIntegration implements Queueable, Database.AllowsCallouts {
    
    static String apiEnvironment;
    static CalloutData__c calloutData;
    public String syncOrder = 'false';
    List<Order> orderList = new List<Order>();
    
    public SalesforceOEINetsuiteOrderIntegration(List<Order> orderList, String crtNS) {
        this.orderList = orderList;
        syncOrder = crtNS;
    }
    
    public void execute(QueueableContext context) {
        
        loadCalloutParams();
        System.debug('Callout parameters: ' + calloutData);
        
        
        Set<Id> productIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        Map<Id, List<OrderItem>> orderItemsMap = new Map<Id, List<OrderItem>>();
        
        for (Order ord : orderList) {
            orderItemsMap.put(ord.Id, new List<OrderItem>());
            orderIds.add(ord.Id);
        }
        
        List<Order> orders = [SELECT Id, Owner.Name, Requester_Contact__r.Name, AccountId, Account.Netsuite_External_Name__c,
                              Description, CreatedBy.Name, OrderNumber, Netsuite_Id__c,
                              Region__c, EffectiveDate, Start_Date_Time__c, End_Date_Time__c, 
                              Business_Line__c, Department__c, Status, Name, Event_Type_OE_Defined__c,
                              Billing_Method__c, Billing_Time_Sensitivity__c,
                              Billing_Contact__c, Billing_Contact_Email__c, Billing_Contact_Phone__c,
                              Client_Cost_Code__c, BillingCountry, BillingStreet, BillingCity,
                              BillingState, BillingPostalCode, Billing_Notes__c,
                              Additional_Recipient_1_Email__c, Additional_Recipient_2_Email__c, Billing_Contact__r.Name,
                              Bill_To_Legal_Entity_Name__r.Netsuite_External_Name__c, BillingStateCode, BillingCountryCode
                              FROM Order 
                              WHERE Id = :orderIds for Update];
        
        List<OrderItem> orderItems = [SELECT Id, OrderId, Product2Id, Quantity, UnitPrice, TotalPrice,
                                      OrderItemNumber
                                      FROM OrderItem 
                                      WHERE OrderId IN :orderItemsMap.keySet()];
        
        System.debug('orderItems :::::::::::: ' + orderItems);
        
        for (OrderItem item : orderItems) {
            orderItemsMap.get(item.OrderId).add(item);
            productIds.add(item.Product2Id);
        }
        
        System.debug('productIds :::::::::::: ' + productIds);
        Map<Id, Product2> products = new Map<Id, Product2>([SELECT Id, Name, OE_Product_Name__c, Description, Family,
                                                            Product_Legal_Entity__c, Sub_Product_Family__c, ProductCode,
                                                            Netsuite_Id__c
                                                            FROM Product2 WHERE Id IN :productIds]);
        
        for (Order ord : orders) {
            
            Order orderWithRelations = [SELECT Id, Owner.Name, Requester_Contact__r.Name, Requester_Contact__r.FirstName, AccountId, Account.Netsuite_External_Name__c,
                                        Description, Billing_Contact__r.Name, 
                                        region__c, EffectiveDate, Start_Date_Time__c, End_Date_Time__c, 
                                        Business_Line__c, Department__c, Status, Bill_To_Legal_Entity_Name__r.Netsuite_External_Name__c,
                                        Bill_To_Legal_Entity_Name__r.Name
                                        FROM Order 
                                        WHERE Id = :ord.Id LIMIT 1];
            
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(calloutData.AuthenticationURL__c);
            req.setMethod('POST');
            
            Blob headerValue = Blob.valueOf(calloutData.UserName__c + ':' + calloutData.UserPassword__c);
            String authorizationValue = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationValue);
            
            HttpResponse res;
            String idTokenString = '';
            Order updateOrder = new Order();
            
            DateTime startTime1 = System.now();
            res = http.send(req);
            DateTime endTime1 = System.now();
            Long timeTakenMillis1 = endTime1.getTime() - startTime1.getTime();
            Long timeTakenSeconds1 = timeTakenMillis1 / 1000;
            
            System.debug('Total time taken: ' + timeTakenSeconds1 + ' seconds');
            
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
                
                List<OrderItem> items = orderItemsMap.get(ord.Id);
                
                String sd = ord.Start_Date_Time__c.formatGMT('yyyy-MM-dd');
                String ed = ord.End_Date_Time__c.formatGMT('yyyy-MM-dd');
                DateTime myDateTime = DateTime.newInstance(ord.EffectiveDate.year(), ord.EffectiveDate.month(), ord.EffectiveDate.day(), 0, 0, 0);
                String tranDate = myDateTime.format('yyyy-MM-dd');
                
                String department = '1000 Revenue';
                String description = 'null';
                String billingNotes;
                if(String.isNotBlank(ord.Billing_Notes__c))
                    billingNotes = stringProcessor(ord.Billing_Notes__c);
                else
                    billingNotes = 'null';
                
                String billingStreet;
                if(String.isNotBlank(ord.BillingStreet))
                    billingStreet = stringProcessor(ord.BillingStreet);
                else
                    billingStreet = 'null';
                
                String body = '{' +
                    '"entity":"' + orderWithRelations.Bill_To_Legal_Entity_Name__r.Netsuite_External_Name__c + '",' +
                    '"legal_Entity_Name":"' + orderWithRelations.Bill_To_Legal_Entity_Name__r.Name + '",' +
                    '"memo":"' + description + '",' +
                    '"salesRep":"' + orderWithRelations.Owner.Name + '",' +
                    '"createNewOrder":"' + syncOrder + '",' +
                    '"location":"' + ord.Region__c + '",' +
                    '"tranDate":"' + tranDate + '",' +
                    '"custBody_oe_gt_billing_contact_name":"' + orderWithRelations.Requester_Contact__r.FirstName + '",' +
                    '"custbody_oe_gt_billing_method":"' + ord.Billing_Method__c + '",' +
                    '"custbody_oe_gt_billing_time_sense":"' + ord.Billing_Time_Sensitivity__c + '",' +
                    '"eventType":"' + ord.Event_Type_OE_Defined__c + '",' +
                    '"custBody_oe_gt_start_date":"' + sd + '",' +
                    '"custBody_oe_gt_end_date":"' + ed + '",' +
                    '"otherRefNum":"' + ord.Client_Cost_Code__c + '",' +
                    '"billing_Contact":"' + ord.Billing_Contact__r.Name + '",' +
                    '"billing_Contact_Email":"' + ord.Billing_Contact_Email__c + '",' +
                    '"billing_Contact_Phone":"' + ord.Billing_Contact_Phone__c + '",' +
                    '"billingCountry":"' + ord.BillingCountryCode + '",' +
                    '"billingStreet":"' + billingStreet + '",' +
                    '"billingCity":"' + ord.BillingCity + '",' +
                    '"billingState":"' + ord.BillingStateCode + '",' +
                    '"billingPostalCode":"' + ord.BillingPostalCode + '",' +
                    '"billing_Notes":"' + billingNotes + '",' +
                    '"additional_Recipient_1_Email":"' + ord.Additional_Recipient_1_Email__c + '",' +
                    '"additional_Recipient_2_Email":"' + ord.Additional_Recipient_2_Email__c + '",' +
                    '"externalId":"' + ord.Id + '",';
                
                List<String> itemDetails = new List<String>();
                for (OrderItem ordItem : items) {
                    Product2 prd = products.get(ordItem.Product2Id);
                    String productDescription;
                    if(String.isNotBlank(prd.Description))
                        productDescription = stringProcessor(prd.Description);
                    else
                        productDescription = 'null';
                    
                    String itemBody = '{' +
                        '"custCol_orderNumber":"' + ord.OrderNumber + '",' +
                        '"custColRequester":"' + orderWithRelations.Requester_Contact__r.Name + '",' +
                        '"item":"' + prd.OE_Product_Name__c + '",' +
                        '"custCol1":"' + prd.Family + '",' +
                        '"description":"' + productDescription + '",' +
                        '"quantity":"' + ordItem.Quantity + '",' +
                        '"rate":"' + ordItem.UnitPrice + '",' +
                        '"amount":"' + ordItem.TotalPrice + '",' +
                        '"custCol_revstart":"' + sd + '",' +
                        '"custCol_revend":"' + ed + '",' +
                        '"department":"' + department + '",' +
                        '"eventName":"' + ord.Name + '",' +
                        '"cseg1":"' + ord.Business_Line__c + '",' +
                        '"lineUniqueKey":"' + ordItem.OrderItemNumber + '"';
                    
                    itemBody += '}';
                    itemDetails.add(itemBody);
                }
                
                if (!itemDetails.isEmpty()) {
                    body += '"item":[' + String.join(itemDetails, ',') + '],';
                } else {
                    body += '"item":[],';
                }
                
                body = body.substring(0, body.length() - 1) + '}';
                System.debug('Request body for Order creation: ' + body);
                
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
                    
                    System.debug('Order Creation response status code: ' + res2.getStatusCode() + ' - ' + res2.getBody());
                    
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
                        
                        if(String.isNotBlank(ord.Id)){
                            updateOrder =  [Select Id, Netsuite_Id__c, Netsuite_Creation_Message__c
                                            FROM Order where Id = :ord.Id];
                            System.debug('updateOrder =========>'+updateOrder);
                            
                            if(String.isNotBlank(netsuitId)){
                                System.debug('isNotBlank(netsuitId) =========>'+netsuitId);
                                updateOrder.Netsuite_Id__c = netsuitId;
                            }
                            if(updateOrder != null){
                                updateOrder.Netsuite_Creation_Message__c = 'Order Record Created Successfully.!!!';
                                System.debug('updateOrder != null =========>' +updateOrder);
                                update updateOrder;
                            }
                        }
                    } else {
                        System.debug('Failed to create Order :- ' + res2.getStatusCode() + ' - ' + res2.getStatus() + ' - ' + res2.getBody());
                        updateOrder = [SELECT Id, Netsuite_Id__c, Netsuite_Creation_Message__c FROM Order WHERE Id = :ord.Id];
                        updateOrder.Netsuite_Id__c = '';
                        updateOrder.Netsuite_Creation_Message__c = 'Creation failed :- ' + res2.getBody();
                        update updateOrder;
                    }
                } catch (Exception e) {
                    System.debug('Something strange :- ' + e.getMessage());
                    updateOrder = [SELECT Id, Netsuite_Id__c, Netsuite_Creation_Message__c FROM Order WHERE Id = :ord.Id];
                    updateOrder.Netsuite_Id__c = '';
                    updateOrder.Netsuite_Creation_Message__c = 'Something Wrong at Creation :- ' + errorMessage;
                    update updateOrder;
                    //throw new AuraHandledException(e.getMessage());
                }
                
            } else {
                System.debug('Authentication failed :- ' + res.getStatusCode() + ' - ' + res.getStatus() + ' - ' + res.getBody());
                updateOrder = [SELECT Id, Netsuite_Creation_Message__c FROM Order WHERE Id = :ord.Id];
                updateOrder.Netsuite_Creation_Message__c = 'Authentication failed at Creation :- ' + res.getBody();
                update updateOrder;
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
            OECCallOuts__mdt callouts = [SELECT QAAccountId__c, QAAuthURL__c, QACreateOrderEndpointURL__c, QAPassword__c, QAUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            calloutData = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QACreateOrderEndpointURL__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);             
        }
        else if (apiEnvironment == 'Prod'){
            OECCallOuts__mdt callouts = [SELECT ProdAccountId__c, ProdAuthURL__c, ProductionCreateOrderEndpointURL__c, ProdPassword__c, ProdUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            calloutData = new CalloutData__c(AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProductionCreateOrderEndpointURL__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);              
        }
        else {
            OECCallOuts__mdt callouts = [SELECT DevAccountId__c, DevAuthURL__c, StageCreateOrderEndpointURL__c, DevPassword__c, DevUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            calloutData = new CalloutData__c(AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.StageCreateOrderEndpointURL__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
        }
    }
    
}