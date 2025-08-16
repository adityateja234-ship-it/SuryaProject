public class PaymentServiceHelper {
    
    public String externalId {get; set;}
    public List<String> orderNumbers {get; set;}
    public String invoiceNumber {get; set;}
    public String invoiceExternalId {get; set;}
    public Decimal paymentAmount {get; set;}
    public Decimal paymentAmountUSD {get; set;}
    public String paymentType {get; set;}
    public String paymentDate {get; set;}
    public String applyingTransaction {get; set;}
    public String currencyIsoCode {get; set;}
    public String descriptionNotes {get; set;}
    public Decimal discountFee {get; set;}
    public Decimal discountFeeUSD {get; set;}
    
    public PaymentServiceHelper(JSONParser parser) {
        orderNumbers = new List<String>();
        
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
                
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (fieldName == 'externalId') {
                        externalId = parser.getText();
                    } else if (fieldName == 'orderNumbers') {
                        if (parser.getCurrentToken() == System.JSONToken.START_ARRAY) {
                            while (parser.nextToken() != System.JSONToken.END_ARRAY) {
                                orderNumbers.add(parser.getText());
                            }
                        }
                    } else if (fieldName == 'invoiceNumber') {
                        invoiceNumber = parser.getText();
                    } else if (fieldName == 'invoiceExternalId') {
                        invoiceExternalId = parser.getText();
                    } else if (fieldName == 'paymentAmount') {
                        paymentAmount = Decimal.valueOf(parser.getText());
                    } else if (fieldName == 'paymentAmountUSD') {
                        paymentAmountUSD = Decimal.valueOf(parser.getText());
                    } else if (fieldName == 'discountFee') {
                        discountFee = Decimal.valueOf(parser.getText());
                    } else if (fieldName == 'discountFeeUSD') {
                        discountFeeUSD = Decimal.valueOf(parser.getText());
                    } else if (fieldName == 'paymentType') {
                        paymentType = parser.getText();
                    } else if (fieldName == 'paymentDate') {
                        paymentDate = parser.getText();
                    } else if (fieldName == 'applyingTransaction') {
                        applyingTransaction = parser.getText();
                    } else if (fieldName == 'descriptionNotes') {
                        descriptionNotes = parser.getText();
                    } else if (fieldName == 'currencyIsoCode') {
                        currencyIsoCode = parser.getText();
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
    
    public static PaymentServiceHelper parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new PaymentServiceHelper(parser);
    }
    
    public void debugPaymentDetails() {
        System.debug(' ***** Payment Details***** ');
        System.debug('ExternalId = ' + externalId);
        System.debug('OrderNumbers = ' + orderNumbers);
        System.debug('InvoiceNumber = ' + invoiceNumber);
        System.debug('InvoiceExternalId = ' + invoiceExternalId);
        System.debug('PaymentAmount = ' + paymentAmount);
        System.debug('PaymentAmountUSD = ' + paymentAmountUSD);
        System.debug('PaymentType = ' + paymentType);
        System.debug('PaymentDate = ' + paymentDate);
        System.debug('ApplyingTransaction = ' + applyingTransaction);
        System.debug('CurrencyIsoCode = ' + currencyIsoCode);
        System.debug('DescriptionNotes = ' + descriptionNotes);
        System.debug('DiscountFee = ' + discountFee);
        System.debug('DiscountFeeUSD = ' + discountFeeUSD);
    }

}