@IsTest
public class OrderProductHelper_Test {
    
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{'+
        '      \"orderId\":\"\",'+
        //'      \"pricebookType\":\"Conference\",    '+
        '      \"orderProducts\":  ['+
        '            {'+
        '            \"productName\": \"Transcription - AI\",'+
        '            \"quantity\": \"1\"'+
        '            }'+
        '         ]'+
        '}';
        OrderProductHelper r = OrderProductHelper.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        OrderProductHelper objOrderProductHelper = new OrderProductHelper(System.JSON.createParser(json));
        System.assert(objOrderProductHelper != null);
        System.assert(objOrderProductHelper.orderId == null);
        //System.assert(objOrderProductHelper.pricebookType == null);
        System.assert(objOrderProductHelper.orderProducts == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        OrderProductHelper.OrderProducts objOrderProducts = new OrderProductHelper.OrderProducts(System.JSON.createParser(json));
        System.assert(objOrderProducts != null);
        System.assert(objOrderProducts.productName == null);
        System.assert(objOrderProducts.quantity == null);
    }
}