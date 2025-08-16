public class UpdatePriceBookController {
    @AuraEnabled
    public static String updatePriceBook(String orderId, String priceBookId, String status){
        String errorMsg = '';
        try{
            List<OrderItem> productList = new List<OrderItem>();
            productList = [SELECT Id FROM OrderItem WHERE OrderId =: orderId];
            Order updateOrder = new Order();
            updateOrder.Id = orderId;
            if(productList.size()>0 && status == 'In Progress'){
                updateOrder.Status = 'New';
                update updateOrder;
                delete productList;
                updateOrder.Pricebook2Id = priceBookId;
                update updateOrder;
            }
            else{
                if(productList.size()>0){
                    delete productList;
                }
                updateOrder.Pricebook2Id = priceBookId;
                update updateOrder;
            }
        } catch(Exception ex){
            errorMsg = ex.getMessage();
        }
        return errorMsg;
    }
    @AuraEnabled
    public static Order getOrderDetails(String orderId){
        return [SELECT Id, Status FROM Order WHERE Id =: orderId];
    }
    
}