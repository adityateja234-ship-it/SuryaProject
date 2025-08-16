// ********************************************************************************* ***************//
// 
//  Developer By : RAJU CHERUKURI Salesforce Architect (raju.cherukuri@openexc.com)
//  Created on : 05/04/2021
//  Last Modified on : 05/11/2021
//  Description :
//  This REST Service creates Standard Order for CITI bank client
//
//  JIRA:
//
// ************************************************************************************************ //

@RestResource (urlMapping='/OrderProductService')
global class OrderProductService {
    @HTTPPost
    static global void insertProduct(){ 
        
        System.debug('Starting Date Time ------------------>>>>:'+System.now());
        String jsonString = RestContext.request.requestBody.toString();
        if(OEUtil.runningInASandbox())
            System.debug('JSON Request Received is --->> '+jsonString);
        boolean errorEncountered = false;
        
        OrderProductHelper oPHelper = OrderProductHelper.parse(jsonString);
        
        String errorMsg = checkBlanks(oPHelper);

        if(!String.isBlank(errorMsg))
        {
            RestContext.response.responseBody = Blob.valueOf('{ "error" : '+errorMsg+ '}');
            return;
        }

        Order ord;
        RestContext.response.addHeader('Content-Type', 'application/json');
        try{
            Id orderId = Id.valueOf(oPHelper.orderId);
            ord = [select id,Pricebook2Id from Order where Id = :orderId];
        }catch(StringException ex){
             System.debug('Error:'+ex);
             RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid length of OrderId"}');
             return;
        }catch(QueryException ex){
             System.debug('Error: OrderId provided does not exist please send valid OrderId'+ex);
             RestContext.response.responseBody = Blob.valueOf('{ "error":"OrderId provided does not exist please send valid OrderId"}');
             return;
        }catch(DmlException ex){
             System.debug('Error:'+ex);
             RestContext.response.responseBody = Blob.valueOf('{ "error":"'+ex.getMessage()+'"}');
             return;
        }catch(Exception ex){
             System.debug('Error:'+ex);
             RestContext.response.responseBody = Blob.valueOf('{ "error" : "'+ex+ '"}');
             return;
        }
        try{
           /** 
            PriceBook2 pb;
            if (oPHelper.PricebookType == 'Conference'){
                pb = [SELECT Id FROM Pricebook2 where name like 'Citi OEConference Custom Price Book'];
            }                
            else if (oPHelper.PricebookType == 'Connect'){
                pb = [SELECT Id FROM Pricebook2 where name like 'Citi OEConnect Custom Price Book'];                
            }
 
            ord.Pricebook2Id = pb.Id;
            update ord; 
            */ 
            PricebookEntry pbe ;
            List<OrderItem> lOItems = new List<OrderItem>();
            OrderItem oItem ;
            
            for (OrderProductHelper.OrderProducts product : oPHelper.OrderProducts){ 
                
                //pbe = [SELECT Product2Id, UnitPrice, Id, Pricebook2Id  FROM PricebookEntry where pricebook2Id = :ord.Pricebook2Id and Name = :product.ProductName];
                
                pbe = [SELECT Product2Id, UnitPrice, Id, Pricebook2Id  FROM PricebookEntry where pricebook2Id = :ord.Pricebook2Id and Product2Id = :product.productName]; //OEP-12048
                
                /**
                if (oPHelper.PricebookType == 'Conference'){

                    pbe = [SELECT Product2Id, UnitPrice, Id, Pricebook2Id  FROM PricebookEntry where pricebook2Id = :pb.Id and Name = :product.ProductName];                   
                }                
                else if (oPHelper.PricebookType == 'Connect'){

                    pbe = [SELECT Product2Id, UnitPrice, Id, Pricebook2Id FROM PricebookEntry where pricebook2Id = :pb.Id and Name = :product.ProductName];                
                }  
                **/           
                 //System.debug('oHelper.PricebookType '+oPHelper.PricebookType+' UnitPrice:'+pbe.UnitPrice+' Product2Id '+pbe.Product2Id+' PricebookEntryId '+pbe.Id+' OrderId '+ord.Id+' Quantity '+product.Quantity);
                 System.debug('UnitPrice:'+pbe.UnitPrice+' Product2Id '+pbe.Product2Id+' PricebookEntryId '+pbe.Id+' OrderId '+ord.Id+' Quantity '+product.Quantity);
                 oItem = new OrderItem ();
                 oItem.UnitPrice = pbe.UnitPrice;
                 oItem.Product2Id = pbe.Product2Id;
                 oItem.PricebookEntryId = Id.valueOf(pbe.Id);
                 oItem.EventId__c = Product.eventId;
                 oItem.MeetingId__c = Product.meetingId;
                 oItem.OrderId = ord.Id;
                 oItem.Quantity = Decimal.valueof(product.Quantity.trim());
                 
                 lOItems.add(oItem);
             }
             
             insert lOItems;
         }catch(QueryException ex){
             System.debug('Error: Product Name provided does not exist please provide correct one'+ex);
             RestContext.response.responseBody = Blob.valueOf('{ "error":"Product Name provided does not exist please provide correct one"}');
             return;
         }catch(DmlException ex){
             System.debug('Error:'+ex);
             RestContext.response.responseBody = Blob.valueOf('{ "error":"'+ex.getMessage()+'"}');
             return;
         }catch(Exception ex){
             System.debug('Error:'+ex);
             RestContext.response.responseBody = Blob.valueOf('{ "error" : "'+ex+ '"}');
             return;
         }
         
         RestContext.response.responseBody = Blob.valueOf('{ "OrderId" : "'+String.valueOf(ord.Id)+'"}');
         System.debug('Starting Date Time ------------------>>>>:'+System.now());
         return; 
    }
    
    
    private static String checkBlanks(OrderProductHelper r){
        String errorString= '';
        Boolean isValidError = false;
    
        if (String.isBlank(r.orderId)){
            errorString = errorString +' orderId ';
            isValidError = true;
 
        }           
        for (OrderProductHelper.OrderProducts product : r.OrderProducts){ 
            
            if(String.isBlank(product.productName)){     
                errorString = errorString +' productName ';
                isValidError = true;
            }
            if(String.isBlank(product.quantity)){     
                errorString = errorString +' quantity ';
                isValidError = true;
            } 
        
        }         
        if(isValidError == true){  
            errorString = errorString +' cant be Null or Blank ';  
        }
        return  errorString;         
    }
    
    
   
    
}