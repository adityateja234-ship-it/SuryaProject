// ********************************************************************************* ***************//
// 
//  Developer By : RAJU CHERUKURI Salesforce Architect (raju.cherukuri@openexc.com)
//  Created on : 04/12/2024
//  Last Modified on : 05/20/2024
//  Description :
//  This REST Service receives Start Date and End Date as parameters
//   Returns all Orders start Date between Start Date and End Date received along with OE Number and Created Date.
//  JIRA:
//
// ************************************************************************************************ //

@RestResource (urlMapping='/OrderNumberService')
global class OECOrderNumberService {
    @HTTPPOST
    static global void getOrderNumbers(){ 
        
        String jsonString = RestContext.request.requestBody.toString();
        System.debug('JSON Request Received is --->> '+jsonString);
        
        if(OEUtil.runningInASandbox())
            System.debug('JSON Request Received is --->> '+jsonString);
        OECOrderNumberHelper oHelper = OECOrderNumberHelper.parse(jsonString);
        String errorMsg = checkBlanks(oHelper);
        
        if(!String.isBlank(errorMsg))
        {
            RestContext.response.statusCode = 400;  
            RestContext.response.responseBody = Blob.valueOf('{ "error" : '+errorMsg+ '}');
            return;
        }
        
        try {
            Date d1 = date.valueOf(oHelper.startDate);
        }catch(Exception exp){
             RestContext.response.statusCode = 400;  
             RestContext.response.responseBody = Blob.valueOf('{ "error" : "Invalid Start Date '+ oHelper.startDate + '"}');
             return ;
    
        }
        try {
            Date d2 = date.valueOf(oHelper.endDate);
        }catch(Exception exp){
             RestContext.response.statusCode = 400;  
             RestContext.response.responseBody = Blob.valueOf('{ "error" : "Invalid End Date '+ oHelper.endDate + '"}');
             return ;
    
        }
         
        String body = prepareBody(oHelper);
        
        RestContext.response.responseBody = Blob.valueOf(body);
         
        //RestContext.response.responseBody = Blob.valueOf('{ "OrderId" : "'+String.valueOf(ord.Id)+'", "OrderNumber" : "'+(ord2.OrderNumber).replaceFirst( '^0+', '')+'"}');
        return; 
         
        
        
    }
    
    private static String checkBlanks(OECOrderNumberHelper r){
        String errorString= '';
        Boolean isValidError = false;
    
         
        if(String.isBlank(r.startDate)){
            errorString = errorString +' startDate cant be blank or invalid';
            isValidError = true;
        }  
        if(String.isBlank(r.endDate)){
            errorString = errorString +' endDate cant be blank or invalid ';
            isValidError = true;
        }
        return errorString;
     }
     
     private static String prepareBody(OECOrderNumberHelper r){
         List<Order> orderList = new List<Order>();

         orderList = [select Id,OrderNumber,Start_Date_Time__c,End_Date_Time__c,Created_Date_Time__c from Order where end_Date_Time__c >= :date.valueOf(r.startDate) and end_Date_Time__c <= :date.valueOf(r.endDate)];
  
         
         
         String body = '[';
         boolean first = true;
         for(Order ord : orderList){
         
             if (!first) // For every second record we need to append , at the previous order details.
                 body = body + ',\n';
             
             System.debug('ord.Id------->' + ord.id);
             System.debug('ord.OrderNumber------->' + ord.OrderNumber);
             System.debug('ord.Start_Date_Time__c------->' + ord.Start_Date_Time__c);
             System.debug('ord.End_Date_Time__c------->' + ord.End_Date_Time__c);
             System.debug('ord.Created_Date_Time__c------->' + ord.Created_Date_Time__c);
             
             body = body + '{"orderNumber":"'+(ord.OrderNumber).replaceFirst( '^0+', '')+'",'+
                                  '"startDate":"'+ord.Start_Date_Time__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+'",'+
                                  '"endDate":"'+ord.End_Date_Time__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+'",'+
                                  '"createdDate":"'+ord.Created_Date_Time__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')+'"}';
                 first = false;
                             
         } 
         body = body + ']';
         
         System.debug('Body ----------------->>>'+body);
         return body;
     }

}