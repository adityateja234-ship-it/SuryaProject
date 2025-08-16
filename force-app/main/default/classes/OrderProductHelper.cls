public class OrderProductHelper {

    public String orderId {get;set;} 
    //public String pricebookType {get;set;} 
    public List<OrderProducts> orderProducts {get;set;} 

    public OrderProductHelper(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'orderId') {
                        orderId = parser.getText();
                    } else if (text == 'orderProducts') {
                        orderProducts = arrayOfOrderProducts(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'OrderProductHelper consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class OrderProducts {
        public String productName {get;set;}
        public String quantity {get;set;} 
        public String eventId {get;set;}  
        public String meetingId {get;set;} 

        public OrderProducts(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'productName') {
                            productName = parser.getText();
                        }else if (text == 'quantity') {
                            quantity = parser.getText();
                        } else if (text == 'eventId') {
                            eventId = parser.getText();
                        } else if (text == 'meetingId') {
                            meetingId = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'OrderProducts consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static OrderProductHelper parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new OrderProductHelper(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
    


    private static List<OrderProducts> arrayOfOrderProducts(System.JSONParser p) {
        List<OrderProducts> res = new List<OrderProducts>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new OrderProducts(p));
        }
        return res;
    }



}