// ********************************************************************************* ***************//
// 
// 	Developer By : Nilesh Bharti 'Salesforce Consultant' (nilesh.bharti@openexc.com)
//  Created on : 19/12/2024
//  JIRA:- OEP-14228
//  
//  Last Modified on : 19/12/2024
//  
//  Description :
//  This REST Service receives payment details as parameter from OEI
//  And create Payment in Sf
//  
//  Returns details :
//  For Success
//  Payment Id along with 'Success' message and StatusCode '200'
//  
//  For Error
//  StatusCode '400' along with error message
//
// ************************************************************************************************ //

@RestResource(urlMapping='/PaymentService/*')
global class PaymentService {
    
    @HttpPost
    global static void insertPayments(){ 
        
        DateTime startTime = System.now();
        
        String jsonString = RestContext.request.requestBody.toString();
        if(OEUtil.runningInASandbox())
            System.debug('JSON Request Received is --->> '+jsonString);
        PaymentServiceHelper oHelper = PaymentServiceHelper.parse(jsonString);
        System.debug('oHelper========>'+oHelper);
        RestContext.response.addHeader('Content-Type', 'application/json');
        
        String errorMsg = checkBlanks(oHelper);
        
        if(!String.isBlank(errorMsg)){
            RestContext.response.statusCode = 400;
            Integer statusCode = RestContext.response.statusCode;
            RestContext.response.responseBody = Blob.valueOf('{ \"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"' + errorMsg + '\" }}');
            return;
        }
        
        if (!isValidDateFormat(oHelper.paymentDate)) {
            RestContext.response.statusCode = 400;
            Integer statusCode = RestContext.response.statusCode;
            RestContext.response.responseBody = Blob.valueOf('{\"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"Invalid paymentDate format. It must be in yyyy-MM-dd format.\"}}');
            return;
        }
        
        if (oHelper.paymentAmount < 0) {
            RestContext.response.statusCode = 400;
            Integer statusCode = RestContext.response.statusCode;
            RestContext.response.responseBody = Blob.valueOf('{\"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"Payment amount must be positive.\"}}');
            return;
        }
        
        List<Payment__c> insertPaymentList = new List<Payment__c>();
        List<Payment__c> insertDiscountList = new List<Payment__c>();
        
        Integer payCount = [SELECT count() FROM Payment__c WHERE Netsuite_Id__c = :oHelper.externalId AND Order__r.OrderNumber = :oHelper.orderNumbers];
        System.debug('payCount =======> '+payCount);
        
        if(payCount == 0) {
            
            try {
                
                Decimal amount = oHelper.paymentAmount;
                Decimal amountDiscount = oHelper.discountFee;
                Map<Id,Order> relatedOrder = new Map<Id,Order>([SELECT Id, Status FROM Order WHERE OrderNumber = :oHelper.orderNumbers]);
                System.debug('relatedOrder details ::::: '+relatedOrder);
                List<Invoice__c> relatedInvoice = [SELECT Id, Order__c, Order__r.Status, Invoice_Amount__c
                                                   FROM Invoice__c 
                                                   WHERE External_Id__c = :oHelper.invoiceExternalId AND Order__r.OrderNumber = :oHelper.orderNumbers AND Order__r.Status = 'Invoice Sent'
                                                   ORDER BY Order__r.Order_Payment_Balance__c
                                                  ];
                System.debug('relatedInvoice ::::: '+relatedInvoice.size());
                System.debug('relatedInvoice details ::::: '+relatedInvoice);
                
                if(relatedInvoice.size() > 0){
                    
                    for(Invoice__c inv : relatedInvoice){
                        
                        if(amount > 0){
                            Payment__c insertPayment = new Payment__c();
                            insertPayment.Netsuite_Id__c = oHelper.externalId;                        
                            insertPayment.Payment_Amount__c = oHelper.paymentAmount;
                            insertPayment.Payment_Amount_USD__c = oHelper.paymentAmountUSD;
                            insertPayment.Payment_Date__c = Date.valueOf(oHelper.paymentDate);
                            
                            if(oHelper.paymentType == 'Payment'){
                                insertPayment.Payment_Type__c = 'Invoice';
                            } else if(oHelper.paymentType == 'Deposit'){
                                insertPayment.Payment_Type__c = 'Deposit';
                            } else {
                                insertPayment.Payment_Type__c = oHelper.paymentType;
                            }
                            
                            insertPayment.Applying_Transaction__c = oHelper.applyingTransaction;
                            insertPayment.Description_Notes__c = oHelper.descriptionNotes;
                            insertPayment.CurrencyIsoCode = oHelper.currencyIsoCode;
                            insertPayment.Order__c = inv.Order__c;
                            insertPayment.Invoice__c = inv.Id;
                            
                            insertPaymentList.add(insertPayment);
                        }
                    }
                    
                    if(!insertPaymentList.isEmpty()){
                        insert insertPaymentList;
                    }
                    
                    List<Invoice__c> relatedInvoices = [SELECT Id, Order__c, Order__r.Status, Invoice_Amount__c
                                                        FROM Invoice__c 
                                                        WHERE External_Id__c = :oHelper.invoiceExternalId AND Order__r.OrderNumber = :oHelper.orderNumbers AND Order__r.Status = 'Invoice Sent'
                                                        ORDER BY Order__r.Order_Payment_Balance__c
                                                       ];
                    System.debug('relatedInvoices ::::: '+relatedInvoices.size());
                    
                    for(Invoice__c inv : relatedInvoices){
                        
                        if(amountDiscount > 0){
                            
                            Payment__c insertDiscountPayment = new Payment__c();
                            insertDiscountPayment.Netsuite_Id__c = oHelper.externalId;
                            
                            insertDiscountPayment.Payment_Amount__c = oHelper.discountFee;
                            insertDiscountPayment.Payment_Amount_USD__c = oHelper.discountFee;
                            
                            insertDiscountPayment.Payment_Date__c = Date.valueOf(oHelper.paymentDate);
                            insertDiscountPayment.Payment_Type__c = null;
                            
                            insertDiscountPayment.Applying_Transaction__c = oHelper.applyingTransaction;
                            insertDiscountPayment.Description_Notes__c = 'This is discount amount payment.';
                            insertDiscountPayment.CurrencyIsoCode = oHelper.currencyIsoCode;
                            insertDiscountPayment.Order__c = inv.Order__c;
                            insertDiscountPayment.Invoice__c = inv.Id;
                            
                            insertDiscountList.add(insertDiscountPayment);
                            
                        }
                    }
                    
                    if(!insertDiscountList.isEmpty()){
                        insert insertDiscountList;
                    }
                }
                else{
                    RestContext.response.statusCode = 400;
                    Integer statusCode = RestContext.response.statusCode;
                    RestContext.response.responseBody = Blob.valueOf('{\"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"Order status is not invoice sent.\"}}');
                    return;
                }
            }
            catch (DmlException ex) {
                System.debug('Error ::::: '+ex);
                RestContext.response.statusCode = 400;
                Integer statusCode = RestContext.response.statusCode;
                RestContext.response.responseBody = Blob.valueOf('{ \"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"' + ex.getMessage() + '\" }}');
                return;
            }
            catch(Exception ex){
                System.debug('Error ::::: '+ex);
                RestContext.response.statusCode = 400;
                Integer statusCode = RestContext.response.statusCode;
                RestContext.response.responseBody = Blob.valueOf('{ \"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"' + ex.getMessage() + '\" }}');
                return;
            }
            
            List<Payment__c> payList = [SELECT Id FROM Payment__c WHERE Id = :insertPaymentList];
            List<Payment__c> discountList = [SELECT Id FROM Payment__c WHERE Id = :insertDiscountList];
            List<String> paymentIds = new List<String>();
            for (Payment__c pay : payList) {
                paymentIds.add(pay.Id);
            }
            
            for (Payment__c pay : discountList) {
                paymentIds.add(pay.Id);
            }
            
            DateTime endTime = System.now();
            Long timeTakenMillis = endTime.getTime() - startTime.getTime();
            Long timeTakenSeconds = timeTakenMillis / 1000;
            System.debug('Total time taken to Create ' +payList.size()+ ' Payment/s '+ timeTakenSeconds + ' seconds');
            
            RestContext.response.statusCode = 200;
            Integer statusCode = RestContext.response.statusCode;
            RestContext.response.responseBody = Blob.valueOf('{ \"data\": { \"statusCode\": ' + statusCode + ', \"message\": \"Successfully created\", \"externalId\" : \"' + paymentIds + '\" }}');
            return;
            
        }
        else{
            
            List<String> paymentIdsUpdated = new List<String>();
            try {
                
                List<Payment__c> existingPaymentUpdate = new List<Payment__c>();
                
                List<Payment__c> existingPaymentList = [SELECT Id, Netsuite_Id__c, Applying_Transaction__c, Payment_Type__c,
                                                        CurrencyIsoCode, Invoice__c, Payment_Amount__c, Order__c,
                                                        Payment_Amount_USD__c, Payment_Date__c, Description_Notes__c,
                                                        Order__r.Billing_Method__c, Order__r.Order_Payment_Balance__c,
                                                        Order__r.TotalAmount, Order__r.Payment_Totals__c, Invoice__r.External_Id__c
                                                        FROM Payment__c
                                                        WHERE Netsuite_Id__c = :oHelper.externalId AND Order__r.OrderNumber = :oHelper.orderNumbers
                                                        ORDER BY Order__r.Order_Payment_Balance__c
                                                       ];
                System.debug('existingPaymentList ::::: '+existingPaymentList.size());
                
                for(Payment__c pay : existingPaymentList){
                    
                    if(pay.Invoice__r.External_Id__c != oHelper.invoiceExternalId){
                        RestContext.response.statusCode = 400;
                        Integer statusCode = RestContext.response.statusCode;
                        RestContext.response.responseBody = Blob.valueOf('{\"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"You cannot change Invoice details from existing payment.\"}}');
                        return;
                    }
                    
                    Payment__c existingPayment = new Payment__c();
                    existingPayment.Id = pay.Id;
                    existingPayment.Payment_Date__c = Date.valueOf(oHelper.paymentDate);
                    
                    if(pay.Payment_Type__c == null){
                        existingPayment.Payment_Amount__c = oHelper.discountFee;
                        existingPayment.Payment_Amount_USD__c = oHelper.discountFeeUSD;
                        existingPayment.Description_Notes__c = 'This discount amount payment is updated.';
                    } else if(oHelper.paymentType == 'Payment'){
                        existingPayment.Payment_Amount__c = oHelper.paymentAmount;
                        existingPayment.Payment_Amount_USD__c = oHelper.paymentAmountUSD;
                        existingPayment.Payment_Type__c = 'Invoice';
                        existingPayment.Description_Notes__c = oHelper.descriptionNotes;
                    } else if(oHelper.paymentType == 'Deposit'){
                        existingPayment.Payment_Amount__c = oHelper.paymentAmount;
                        existingPayment.Payment_Amount_USD__c = oHelper.paymentAmountUSD;
                        existingPayment.Payment_Type__c = 'Deposit';
                        existingPayment.Description_Notes__c = oHelper.descriptionNotes;
                    } else{
                        existingPayment.Payment_Amount__c = oHelper.paymentAmount;
                        existingPayment.Payment_Amount_USD__c = oHelper.paymentAmountUSD;
                        existingPayment.Payment_Type__c = oHelper.paymentType;
                        existingPayment.Description_Notes__c = oHelper.descriptionNotes;
                    }
                    
                    existingPayment.CurrencyIsoCode = oHelper.currencyIsoCode;
                    existingPayment.Applying_Transaction__c = oHelper.applyingTransaction;
                    
                    existingPaymentUpdate.add(existingPayment);
                    paymentIdsUpdated.add(pay.Id);
                    
                }
                
                if(!existingPaymentUpdate.isEmpty()){
                    update existingPaymentUpdate;
                }
            }
            catch (DmlException ex) {
                System.debug('Error ::::: '+ex);
                RestContext.response.statusCode = 400;
                Integer statusCode = RestContext.response.statusCode;
                RestContext.response.responseBody = Blob.valueOf('{ \"error\": { \"statusCode\": ' + statusCode + ', \"message\": \"' + ex.getMessage() + '\" }}');
                return;
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
            System.debug('Total time taken to Update ' +paymentIdsUpdated.size()+ ' Payment/s '+ timeTakenSeconds + ' seconds');
            
            RestContext.response.statusCode = 200;
            Integer statusCode = RestContext.response.statusCode;
            RestContext.response.responseBody = Blob.valueOf('{ \"data\": { \"statusCode\": ' + statusCode + ', \"message\": \"Successfully Updated\", \"externalId\" : \"' + paymentIdsUpdated + '\" }}');
            return;
        }
    }
    
    private static String checkBlanks(PaymentServiceHelper r){
        String errorString= '';
        Boolean isValidError = false;
        
        if (r.orderNumbers.isEmpty()){
            errorString = errorString +'orderNumbers';
            isValidError = true;
        }
        if(String.isBlank(String.valueOf(r.paymentAmount))){
            errorString = errorString +'paymentAmount';
            isValidError = true;
        }
        if(String.isBlank(r.externalId)){
            errorString = errorString +'externalId';
            isValidError = true;
        }
        if(String.isBlank(r.invoiceExternalId)){
            errorString = errorString +'invoiceExternalId';
            isValidError = true;
        }
        if(String.isBlank(r.applyingTransaction)){
            errorString = errorString +'applyingTransaction';
            isValidError = true;
        }
        if(String.isBlank(r.paymentDate)){
            errorString = errorString +'paymentDate';
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