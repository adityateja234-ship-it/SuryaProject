@isTest(seeAllData=false)
public class InvoiceService_Test {
    
    @isTest
    static void testValidInvoiceCreation() {
        
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Description='Test Product';
        p.productCode = 'ABC';
        p.isActive = true;
        p.Rev_Rec_Forecast_Rule__c = 'OE Immediate';
        p.Revenue_Recognition_Rule__c = 'Straight-line, Flexible Dates';
        insert p;
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 240;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        Account acc = new Account(
            Name = 'SFDCPanther.com',
            Rating = 'Hot',
            Industry = 'Banking',
            Phone = '9087654321',
            External_Sync__c = true
        );
        insert acc;
        
        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        
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
        lineItem.OrderId = order.id;
        lineItem.Quantity = 24;
        lineItem.UnitPrice = 240;
        lineItem.ListPrice =  240;
        lineItem.Product2id = p.id;
        lineItem.PricebookEntryId=standardPrice.id;
        insert lineItem;
        
        Order queriedOrder = [SELECT Status, OrderNumber, TotalAmount FROM Order WHERE Id = :order.Id LIMIT 1];
        queriedOrder.Status = 'Ready to Bill';
        update queriedOrder;
        String orderNumber = queriedOrder.OrderNumber;
        
        String jsonBody = '{"externalId": "234356", "orderNumber": ["' + orderNumber + '"], "invoiceAmount": "'+queriedOrder.TotalAmount+'", "invoiceNumber": "INV001", "invoiceDate": "2024-12-01", "invoiceSentDate": "2024-12-02", "descriptionNotes": "Invoice for services", "credit": true}';
        
        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/InvoiceService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        InvoiceService.insertInvoices();
        
        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"statusCode": 200'));
        System.assert(responseBody.contains('"message": "Successfully created"'));
        
        Test.stopTest();
    }
    
    @isTest
    static void testInvalidOrderStatus() {
        
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Description='Test Product';
        p.productCode = 'ABC';
        p.isActive = true;
        p.Rev_Rec_Forecast_Rule__c = 'OE Immediate';
        p.Revenue_Recognition_Rule__c = 'Straight-line, Flexible Dates';
        insert p;
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 240;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        Account acc = new Account(
            Name = 'SFDCPanther.com',
            Rating = 'Hot',
            Industry = 'Banking',
            Phone = '9087654321',
            External_Sync__c = true
        );
        insert acc;
        
        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        
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
        lineItem.Quantity = 24;
        lineItem.UnitPrice = 240;
        lineItem.ListPrice =  240;
        lineItem.Product2id = p.Id;
        lineItem.PricebookEntryId=standardPrice.id;
        insert lineItem;
        
        Order queriedOrder = [SELECT Status, OrderNumber, TotalAmount FROM Order WHERE Id = :order.Id LIMIT 1];
        String orderNumber = queriedOrder.OrderNumber;
        
        String jsonBody = '{"externalId": "234356", "orderNumber": ["' + orderNumber + '"], "invoiceAmount": "'+queriedOrder.TotalAmount+'", "invoiceNumber": "INV001", "invoiceDate": "2024-12-01", "invoiceSentDate": "2024-12-02", "descriptionNotes": "Invoice for services", "credit": true}';
        
        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/InvoiceService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        InvoiceService.insertInvoices();
        
        System.assertEquals(400, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"statusCode": 400'));
        System.assert(responseBody.contains('"message": "Order Status is not Ready to Bill/Invoice Sent in salesforce."'));
        
        Test.stopTest();
    }
    
    @isTest
    static void testInvalidOrder() {
        
        Test.startTest();
        
        String jsonBody = '{"externalId": "234356", "orderNumber": ["00000000"], "invoiceAmount": 10.00, "invoiceNumber": "INV1234", "invoiceDate": "2024-12-01", "invoiceSentDate": "2024-12-02", "description_Notes": "Invoice for services", "credit": true}';
        
        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/InvoiceService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        InvoiceService.insertInvoices();
        
        System.assertEquals(400, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"statusCode": 400'));
        System.assert(responseBody.contains('"message": "Order not available in Salesforce."'));
        
        Test.stopTest();
    }
    
    @isTest
    static void testMissingRequiredFields1() {
        
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Description='Test Product';
        p.productCode = 'ABC';
        p.isActive = true;
        p.Rev_Rec_Forecast_Rule__c = 'OE Immediate';
        p.Revenue_Recognition_Rule__c = 'Straight-line, Flexible Dates';
        insert p;
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 240;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        Account acc = new Account(
            Name = 'SFDCPanther.com',
            Rating = 'Hot',
            Industry = 'Banking',
            Phone = '9087654321',
            External_Sync__c = true
        );
        insert acc;
        
        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        
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
        lineItem.OrderId = order.id;
        lineItem.Quantity = 24;
        lineItem.UnitPrice = 240;
        lineItem.ListPrice =  240;
        lineItem.Product2id = p.id;
        lineItem.PricebookEntryId=standardPrice.id;
        insert lineItem;
        
        Order queriedOrder = [SELECT Status, OrderNumber, TotalAmount FROM Order WHERE Id = :order.Id LIMIT 1];
        queriedOrder.Status = 'Ready to Bill';
        update queriedOrder;
        String orderNumber = queriedOrder.OrderNumber;
        
        String jsonBody = '{"externalId": "", "orderNumber": ["' + orderNumber + '"], "invoiceAmount": "'+queriedOrder.TotalAmount+'", "invoiceNumber": "INV001", "invoiceDate": "2024-12-01", "invoiceSentDate": "2024-12-02", "descriptionNotes": "Payment for services", "credit": true}';
        
        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/InvoiceService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        InvoiceService.insertInvoices();
        
        System.assertEquals(400, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"message": "externalId cant be null or blank"'));
    }
    
    @isTest
    static void testMissingRequiredFields2() {
        
        String jsonBody = '{"externalId": "234356", "orderId": "", "invoiceAmount": null, "invoiceNumber": "", "invoiceDate": "", "invoiceSentDate": "", "description_Notes": "Payment for services", "credit": null}';
        
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        InvoiceService.insertInvoices();
        
        System.assertEquals(400, res.statusCode);
    }
    
    @isTest
    static void testInvalidInvoiceDate() {
        
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Description='Test Product';
        p.productCode = 'ABC';
        p.isActive = true;
        p.Rev_Rec_Forecast_Rule__c = 'OE Immediate';
        p.Revenue_Recognition_Rule__c = 'Straight-line, Flexible Dates';
        insert p;
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 240;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        Account acc = new Account(
            Name = 'SFDCPanther.com',
            Rating = 'Hot',
            Industry = 'Banking',
            Phone = '9087654321',
            External_Sync__c = true
        );
        insert acc;
        
        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        
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
        lineItem.OrderId = order.id;
        lineItem.Quantity = 24;
        lineItem.UnitPrice = 240;
        lineItem.ListPrice =  240;
        lineItem.Product2id = p.id;
        lineItem.PricebookEntryId=standardPrice.id;
        insert lineItem;
        
        Order queriedOrder = [SELECT Status, OrderNumber, TotalAmount FROM Order WHERE Id = :order.Id LIMIT 1];
        queriedOrder.Status = 'Ready to Bill';
        update queriedOrder;
        String orderNumber = queriedOrder.OrderNumber;
        
        String jsonBody = '{"externalId": "234356", "orderNumber": ["' + orderNumber + '"], "invoiceAmount": "'+queriedOrder.TotalAmount+'", "invoiceNumber": "INV001", "invoiceDate": "12-02-2024", "invoiceSentDate": "2024-12-01", "descriptionNotes": "Payment for services", "credit": true}';

        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/InvoiceService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        InvoiceService.insertInvoices();
        
        System.assertEquals(400, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"message": "Invalid invoiceDate format. It must be in yyyy-MM-dd format."'));
    }
    
    @isTest
    static void testInvalidInvoiceSentDate() {
        
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Description='Test Product';
        p.productCode = 'ABC';
        p.isActive = true;
        p.Rev_Rec_Forecast_Rule__c = 'OE Immediate';
        p.Revenue_Recognition_Rule__c = 'Straight-line, Flexible Dates';
        insert p;
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 240;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        Account acc = new Account(
            Name = 'SFDCPanther.com',
            Rating = 'Hot',
            Industry = 'Banking',
            Phone = '9087654321',
            External_Sync__c = true
        );
        insert acc;
        
        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        
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
        lineItem.OrderId = order.id;
        lineItem.Quantity = 24;
        lineItem.UnitPrice = 240;
        lineItem.ListPrice =  240;
        lineItem.Product2id = p.id;
        lineItem.PricebookEntryId=standardPrice.id;
        insert lineItem;
        
        Order queriedOrder = [SELECT Status, OrderNumber, TotalAmount FROM Order WHERE Id = :order.Id LIMIT 1];
        queriedOrder.Status = 'Ready to Bill';
        update queriedOrder;
        String orderNumber = queriedOrder.OrderNumber;
        
        String jsonBody = '{"externalId": "234356", "orderNumber": ["' + orderNumber + '"], "invoiceAmount": "'+queriedOrder.TotalAmount+'", "invoiceNumber": "INV001", "invoiceDate": "2024-12-01", "invoiceSentDate": "12-02-2024", "descriptionNotes": "Invoice for services", "credit": true}';

        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/InvoiceService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        InvoiceService.insertInvoices();
        
        System.assertEquals(400, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"message": "Invalid invoiceSentDate format. It must be in yyyy-MM-dd format."'));
    }
    
    @isTest
    static void testInvoiceUpdate() {
        
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Description='Test Product';
        p.productCode = 'ABC';
        p.isActive = true;
        p.Rev_Rec_Forecast_Rule__c = 'OE Immediate';
        p.Revenue_Recognition_Rule__c = 'Straight-line, Flexible Dates';
        insert p;
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 240;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        Account acc = new Account(
            Name = 'SFDCPanther.com',
            Rating = 'Hot',
            Industry = 'Banking',
            Phone = '9087654321',
            External_Sync__c = true
        );
        insert acc;
        
        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        
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
        lineItem.OrderId = order.id;
        lineItem.Quantity = 24;
        lineItem.UnitPrice = 240;
        lineItem.ListPrice =  240;
        lineItem.Product2id = p.id;
        lineItem.PricebookEntryId=standardPrice.id;
        insert lineItem;
        
        Order queriedOrder = [SELECT OrderNumber, TotalAmount FROM Order WHERE Id = :order.Id LIMIT 1];
        String orderNumber = queriedOrder.OrderNumber;
        
        Invoice__c newInvoice = new Invoice__c(
            External_Id__c = '234356',
            Order__c = order.Id,
            Invoice_Amount__c = 2880.00,
            Invoice_Number__c = 'INV003',
            Invoice_Date__c = Date.valueOf('2024-12-01'),
            Date_Invoice_Sent__c = Date.valueOf('2024-12-02'),
            Credit__c = false
        );
        insert newInvoice;
        
        String jsonBody = '{"externalId": "'+newInvoice.External_Id__c+'", "orderNumber": ["' + orderNumber + '"], "invoiceAmount": 2880.00, "invoiceNumber": "'+newInvoice.Invoice_Number__c+'", "invoiceDate": "2024-12-01", "invoiceSentDate": "2024-12-02", "descriptionNotes": "Updated invoice.", "credit": false}';

        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/InvoiceService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        InvoiceService.insertInvoices();
        
        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"statusCode": 200'));
        System.assert(responseBody.contains('"message": "Successfully Updated"'));
    }
    
    @isTest
    static void testCreditTrueInvoice() {
        
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Description='Test Product';
        p.productCode = 'ABC';
        p.isActive = true;
        p.Rev_Rec_Forecast_Rule__c = 'OE Immediate';
        p.Revenue_Recognition_Rule__c = 'Straight-line, Flexible Dates';
        insert p;
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 240;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        Account acc = new Account(
            Name = 'SFDCPanther.com',
            Rating = 'Hot',
            Industry = 'Banking',
            Phone = '9087654321',
            External_Sync__c = true
        );
        insert acc;
        
        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        
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
        lineItem.OrderId = order.id;
        lineItem.Quantity = 24;
        lineItem.UnitPrice = 240;
        lineItem.ListPrice =  240;
        lineItem.Product2id = p.id;
        lineItem.PricebookEntryId=standardPrice.id;
        insert lineItem;
        
        Order queriedOrder = [SELECT Status, OrderNumber, TotalAmount FROM Order WHERE Id = :order.Id LIMIT 1];
        queriedOrder.Status = 'Ready to Bill';
        update queriedOrder;
        String orderNumber = queriedOrder.OrderNumber;
        
        Invoice__c newInvoice = new Invoice__c(
            External_Id__c = '234356',
            Order__c = order.Id,
            Invoice_Amount__c = queriedOrder.TotalAmount,
            Invoice_Number__c = 'INV003',
            Invoice_Date__c = Date.valueOf('2024-12-01'),
            Date_Invoice_Sent__c = Date.valueOf('2024-12-02'),
            Credit__c = false
        );
        insert newInvoice;
        
        Payment__c newPayment = new Payment__c(
            Netsuite_Id__c = '234357',
            Order__c = order.Id,
            Payment_Amount__c = newInvoice.Invoice_Amount__c,
            Payment_Amount_USD__c = newInvoice.Invoice_Amount__c,
            Applying_Transaction__c = 'PAY003',
            Payment_Date__c = Date.valueOf('2024-12-01'),
            Payment_Type__c = 'Invoice',
            Invoice__c = newInvoice.Id
        );
        insert newPayment;
        
        String jsonBody = '{"externalId": "'+newInvoice.External_Id__c+'", "orderNumber": ["' + orderNumber + '"], "invoiceAmount": "'+newInvoice.Invoice_Amount__c+'", "invoiceNumber": "'+newInvoice.Invoice_Number__c+'", "invoiceDate": "2024-12-01", "invoiceSentDate": "2024-12-02", "descriptionNotes": "Payment for services", "credit": true}';
        
        RestRequest req = new RestRequest();
        req.requestURI = 'services/apexrest/InvoiceService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        InvoiceService.insertInvoices();
        
        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('"statusCode": 200'));
        System.assert(responseBody.contains('"message": "Successfully Updated all payments to zero"'));
    }
    
}