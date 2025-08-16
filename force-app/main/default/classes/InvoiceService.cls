// ********************************************************************************* ***************//
// 
// 	Developer By : Nilesh Bharti 'Salesforce Consultant' (nilesh.bharti@openexc.com)
//  Created on : 05/12/2024
//  JIRA:- OEP-13754
//  
//  Last Modified on : 05/12/2024
//  
//  Description :
//  This REST Service receives Invoices/credit memo as parameters from OEI
//  
//  Returns details :
//  For Success
//  Invoice Id along with 'Success' message and StatusCode '200'
//  
//  For Error
//  StatusCode '400' along with error message
//
// ************************************************************************************************ //

@RestResource(urlMapping='/InvoiceService/*')
global class InvoiceService {
    
    @HttpPost
    global static void insertInvoices() {
        
        DateTime startTime = System.now();
        
        String jsonString = RestContext.request.requestBody.toString();
        if(OEUtil.runningInASandbox())
            System.debug('JSON Request Received is --->> '+jsonString);
        InvoiceServiceHelper oHelper = InvoiceServiceHelper.parse(jsonString);
        System.debug('oHelper========>'+oHelper);
        RestContext.response.addHeader('Content-Type', 'application/json');
        String errorMsg = checkBlanks(oHelper);
        if(!String.isBlank(errorMsg)){
            RestContext.response.statusCode = 400;
            Integer statusCode = RestContext.response.statusCode;
            RestContext.response.responseBody = Blob.valueOf('{ \"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"' + errorMsg + '\" }}');
            return;
        }
        
        if (!isValidDateFormat(oHelper.invoiceDate)) {
            RestContext.response.statusCode = 400;
            Integer statusCode = RestContext.response.statusCode;
            RestContext.response.responseBody = Blob.valueOf('{\"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"Invalid invoiceDate format. It must be in yyyy-MM-dd format.\"}}');
            return;
        }
        
        if (!isValidDateFormat(oHelper.invoiceSentDate)) {
            RestContext.response.statusCode = 400;
            Integer statusCode = RestContext.response.statusCode;
            RestContext.response.responseBody = Blob.valueOf('{\"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"Invalid invoiceSentDate format. It must be in yyyy-MM-dd format.\"}}');
            return;
        }
        
        List<Invoice__c> insertInvoiceList = new List<Invoice__c>();
        
        Integer invCount = [SELECT count() FROM Invoice__c WHERE External_Id__c = :oHelper.externalId AND Order__r.OrderNumber = :oHelper.orderNumber];
        System.debug('InvCount =======> '+invCount);
        
        if(invCount == 0){
            
            try {
                
                List<Order> relatedOrder = [SELECT Id, Status FROM Order WHERE OrderNumber = :oHelper.orderNumber];
                System.debug('relatedOrder ::::: '+relatedOrder.size() + ' :::: Order details :- '+relatedOrder);
                
                if(relatedOrder.size() > 0){
                    for(Order ord : relatedOrder){
                        if(ord.Status == 'Ready to Bill' || ord.Status == 'Invoice Sent'){
                            Invoice__c insertInvoice = new Invoice__c();
                            insertInvoice.External_Id__c = oHelper.externalId;
                            insertInvoice.Date_Invoice_Sent__c = Date.valueOf(oHelper.invoiceSentDate);
                            insertInvoice.Invoice_Amount__c = oHelper.invoiceAmount;
                            insertInvoice.Invoice_Date__c = Date.valueOf(oHelper.invoiceDate);
                            insertInvoice.Invoice_Number__c = oHelper.invoiceNumber;
                            insertInvoice.Description_Notes__c = oHelper.descriptionNotes;
                            
                            if(oHelper.invoiceAmount < 0)
                                insertInvoice.Credit__c = true;
                            
                            insertInvoice.Order__c = ord.Id;
                            insertInvoiceList.add(insertInvoice);
                        }
                        else{
                            RestContext.response.statusCode = 400;
                            Integer statusCode = RestContext.response.statusCode;
                            RestContext.response.responseBody = Blob.valueOf('{\"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"Order Status is not Ready to Bill/Invoice Sent in salesforce.\"}}');
                            return;
                        }
                    }
                }
                else{
                    RestContext.response.statusCode = 400;
                    Integer statusCode = RestContext.response.statusCode;
                    RestContext.response.responseBody = Blob.valueOf('{\"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"Order not available in Salesforce.\"}}');
                    return;
                }
                
                if(!insertInvoiceList.isEmpty()){
                    insert insertInvoiceList;
                }
            }
            catch(Exception ex){
                System.debug('Error ::::: '+ex);
                RestContext.response.statusCode = 400;
                Integer statusCode = RestContext.response.statusCode;
                RestContext.response.responseBody = Blob.valueOf('{ \"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"' + ex.getMessage() + '\" }}');
                return;
            }
            
            List<Invoice__c> invList = [SELECT Id FROM Invoice__c WHERE Id = :insertInvoiceList];
            System.debug('invList ::::: '+invList.size());
            List<String> invoiceIds = new List<String>();
            for (Invoice__c inv : invList) {
                invoiceIds.add(inv.Id);
            }
            
            DateTime endTime = System.now();
            Long timeTakenMillis = endTime.getTime() - startTime.getTime();
            Long timeTakenSeconds = timeTakenMillis / 1000;
            System.debug('Total time taken to Create ' +invList.size()+ ' Invoice/s '+ timeTakenSeconds + ' seconds');
            
            RestContext.response.statusCode = 200;
            Integer statusCode = RestContext.response.statusCode;
            RestContext.response.responseBody = Blob.valueOf('{ \"data\": { \"statusCode\": ' + statusCode + ', \"message\": \"Successfully created\", \"externalId\" : \"' + invoiceIds + '\" }}');
            return;
            
        }
        else if(oHelper.credit == false){
            
            List<String> invoiceIdsUpdated = new List<String>();
            try {
                
                List<Invoice__c> existingInvoiceUpdate = new List<Invoice__c>();
                List<Invoice__c> existingInvoiceList = [SELECT Id, External_Id__c, Credit__c, Date_Invoice_Sent__c,
                                                        Invoice_Amount__c, Invoice_Date__c, Invoice_Number__c, Order__c,
                                                        Description_Notes__c
                                                        FROM Invoice__c
                                                        WHERE External_Id__c = :oHelper.externalId AND Order__r.OrderNumber = :oHelper.orderNumber];
                System.debug('existingInvoiceList ::::: '+existingInvoiceList.size() +' :::: Existing Invoice :- ' +existingInvoiceList);
                Map<Id,Order> orderMap = new Map<Id,Order>([SELECT Id, OrderNumber FROM Order WHERE OrderNumber = :oHelper.orderNumber]);
                
                for(Invoice__c inv : existingInvoiceList){
                    
                    if(!orderMap.containsKey(inv.Order__c)){
                        RestContext.response.statusCode = 400;
                        Integer statusCode = RestContext.response.statusCode;
                        RestContext.response.responseBody = Blob.valueOf('{\"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"You cannot change Order details from existing invoice.\"}}');
                        return;
                    }
                    
                    Invoice__c existingInvoice = new Invoice__c();
                    existingInvoice.Id = inv.Id;
                    existingInvoice.Date_Invoice_Sent__c = Date.valueOf(oHelper.invoiceSentDate);
                    existingInvoice.Invoice_Amount__c = oHelper.invoiceAmount;
                    existingInvoice.Invoice_Date__c = Date.valueOf(oHelper.invoiceDate);
                    existingInvoice.Invoice_Number__c = oHelper.invoiceNumber;
                    existingInvoice.Description_Notes__c = oHelper.descriptionNotes;
                    
                    if(oHelper.invoiceAmount < 0)
                        existingInvoice.Credit__c = true;
                    
                    existingInvoiceUpdate.add(existingInvoice);
                    invoiceIdsUpdated.add(inv.Id);
                }
                
                if(!existingInvoiceUpdate.isEmpty()){
                    update existingInvoiceUpdate;
                }
            }
            catch(Exception ex){
                System.debug('Error ::::: '+ex);
                RestContext.response.statusCode = 400;
                Integer statusCode = RestContext.response.statusCode;
                RestContext.response.responseBody = Blob.valueOf('{ \"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"' + ex.getMessage() + '\" }}');
                return;
            }
            
            DateTime endTime = System.now();
            Long timeTakenMillis = endTime.getTime() - startTime.getTime();
            Long timeTakenSeconds = timeTakenMillis / 1000;
            System.debug('Total time taken to Update ' +invoiceIdsUpdated.size()+ ' Invoice/s '+ timeTakenSeconds + ' seconds');
            
            RestContext.response.statusCode = 200;
            Integer statusCode = RestContext.response.statusCode;
            RestContext.response.responseBody = Blob.valueOf('{ \"data\": { \"statusCode\": ' + statusCode + ', \"message\": \"Successfully Updated\", \"externalId\" : \"' + invoiceIdsUpdated + '\" }}');
            return;
        }
        else {
            
            List<String> paymentIdsUpdated = new List<String>();
            List<Payment__c> existingPaymentUpdate = new List<Payment__c>();
            
            try{
                
                List<Payment__c> existingPaymentList = [SELECT Id, Netsuite_Id__c, Applying_Transaction__c, Payment_Type__c,
                                                        CurrencyIsoCode, Invoice__c, Payment_Amount__c, Order__c,
                                                        Payment_Amount_USD__c, Payment_Date__c, Description_Notes__c,
                                                        Order__r.Billing_Method__c, Order__r.Order_Payment_Balance__c,
                                                        Order__r.TotalAmount, Order__r.Payment_Totals__c, Invoice__r.External_Id__c
                                                        FROM Payment__c
                                                        WHERE Invoice__r.External_Id__c = :oHelper.externalId AND Order__r.OrderNumber = :oHelper.orderNumber
                                                       ];
                System.debug('existingPaymentList ::::: '+existingPaymentList.size() + ' ::::: Existing Payment :- ' +existingPaymentList);
                
                for(Payment__c pay : existingPaymentList){
                    
                    Payment__c existingPayment = new Payment__c();
                    existingPayment.Id = pay.Id;
                    
                    existingPayment.Payment_Amount__c = 0;
                    existingPayment.Payment_Amount_USD__c = 0;
                    
                    existingPaymentUpdate.add(existingPayment);
                    paymentIdsUpdated.add(pay.Id);
                }
                
                if(!existingPaymentUpdate.isEmpty()){
                    update existingPaymentUpdate;
                }
                
                List<Invoice__c> existingInvoiceUpdate = new List<Invoice__c>();
                List<Invoice__c> existingInvoiceList = [SELECT Id, External_Id__c, Credit__c, Date_Invoice_Sent__c,
                                                        Invoice_Amount__c, Invoice_Date__c, Invoice_Number__c, Order__c,
                                                        Description_Notes__c
                                                        FROM Invoice__c
                                                        WHERE External_Id__c = :oHelper.externalId AND Order__r.OrderNumber = :oHelper.orderNumber
                                                       ];
                System.debug('existingInvoiceList ::::: '+existingInvoiceList.size() + ' :::: Existing Invoice :- '+existingInvoiceList);
                Map<Id,Order> orderMap = new Map<Id,Order>([SELECT Id, OrderNumber FROM Order WHERE OrderNumber = :oHelper.orderNumber]);
                
                for(Invoice__c inv : existingInvoiceList){
                    
                    if(!orderMap.containsKey(inv.Order__c)){
                        RestContext.response.statusCode = 400;
                        Integer statusCode = RestContext.response.statusCode;
                        RestContext.response.responseBody = Blob.valueOf('{\"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"You cannot change Order details from existing invoice.\"}}');
                        return;
                    }
                    
                    Invoice__c existingInvoice = new Invoice__c();
                    existingInvoice.Id = inv.Id;
                    existingInvoice.Date_Invoice_Sent__c = Date.valueOf(oHelper.invoiceSentDate);
                    existingInvoice.Invoice_Amount__c = oHelper.invoiceAmount;
                    existingInvoice.Invoice_Date__c = Date.valueOf(oHelper.invoiceDate);
                    existingInvoice.Invoice_Number__c = oHelper.invoiceNumber;
                    existingInvoice.Description_Notes__c = oHelper.descriptionNotes;
                    
                    if(oHelper.invoiceAmount < 0)
                        existingInvoice.Credit__c = true;
                    
                    existingInvoiceUpdate.add(existingInvoice);
                    paymentIdsUpdated.add(inv.Id);
                }
                
                
                if(!existingInvoiceUpdate.isEmpty()){
                    update existingInvoiceUpdate;
                }
            }
            catch(Exception ex){
                System.debug('Error ::::: '+ex);
                RestContext.response.statusCode = 400;
                Integer statusCode = RestContext.response.statusCode;
                RestContext.response.responseBody = Blob.valueOf('{ \"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"' + ex.getMessage() + '\" }}');
                return;
            }
            
            DateTime endTime = System.now();
            Long timeTakenMillis = endTime.getTime() - startTime.getTime();
            Long timeTakenSeconds = timeTakenMillis / 1000;
            System.debug('Total time taken to Update ' +existingPaymentUpdate.size()+ ' Payment/s '+ timeTakenSeconds + ' seconds');
            
            RestContext.response.statusCode = 200;
            Integer statusCode = RestContext.response.statusCode;
            RestContext.response.responseBody = Blob.valueOf('{ \"data\": { \"statusCode\": ' + statusCode + ', \"message\": \"Successfully Updated all payments to zero\", \"externalId\" : \"' + paymentIdsUpdated + '\" }}');
            return;
        }
        
    }
    
    private static String checkBlanks(InvoiceServiceHelper r){
        String errorString= '';
        Boolean isValidError = false;
        
        if (r.orderNumber.isEmpty()){
            errorString = errorString +'orderNumber';
            isValidError = true;
        }
        if(String.isBlank(String.valueOf(r.invoiceAmount))){
            errorString = errorString +'invoiceAmount';
            isValidError = true;
        }
        if(String.isBlank(r.externalId)){
            errorString = errorString +'externalId';
            isValidError = true;
        }
        if(String.isBlank(r.invoiceNumber)){
            errorString = errorString +'invoiceNumber';
            isValidError = true;
        }
        if(String.isBlank(r.invoiceDate)){
            errorString = errorString +'invoiceDate';
            isValidError = true;
        }
        if(String.isBlank(r.invoiceSentDate)){
            errorString = errorString +'invoiceSentDate';
            isValidError = true;
        }
        if(r.credit == null){
            errorString = errorString +'credit';
            isValidError = true;
        }
        if(isValidError == true){
            errorString = errorString +' cant be null or blank';
        }
        return  errorString;
    }
    
    // Helper method to check if the date string is in valid yyyy-MM-dd format
    private static Boolean isValidDateFormat(String dateStr) {
        
        String datePattern = '^(\\d{4})-(\\d{2})-(\\d{2})$';
        
        if (String.isBlank(dateStr)) {
            return false;
        }
        
        Pattern pattern = Pattern.compile(datePattern);
        Matcher matcher = pattern.matcher(dateStr);
        
        if (!matcher.matches()) {
            return false;
        }
        
        try {
            Date.valueOf(dateStr);
            return true;
        } catch (Exception ex) {
            return false;
        }
    }
}