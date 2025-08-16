@isTest(seeAllData=false)
public class PaymentService_Test {
    
    @testSetup
    static void setupTestData() {
        
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Description = 'Test Product';
        p.productCode = 'ABC';
        p.isActive = true;
        p.Rev_Rec_Forecast_Rule__c = 'OE Immediate';
        p.Revenue_Recognition_Rule__c = 'Straight-line, Flexible Dates';
        insert p;
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 10;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice;
        
        Account acc = new Account(
            Name = 'Open Exchange',
            Rating = 'Hot',
            Industry = 'Banking',
            Phone = '0000000000',
            External_Sync__c = true
        );
        insert acc;
        
        Contact newContact = new Contact(FirstName = 'xyzFirst', LastName = 'XyZLast');
        insert newContact;
    }
    
    @isTest
    static void testValidPaymentCreation() {
        
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
        Contact cc = [SELECT Id FROM Contact WHERE FirstName = 'xyzFirst' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Open Exchange' LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'Test Product' LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id FROM PricebookEntry WHERE Product2Id = :p.Id LIMIT 1];
        
        Test.startTest();
        Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'New',
            PriceBook2Id = Test.getStandardPricebookId(),
            Region__c='APAC', 
            Requester_Contact__c=cc.Id, 
            Meeting_Complexity__c='2 - Medium', 
            Start_Date_Time__c=datetime.newInstance(2022, 12, 18), 
            End_Date_Time__c=datetime.newInstance(2022, 12, 20), 
            Event_Type_OE_Defined__c='Virtual Conference', 
            Name='Test Order Future',
            Order_TimeZone__c='(GMT+5:30) India', 
            CurrencyIsoCode='USD',
            Description='Test Description',
            EventNotes__c='Test Notes',
            No_Sync_to_External_Systems__c = false,
            Business_Line_Exception__c = 'OE Connect'
        );
        insert order;
        
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.Id;
        lineItem.Quantity = 5;
        lineItem.UnitPrice = 10;
        lineItem.ListPrice =  10;
        lineItem.Product2id = p.Id;
        lineItem.PricebookEntryId = standardPrice.Id;
        insert lineItem;
        
        Order queriedOrder = [SELECT Id, Status, OrderNumber, TotalAmount FROM Order WHERE Id = :order.Id LIMIT 1];
        queriedOrder.Status = 'Ready to Bill';
        queriedOrder.Id = queriedOrder.Id;
        update queriedOrder;
        String orderNumber = queriedOrder.OrderNumber;
        
        Invoice__c inv = new Invoice__c(
            Order__c = order.Id,
            Date_Invoice_Sent__c = System.today(),
            Invoice_Amount__c = queriedOrder.TotalAmount,
            External_Id__c = '901033',
            Credit__c = false,
            Invoice_Number__c = 'INV15323'
        );
        insert inv;
        
        String jsonBody = '{"externalId": "234356", "orderNumbers": ["' + orderNumber + '"], "paymentAmountUSD": 40.00, "invoiceExternalId": "'+inv.External_Id__c+'", "paymentAmount": 40.00, "invoiceNumber": "'+inv.Invoice_Number__c+'", "paymentType": "Payment", "paymentDate": "2024-12-02", "applyingTransaction": "PAY12345", "currencyIsoCode": "USD", "discountFee": 10.00, "discountFeeUSD": 10.00, "descriptionNotes": "Payment for services"}';
        
        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/PaymentService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        PaymentService.insertPayments();
        
        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"statusCode": 200'));
        System.assert(responseBody.contains('"message": "Successfully created"'));
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testInvalidOrderStatus() {
        
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
        Contact cc = [SELECT Id FROM Contact WHERE FirstName = 'xyzFirst' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Open Exchange' LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'Test Product' LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id FROM PricebookEntry WHERE Product2Id = :p.Id LIMIT 1];
        
        Test.startTest();
        
        Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'New',
            PriceBook2Id = Test.getStandardPricebookId(),
            Region__c = 'APAC', 
            Requester_Contact__c = cc.Id, 
            Meeting_Complexity__c = '2 - Medium', 
            Start_Date_Time__c = datetime.newInstance(2022, 12, 18), 
            End_Date_Time__c = datetime.newInstance(2022, 12, 20), 
            Event_Type_OE_Defined__c = 'Virtual Conference', 
            Name = 'Test Order Future',
            Order_TimeZone__c = '(GMT+5:30) India', 
            CurrencyIsoCode = 'USD',
            Description = 'Test Description',
            EventNotes__c = 'Test Notes',
            No_Sync_to_External_Systems__c = false,
            Business_Line_Exception__c = 'OE Connect'
        );
        insert order;
        
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.Id;
        lineItem.Quantity = 5;
        lineItem.UnitPrice = 10;
        lineItem.ListPrice = 10;
        lineItem.Product2id = p.Id;
        lineItem.PricebookEntryId = standardPrice.Id;
        insert lineItem;
        
        Order queriedOrder = [SELECT Status, OrderNumber, TotalAmount FROM Order WHERE Id = :order.Id LIMIT 1];
        String orderNumber = queriedOrder.OrderNumber;
        
        Invoice__c inv = new Invoice__c(
            Order__c = order.Id,
            Date_Invoice_Sent__c = System.today(),
            Invoice_Amount__c = queriedOrder.TotalAmount,
            External_Id__c = '1431132',
            Credit__c = false,
            Invoice_Number__c = 'INV15323'
        );
        insert inv;
        
        String jsonBody = '{"externalId": "000000", "orderNumbers": ["' + orderNumber + '"], "paymentAmountUSD": 40.00, "invoiceExternalId": "'+inv.External_Id__c+'", "paymentAmount": 40.00, "invoiceNumber": "'+inv.Invoice_Number__c+'", "paymentType": "Invoice", "paymentDate": "2024-12-02", "applyingTransaction": "PAY12345", "currencyIsoCode": "USD", "discountFee": 10.00, "discountFeeUSD": 10.00, "descriptionNotes": "Payment for services"}';
        
        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/PaymentService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        PaymentService.insertPayments();
        
        System.assertEquals(400, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"statusCode": 400'));
        
        Test.stopTest();
    }

    @isTest
    static void testMissingRequiredFields1() {
        
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
        Contact cc = [SELECT Id FROM Contact WHERE FirstName = 'xyzFirst' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Open Exchange' LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'Test Product' LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id FROM PricebookEntry WHERE Product2Id = :p.Id LIMIT 1];
        
        Test.startTest();
        
        Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'New',
            PriceBook2Id = Test.getStandardPricebookId(),
            Region__c = 'APAC', 
            Requester_Contact__c = cc.Id, 
            Meeting_Complexity__c = '2 - Medium', 
            Start_Date_Time__c = datetime.newInstance(2022, 12, 18), 
            End_Date_Time__c = datetime.newInstance(2022, 12, 20), 
            Event_Type_OE_Defined__c = 'Virtual Conference', 
            Name = 'Test Order Future',
            Order_TimeZone__c = '(GMT+5:30) India', 
            CurrencyIsoCode = 'USD',
            Description = 'Test Description',
            EventNotes__c = 'Test Notes',
            No_Sync_to_External_Systems__c = false,
            Business_Line_Exception__c = 'OE Connect'
        );
        insert order;
        
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.Id;
        lineItem.Quantity = 5;
        lineItem.UnitPrice = 10;
        lineItem.ListPrice = 10;
        lineItem.Product2id = p.Id;
        lineItem.PricebookEntryId = standardPrice.Id;
        insert lineItem;
        
        Order queriedOrder = [SELECT Status, OrderNumber, TotalAmount FROM Order WHERE Id = :order.Id LIMIT 1];
        queriedOrder.Status = 'Ready to Bill';
        update queriedOrder;
        
        String orderNumber = queriedOrder.OrderNumber;
        
        Invoice__c inv = new Invoice__c(
            Order__c = order.Id,
            Date_Invoice_Sent__c = System.today(),
            Invoice_Amount__c = 50.00,
            External_Id__c = '1431132',
            Credit__c = false,
            Invoice_Number__c = 'INV15323'
        );
        insert inv;
        
        String jsonBody = '{"externalId": "", "orderNumbers": ["' + orderNumber + '"], "paymentAmountUSD": 40.00, "invoiceExternalId": "'+inv.External_Id__c+'", "paymentAmount": 40.00, "invoiceNumber": "'+inv.Invoice_Number__c+'", "paymentType": "Credit Memos", "paymentDate": "2024-12-02", "applyingTransaction": "PAY12345", "currencyIsoCode": "USD", "discountFee": 0, "discountFeeUSD": 0, "descriptionNotes": "Payment for services"}';
        
        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/PaymentService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        PaymentService.insertPayments();
        
        System.assertEquals(400, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"statusCode": 400'));
        System.assert(responseBody.contains('"message": "externalId cant be null or blank"'));
        
        Test.stopTest();
    }
    
    @isTest
    static void testMissingRequiredFields2() {
        
        String jsonBody = '{"externalId": "000000", "orderId": "", "paymentAmountUSD": null, "invoiceExternalId": "", "paymentAmount": null, "invoiceNumber": "", "paymentType": "", "paymentDate": "", "applyingTransaction": "", "currencyIsoCode": "", "discountFee": null, "discountFeeUSD": null, "description_Notes": ""}';
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/PaymentService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        PaymentService.insertPayments();
        
        System.assertEquals(400, res.statusCode);
        
        Test.stopTest();
    }
    
    @isTest
    static void testInvalidPaymentdate() {
        
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
        Contact cc = [SELECT Id FROM Contact WHERE FirstName = 'xyzFirst' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Open Exchange' LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'Test Product' LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id FROM PricebookEntry WHERE Product2Id = :p.Id LIMIT 1];
        
        Test.startTest();
        
        Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'New',
            PriceBook2Id = Test.getStandardPricebookId(),
            Region__c = 'APAC', 
            Requester_Contact__c = cc.Id, 
            Meeting_Complexity__c = '2 - Medium', 
            Start_Date_Time__c = datetime.newInstance(2022, 12, 18), 
            End_Date_Time__c = datetime.newInstance(2022, 12, 20), 
            Event_Type_OE_Defined__c = 'Virtual Conference', 
            Name = 'Test Order Future',
            Order_TimeZone__c = '(GMT+5:30) India', 
            CurrencyIsoCode = 'USD',
            Description = 'Test Description',
            EventNotes__c = 'Test Notes',
            No_Sync_to_External_Systems__c = false,
            Business_Line_Exception__c = 'OE Connect'
        );
        insert order;
        
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.Id;
        lineItem.Quantity = 5;
        lineItem.UnitPrice = 10;
        lineItem.ListPrice = 10;
        lineItem.Product2id = p.Id;
        lineItem.PricebookEntryId = standardPrice.Id;
        insert lineItem;
        
        Order queriedOrder = [SELECT Status, OrderNumber, TotalAmount FROM Order WHERE Id = :order.Id LIMIT 1];
        queriedOrder.Status = 'Ready to Bill';
        update queriedOrder;
        
        String orderNumber = queriedOrder.OrderNumber;
        
        Invoice__c inv = new Invoice__c(
            Order__c = order.Id,
            Date_Invoice_Sent__c = System.today(),
            Invoice_Amount__c = 50.00,
            External_Id__c = '1431132',
            Credit__c = false,
            Invoice_Number__c = 'INV15323'
        );
        insert inv;
        
        String jsonBody = '{"externalId": "000000", "orderNumbers": ["' + orderNumber + '"], "paymentAmountUSD": 40.00, "invoiceExternalId": "'+inv.External_Id__c+'", "paymentAmount": 40.00, "invoiceNumber": "'+inv.Invoice_Number__c+'", "paymentType": "Credit Memos", "paymentDate": "12-02-2024", "applyingTransaction": "PAY12345", "currencyIsoCode": "USD", "discountFee": 0, "discountFeeUSD": 0, "descriptionNotes": "Payment for services"}';
        
        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/PaymentService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        PaymentService.insertPayments();
        
        System.assertEquals(400, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"statusCode": 400'));
        System.assert(responseBody.contains('"message": "Invalid paymentDate format. It must be in yyyy-MM-dd format."'));
        
        Test.stopTest();
    }
    
    @isTest
    static void testInvalidPaymentAmount() {
        
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
        Contact cc = [SELECT Id FROM Contact WHERE FirstName = 'xyzFirst' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Open Exchange' LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'Test Product' LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id FROM PricebookEntry WHERE Product2Id = :p.Id LIMIT 1];
        
        Test.startTest();
        
        Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'New',
            PriceBook2Id = Test.getStandardPricebookId(),
            Region__c = 'APAC', 
            Requester_Contact__c = cc.Id, 
            Meeting_Complexity__c = '2 - Medium', 
            Start_Date_Time__c = datetime.newInstance(2022, 12, 18), 
            End_Date_Time__c = datetime.newInstance(2022, 12, 20), 
            Event_Type_OE_Defined__c = 'Virtual Conference', 
            Name = 'Test Order Future',
            Order_TimeZone__c = '(GMT+5:30) India', 
            CurrencyIsoCode = 'USD',
            Description = 'Test Description',
            EventNotes__c = 'Test Notes',
            No_Sync_to_External_Systems__c = false,
            Business_Line_Exception__c = 'OE Connect'
        );
        insert order;
        
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.Id;
        lineItem.Quantity = 5;
        lineItem.UnitPrice = 10;
        lineItem.ListPrice = 10;
        lineItem.Product2id = p.Id;
        lineItem.PricebookEntryId = standardPrice.Id;
        insert lineItem;
        
        Order queriedOrder = [SELECT Status, OrderNumber, TotalAmount FROM Order WHERE Id = :order.Id LIMIT 1];
        queriedOrder.Status = 'Ready to Bill';
        update queriedOrder;
        
        String orderNumber = queriedOrder.OrderNumber;
        
        Invoice__c inv = new Invoice__c(
            Order__c = order.Id,
            Date_Invoice_Sent__c = System.today(),
            Invoice_Amount__c = 50.00,
            External_Id__c = '1431132',
            Credit__c = false,
            Invoice_Number__c = 'INV15323'
        );
        insert inv;
        
        String jsonBody = '{"externalId": "000000", "orderNumbers": ["' + orderNumber + '"], "paymentAmountUSD": -40.00, "invoiceExternalId": "'+inv.External_Id__c+'", "paymentAmount": -40.00, "invoiceNumber": "'+inv.Invoice_Number__c+'", "paymentType": "Credit Memos", "paymentDate": "2024-12-02", "applyingTransaction": "PAY12345", "currencyIsoCode": "USD", "discountFee": 0, "discountFeeUSD": 0, "descriptionNotes": "Payment for services"}';
        
        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/PaymentService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        PaymentService.insertPayments();
        
        System.assertEquals(400, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"statusCode": 400'));
        System.assert(responseBody.contains('"message": "Payment amount must be positive."'));
        
        Test.stopTest();
    }
    
    @isTest
    static void testPaymentUpdate() {
        
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
        Contact cc = [SELECT Id FROM Contact WHERE FirstName = 'xyzFirst' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Open Exchange' LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'Test Product' LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id FROM PricebookEntry WHERE Product2Id = :p.Id LIMIT 1];
        
        Test.startTest();
        
        Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'New',
            PriceBook2Id = Test.getStandardPricebookId(),
            Region__c = 'APAC', 
            Requester_Contact__c = cc.Id, 
            Meeting_Complexity__c = '2 - Medium', 
            Start_Date_Time__c = datetime.newInstance(2022, 12, 18), 
            End_Date_Time__c = datetime.newInstance(2022, 12, 20), 
            Event_Type_OE_Defined__c = 'Virtual Conference', 
            Name = 'Test Order Future',
            Order_TimeZone__c = '(GMT+5:30) India', 
            CurrencyIsoCode = 'USD',
            Description = 'Test Description',
            EventNotes__c = 'Test Notes',
            No_Sync_to_External_Systems__c = false,
            Business_Line_Exception__c = 'OE Connect'
        );
        insert order;
        
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.Id;
        lineItem.Quantity = 5;
        lineItem.UnitPrice = 10;
        lineItem.ListPrice = 10;
        lineItem.Product2id = p.Id;
        lineItem.PricebookEntryId = standardPrice.Id;
        insert lineItem;
        
        Order queriedOrder = [SELECT Status, OrderNumber, TotalAmount FROM Order WHERE Id = :order.Id LIMIT 1];
        queriedOrder.Status = 'Ready to Bill';
        update queriedOrder;
        
        String orderNumber = queriedOrder.OrderNumber;
        
        Invoice__c inv = new Invoice__c(
            Order__c = order.Id,
            Date_Invoice_Sent__c = System.today(),
            Invoice_Amount__c = queriedOrder.TotalAmount,
            External_Id__c = '1431132',
            Credit__c = false,
            Invoice_Number__c = 'INV15323'
        );
        insert inv;
        
        Payment__c newPayment = new Payment__c(
            Netsuite_Id__c = '234356',
            Order__c = order.Id,
            Payment_Amount__c = 40.00,
            Payment_Amount_USD__c = 40.00,
            Applying_Transaction__c = 'PAY003',
            Payment_Type__c = 'Invoice',
            Payment_Date__c = Date.valueOf('2024-12-01'),
            Invoice__c = inv.Id
        );
        insert newPayment;
        
        Payment__c newDiscountPayment = new Payment__c(
            Netsuite_Id__c = newPayment.Netsuite_Id__c,
            Order__c = order.Id,
            Payment_Amount__c = 10.00,
            Payment_Amount_USD__c = 10.00,
            Applying_Transaction__c = newPayment.Applying_Transaction__c,
            Payment_Type__c = null,
            Payment_Date__c = Date.valueOf('2024-12-01'),
            Invoice__c = inv.Id
        );
        insert newDiscountPayment;
        
        String jsonBody = '{"externalId": "'+newPayment.Netsuite_Id__c+'", "orderNumbers": ["' + orderNumber + '"], "paymentAmountUSD": 45.00, "invoiceExternalId": "'+inv.External_Id__c+'", "paymentAmount": 45.00, "invoiceNumber": "'+inv.Invoice_Number__c+'", "paymentType": "Payment", "paymentDate": "2024-12-02", "applyingTransaction": "'+newPayment.Applying_Transaction__c+'", "currencyIsoCode": "USD", "discountFee": 5.00, "discountFeeUSD": 5.00, "descriptionNotes": "Payment for services"}';
        
        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/PaymentService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        PaymentService.insertPayments();
        
        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"statusCode": 200'));
        System.assert(responseBody.contains('"message": "Successfully Updated"'));
        
        Test.stopTest();
    }
    
    @isTest
    static void testPaymentUpdateDeposit() {
        
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
        Contact cc = [SELECT Id FROM Contact WHERE FirstName = 'xyzFirst' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Open Exchange' LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'Test Product' LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id FROM PricebookEntry WHERE Product2Id = :p.Id LIMIT 1];
        
        Test.startTest();
        
        Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'New',
            PriceBook2Id = Test.getStandardPricebookId(),
            Region__c = 'APAC', 
            Requester_Contact__c = cc.Id, 
            Meeting_Complexity__c = '2 - Medium', 
            Start_Date_Time__c = datetime.newInstance(2022, 12, 18), 
            End_Date_Time__c = datetime.newInstance(2022, 12, 20), 
            Event_Type_OE_Defined__c = 'Virtual Conference', 
            Name = 'Test Order Future',
            Order_TimeZone__c = '(GMT+5:30) India', 
            CurrencyIsoCode = 'USD',
            Description = 'Test Description',
            EventNotes__c = 'Test Notes',
            No_Sync_to_External_Systems__c = false,
            Business_Line_Exception__c = 'OE Connect'
        );
        insert order;
        
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.Id;
        lineItem.Quantity = 5;
        lineItem.UnitPrice = 10;
        lineItem.ListPrice = 10;
        lineItem.Product2id = p.Id;
        lineItem.PricebookEntryId = standardPrice.Id;
        insert lineItem;
        
        Order queriedOrder = [SELECT Status, OrderNumber, TotalAmount FROM Order WHERE Id = :order.Id LIMIT 1];
        queriedOrder.Status = 'Ready to Bill';
        update queriedOrder;
        
        String orderNumber = queriedOrder.OrderNumber;
        
        Invoice__c inv = new Invoice__c(
            Order__c = order.Id,
            Date_Invoice_Sent__c = System.today(),
            Invoice_Amount__c = 50.00,
            External_Id__c = '1431132',
            Credit__c = false,
            Invoice_Number__c = 'INV15323'
        );
        insert inv;
        
        Payment__c newPayment = new Payment__c(
            Netsuite_Id__c = '234356',
            Order__c = order.Id,
            Payment_Amount__c = 40.00,
            Payment_Amount_USD__c = 40.00,
            Applying_Transaction__c = 'PAY003',
            Payment_Date__c = Date.valueOf('2024-12-01'),
            Payment_Type__c = 'Deposit',
            Invoice__c = inv.Id
        );
        insert newPayment;
        
        String jsonBody = '{"externalId": "'+newPayment.Netsuite_Id__c+'", "orderNumbers": ["' + orderNumber + '"], "paymentAmountUSD": "'+inv.Invoice_Amount__c+'", "invoiceExternalId": "'+inv.External_Id__c+'", "paymentAmount": "'+inv.Invoice_Amount__c+'", "invoiceNumber": "'+inv.Invoice_Number__c+'", "paymentType": "'+newPayment.Payment_Type__c+'", "paymentDate": "2024-12-02", "applyingTransaction": "'+newPayment.Applying_Transaction__c+'", "currencyIsoCode": "USD", "discountFee": 0, "discountFeeUSD": 0, "descriptionNotes": "Test for deposit"}';
        
        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/PaymentService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        PaymentService.insertPayments();
        
        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"statusCode": 200'));
        System.assert(responseBody.contains('"message": "Successfully Updated"'));
        
        Test.stopTest();
    }
    
    @isTest
    static void testPaymentUpdateJournal() {
        
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
        Contact cc = [SELECT Id FROM Contact WHERE FirstName = 'xyzFirst' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Open Exchange' LIMIT 1];
        Product2 p = [SELECT Id FROM Product2 WHERE Name = 'Test Product' LIMIT 1];
        PricebookEntry standardPrice = [SELECT Id FROM PricebookEntry WHERE Product2Id = :p.Id LIMIT 1];
        
        Test.startTest();
        
        Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'New',
            PriceBook2Id = Test.getStandardPricebookId(),
            Region__c = 'APAC', 
            Requester_Contact__c = cc.Id, 
            Meeting_Complexity__c = '2 - Medium', 
            Start_Date_Time__c = datetime.newInstance(2022, 12, 18), 
            End_Date_Time__c = datetime.newInstance(2022, 12, 20), 
            Event_Type_OE_Defined__c = 'Virtual Conference', 
            Name = 'Test Order Future',
            Order_TimeZone__c = '(GMT+5:30) India', 
            CurrencyIsoCode = 'USD',
            Description = 'Test Description',
            EventNotes__c = 'Test Notes',
            No_Sync_to_External_Systems__c = false,
            Business_Line_Exception__c = 'OE Connect'
        );
        insert order;
        
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.Id;
        lineItem.Quantity = 5;
        lineItem.UnitPrice = 10;
        lineItem.ListPrice = 10;
        lineItem.Product2id = p.Id;
        lineItem.PricebookEntryId = standardPrice.Id;
        insert lineItem;
        
        Order queriedOrder = [SELECT Status, OrderNumber, TotalAmount FROM Order WHERE Id = :order.Id LIMIT 1];
        queriedOrder.Status = 'Ready to Bill';
        update queriedOrder;
        
        String orderNumber = queriedOrder.OrderNumber;
        
        Invoice__c inv = new Invoice__c(
            Order__c = order.Id,
            Date_Invoice_Sent__c = System.today(),
            Invoice_Amount__c = 50.00,
            External_Id__c = '1431132',
            Credit__c = false,
            Invoice_Number__c = 'INV15323'
        );
        insert inv;
        
        Payment__c newPayment = new Payment__c(
            Netsuite_Id__c = '234356',
            Order__c = order.Id,
            Payment_Amount__c = 40.00,
            Payment_Amount_USD__c = 40.00,
            Applying_Transaction__c = 'PAY003',
            Payment_Date__c = Date.valueOf('2024-12-01'),
            Payment_Type__c = 'Journal',
            Invoice__c = inv.Id
        );
        insert newPayment;
        
        String jsonBody = '{"externalId": "'+newPayment.Netsuite_Id__c+'", "orderNumbers": ["' + orderNumber + '"], "paymentAmountUSD": "'+inv.Invoice_Amount__c+'", "invoiceExternalId": "'+inv.External_Id__c+'", "paymentAmount": "'+inv.Invoice_Amount__c+'", "invoiceNumber": "'+inv.Invoice_Number__c+'", "paymentType": "'+newPayment.Payment_Type__c+'", "paymentDate": "2024-12-02", "applyingTransaction": "'+newPayment.Applying_Transaction__c+'", "currencyIsoCode": "USD", "discountFee": 0, "discountFeeUSD": 0, "descriptionNotes": "Test for deposit"}';
        
        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/PaymentService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        PaymentService.insertPayments();
        
        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"statusCode": 200'));
        System.assert(responseBody.contains('"message": "Successfully Updated"'));
        
        Test.stopTest();
    }
    
}