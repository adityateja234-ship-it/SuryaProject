public class InvoiceServiceHelper {

    public String externalId {get; set;}
    public List<String> orderNumber {get; set;}
    public Decimal invoiceAmount {get; set;}
    public String invoiceNumber {get; set;}
    public String invoiceDate {get; set;}
    public String invoiceSentDate {get; set;}
    public String descriptionNotes {get; set;}
    public Boolean credit {get; set;}

    public InvoiceServiceHelper(JSONParser parser) {
        orderNumber = new List<String>();
        
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
                
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (fieldName == 'externalId') {
                        externalId = parser.getText();
                    } else if (fieldName == 'orderNumber') {
                        if (parser.getCurrentToken() == System.JSONToken.START_ARRAY) {
                            while (parser.nextToken() != System.JSONToken.END_ARRAY) {
                                orderNumber.add(parser.getText());
                            }
                        }
                    } else if (fieldName == 'invoiceAmount') {
                        invoiceAmount = Decimal.valueOf(parser.getText());
                    } else if (fieldName == 'invoiceNumber') {
                        invoiceNumber = parser.getText();
                    } else if (fieldName == 'invoiceDate') {
                        invoiceDate = parser.getText();
                    } else if (fieldName == 'invoiceSentDate') {
                        invoiceSentDate = parser.getText();
                    } else if (fieldName == 'descriptionNotes') {
                        descriptionNotes = parser.getText();
                    } else if (fieldName == 'credit') {
                        credit = Boolean.valueOf(parser.getText());
                    } else {
                        System.debug(LoggingLevel.WARN, 'InvoiceServiceHelper consuming unrecognized property: ' + fieldName);
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken currentToken = parser.getCurrentToken();
            if (currentToken == System.JSONToken.START_OBJECT || 
                currentToken == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (currentToken == System.JSONToken.END_OBJECT ||
                currentToken == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

    public static InvoiceServiceHelper parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new InvoiceServiceHelper(parser);
    }

    public void debugInvoiceDetails() {
        System.debug('Invoice Details: ');
        System.debug('ExternalId = ' + externalId);
        System.debug('orderNumbers = ' + orderNumber);
        System.debug('InvoiceAmount = ' + invoiceAmount);
        System.debug('InvoiceNumber = ' + invoiceNumber);
        System.debug('InvoiceDate = ' + invoiceDate);
        System.debug('InvoiceSentDate = ' + invoiceSentDate);
        System.debug('DescriptionNotes = ' + descriptionNotes);
        System.debug('Credit = ' + credit);
    }
}