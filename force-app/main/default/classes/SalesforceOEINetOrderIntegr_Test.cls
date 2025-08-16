@isTest(seeAllData=true)
public class SalesforceOEINetOrderIntegr_Test {
    
    @isTest
    static void testCreateWithAuthSuccess() {
        
        Account testAccount = new Account(
            Name = 'Test Account 01',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'United States',
            ShippingCountry = 'United States'
        );
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'FirstTest',
            LastName = 'LastName',
            Contact_Status__c = 'Current',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Description = 'Test Description',
            Family = 'Meeting',
            OE_Product_Name__c = 'Test OE Product',
            IsActive = true,
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Product_Ticket_Number__c = 'NS-1001'
        );
        insert testProduct;
        
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
        
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100.00,
            IsActive = TRUE
        );
        insert pricebookEntry;
        
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'New',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Pricebook2Id = standardPricebook.Id,
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id
        );
        insert testOrder;
        
        OrderItem orderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100.00
        );
        insert orderItem;
        
        Order updateOrder = new Order(
            Id = testOrder.Id,
            Status = 'Ready to Bill',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Billing_Notes__c = 'Testing notes'
        );
        update updateOrder;
        
        String crtNS = 'false';
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SalesforceOEINetsuiteOrderIntegration orderIntegrationJob = new SalesforceOEINetsuiteOrderIntegration(new List<Order>{updateOrder}, crtNS);
        System.enqueueJob(orderIntegrationJob);
        
        Test.stopTest();
        
        Order updatedOrder = [SELECT Id, Netsuite_Id__c, Netsuite_Creation_Message__c FROM Order WHERE Id = :updateOrder.Id];
        
        System.assertEquals(updatedOrder.Netsuite_Id__c, null, 'The Netsuite_Id__c should have been populated');
        
        OrderItem updatedOrderItem = [SELECT Id, Product2Id FROM OrderItem WHERE OrderId = :updateOrder.Id LIMIT 1];
        System.assertEquals(updatedOrderItem.Product2Id, testProduct.Id, 'Product2Id on OrderItem should match the created product');
    }
    
    @isTest
    static void testCreateWithAuthFailure() {
        
        Account testAccount = new Account(
            Name = 'Test Account 01',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'United States',
            ShippingCountry = 'United States'
        );
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'FirstTest',
            LastName = 'LastName',
            Contact_Status__c = 'Current',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Description = 'Test Description',
            Family = 'Meeting',
            OE_Product_Name__c = 'Test OE Product',
            IsActive = true,
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Product_Ticket_Number__c = 'NS-1001'
        );
        insert testProduct;
        
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
        
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100.00,
            IsActive = TRUE
        );
        insert pricebookEntry;
        
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'New',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Pricebook2Id = standardPricebook.Id,
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id
        );
        insert testOrder;
        
        OrderItem orderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100.00
        );
        insert orderItem;
        
        Order updateOrder = new Order(
            Id = testOrder.Id,
            Status = 'Ready to Bill',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Billing_Notes__c = 'Testing notes'
        );
        update updateOrder;
        
        String crtNS = 'false';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse401());
        
        Test.startTest();
        SalesforceOEINetsuiteOrderIntegration orderIntegrationJob = new SalesforceOEINetsuiteOrderIntegration(new List<Order>{updateOrder}, crtNS);
        System.enqueueJob(orderIntegrationJob);
        Test.stopTest();
        
        Order updatedOrder = [SELECT Id, Netsuite_Creation_Message__c FROM Order WHERE Id = :updateOrder.Id];
        
        System.assert(updatedOrder.Netsuite_Creation_Message__c.contains('Authentication failed at Creation'),'The error message should contain "Authentication failed at Creation"');
    }
    
    @isTest
    static void testOrderCreationSuccess() {
        
        Account testAccount = new Account(
            Name = 'Test Account 01',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'United States',
            ShippingCountry = 'United States'
        );
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'FirstTest',
            LastName = 'LastName',
            Contact_Status__c = 'Current',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Description = 'Test Description',
            Family = 'Meeting',
            OE_Product_Name__c = 'Test OE Product',
            IsActive = true,
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Product_Ticket_Number__c = 'NS-1001'
        );
        insert testProduct;
        
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
        
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100.00,
            IsActive = TRUE
        );
        insert pricebookEntry;
        
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'New',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Pricebook2Id = standardPricebook.Id,
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id
        );
        insert testOrder;
        
        OrderItem orderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100.00
        );
        insert orderItem;
        
        Order updateOrder = new Order(
            Id = testOrder.Id,
            Status = 'Ready to Bill',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Billing_Notes__c = 'Testing notes'
        );
        update updateOrder;
        
        String crtNS = 'false';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200WithCreation());
        
        Test.startTest();
        SalesforceOEINetsuiteOrderIntegration orderIntegrationJob = new SalesforceOEINetsuiteOrderIntegration(new List<Order>{updateOrder}, crtNS);
        System.enqueueJob(orderIntegrationJob);
        Test.stopTest();
        
        Order updatedOrder = [SELECT Id, Netsuite_Id__c FROM Order WHERE Id = :updateOrder.Id];
        
        System.assertEquals('82028',updatedOrder.Netsuite_Id__c, 'Success');
    }
    
    @isTest
    static void testOrderCreationFailure() {
        
        Account testAccount = new Account(
            Name = 'Test Account 01',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'United States',
            ShippingCountry = 'United States'
        );
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'FirstTest',
            LastName = 'LastName',
            Contact_Status__c = 'Current',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Description = 'Test Description',
            Family = 'Meeting',
            OE_Product_Name__c = 'Test OE Product',
            IsActive = true,
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Product_Ticket_Number__c = 'NS-1001'
        );
        insert testProduct;
        
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
        
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100.00,
            IsActive = TRUE
        );
        insert pricebookEntry;
        
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'New',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Pricebook2Id = standardPricebook.Id,
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id
        );
        insert testOrder;
        
        OrderItem orderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100.00
        );
        insert orderItem;
        
        Order updateOrder = new Order(
            Id = testOrder.Id,
            Status = 'Ready to Bill',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Billing_Notes__c = 'Testing notes'
        );
        update updateOrder;
        
        String crtNS = 'false';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200WithCreationFailure());
        
        Test.startTest();
        SalesforceOEINetsuiteOrderIntegration orderIntegrationJob = new SalesforceOEINetsuiteOrderIntegration(new List<Order>{updateOrder}, crtNS);
        System.enqueueJob(orderIntegrationJob);
        Test.stopTest();
        
        Order updatedOrder = [SELECT Id, Netsuite_Creation_Message__c FROM Order WHERE Id = :updateOrder.Id];
        
        System.assert(updatedOrder.Netsuite_Creation_Message__c.contains('Creation failed'),'The error message should contain "Creation failed"');
    }
    
    @isTest
    static void testUpdateWithAuthSuccess() {
        
        Account testAccount = new Account(
            Name = 'Test Account 01',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'United States',
            ShippingCountry = 'United States'
        );
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'FirstTest',
            LastName = 'LastName',
            Contact_Status__c = 'Current',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Description = 'Test Description',
            Family = 'Meeting',
            OE_Product_Name__c = 'Test OE Product',
            IsActive = true,
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Product_Ticket_Number__c = 'NS-1001'
        );
        insert testProduct;
        
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
        
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100.00,
            IsActive = TRUE
        );
        insert pricebookEntry;
        
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'New',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Pricebook2Id = standardPricebook.Id,
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id
        );
        insert testOrder;
        
        OrderItem orderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100.00
        );
        insert orderItem;
        
        Order updateOrder = new Order(
            Id = testOrder.Id,
            Status = 'Ready to Bill',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Billing_Notes__c = 'Testing notes'
        );
        update updateOrder;
        
        String crtNS = 'false';
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SalesforceOEINSOrderIntegrationUpdate orderIntegrationJob = new SalesforceOEINSOrderIntegrationUpdate(new List<Order>{updateOrder}, crtNS);
        System.enqueueJob(orderIntegrationJob);
        
        Test.stopTest();
        
        Order updatedOrder = [SELECT Id, Netsuite_Id__c, Netsuite_Creation_Message__c FROM Order WHERE Id = :updateOrder.Id];
        
        System.assertEquals(updatedOrder.Netsuite_Id__c, null, 'The Netsuite_Id__c should have been populated');
        
        OrderItem updatedOrderItem = [SELECT Id, Product2Id FROM OrderItem WHERE OrderId = :updateOrder.Id LIMIT 1];
        System.assertEquals(updatedOrderItem.Product2Id, testProduct.Id, 'Product2Id on OrderItem should match the created product');
    }
    
    @isTest
    static void testUpdateWithAuthFailure() {
        
        Account testAccount = new Account(
            Name = 'Test Account 01',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'United States',
            ShippingCountry = 'United States'
        );
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'FirstTest',
            LastName = 'LastName',
            Contact_Status__c = 'Current',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Description = 'Test Description',
            Family = 'Meeting',
            OE_Product_Name__c = 'Test OE Product',
            IsActive = true,
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Product_Ticket_Number__c = 'NS-1001'
        );
        insert testProduct;
        
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
        
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100.00,
            IsActive = TRUE
        );
        insert pricebookEntry;
        
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'New',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Pricebook2Id = standardPricebook.Id,
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id
        );
        insert testOrder;
        
        OrderItem orderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100.00
        );
        insert orderItem;
        
        Order updateOrder = new Order(
            Id = testOrder.Id,
            Status = 'Ready to Bill',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Billing_Notes__c = 'Testing notes'
        );
        update updateOrder;
        
        String crtNS = 'false';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse401());
        
        Test.startTest();
        SalesforceOEINSOrderIntegrationUpdate orderIntegrationJob = new SalesforceOEINSOrderIntegrationUpdate(new List<Order>{updateOrder}, crtNS);
        System.enqueueJob(orderIntegrationJob);
        Test.stopTest();
        
        Order updatedOrder = [SELECT Id, Netsuite_Creation_Message__c FROM Order WHERE Id = :updateOrder.Id];
        
        System.assert(updatedOrder.Netsuite_Creation_Message__c.contains('Authentication failed at Updation'),'The error message should contain "Authentication failed at Updation"');
    }
    
    @isTest
    static void testOrderUpdationSuccess() {
        
        Account testAccount = new Account(
            Name = 'Test Account 01',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'United States',
            ShippingCountry = 'United States'
        );
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'FirstTest',
            LastName = 'LastName',
            Contact_Status__c = 'Current',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Description = 'Test Description',
            Family = 'Meeting',
            OE_Product_Name__c = 'Test OE Product',
            IsActive = true,
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Product_Ticket_Number__c = 'NS-1001'
        );
        insert testProduct;
        
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
        
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100.00,
            IsActive = TRUE
        );
        insert pricebookEntry;
        
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'New',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Pricebook2Id = standardPricebook.Id,
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id
        );
        insert testOrder;
        
        OrderItem orderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100.00
        );
        insert orderItem;
        
        Order updateOrder = new Order(
            Id = testOrder.Id,
            Status = 'Ready to Bill',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Billing_Notes__c = 'Testing notes'
        );
        update updateOrder;
        
        String crtNS = 'false';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200WithCreation());
        
        Test.startTest();
        SalesforceOEINSOrderIntegrationUpdate orderIntegrationJob = new SalesforceOEINSOrderIntegrationUpdate(new List<Order>{updateOrder}, crtNS);
        System.enqueueJob(orderIntegrationJob);
        Test.stopTest();
        
        Order updatedOrder = [SELECT Id, Netsuite_Id__c FROM Order WHERE Id = :updateOrder.Id];
        
        System.assertEquals('82028',updatedOrder.Netsuite_Id__c, 'Success');
    }
    
    @isTest
    static void testOrderUpdationFailure() {
        
        Account testAccount = new Account(
            Name = 'Test Account 01',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'United States',
            ShippingCountry = 'United States'
        );
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'FirstTest',
            LastName = 'LastName',
            Contact_Status__c = 'Current',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Description = 'Test Description',
            Family = 'Meeting',
            OE_Product_Name__c = 'Test OE Product',
            IsActive = true,
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Product_Ticket_Number__c = 'NS-1001'
        );
        insert testProduct;
        
        Pricebook2 standardPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];
        
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100.00,
            IsActive = TRUE
        );
        insert pricebookEntry;
        
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'New',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Pricebook2Id = standardPricebook.Id,
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id
        );
        insert testOrder;
        
        OrderItem orderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100.00
        );
        insert orderItem;
        
        Order updateOrder = new Order(
            Id = testOrder.Id,
            Status = 'Ready to Bill',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Billing_Notes__c = 'Testing notes'
        );
        update updateOrder;
        
        String crtNS = 'false';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200WithCreationFailure());
        
        Test.startTest();
        SalesforceOEINSOrderIntegrationUpdate orderIntegrationJob = new SalesforceOEINSOrderIntegrationUpdate(new List<Order>{updateOrder}, crtNS);
        System.enqueueJob(orderIntegrationJob);
        Test.stopTest();
        
        Order updatedOrder = [SELECT Id, Netsuite_Creation_Message__c FROM Order WHERE Id = :updateOrder.Id];
        
        System.assert(updatedOrder.Netsuite_Creation_Message__c.contains('Updation failed'),'The error message should contain "Updation failed"');
    }
    
    public class MockHttpResponse200 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"idToken":"mockedIdToken"}');
            return res;
        }
    }
    
    public class MockHttpResponse401 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(401);
            res.setBody('{"error":"Authentication failed"}');
            return res;
        }
    }
    
    public class MockHttpResponse200WithCreation implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"data": {"internalId": "82028","Type": "Order"}}');
            return res;
        }
    }
    
    public class MockHttpResponse200WithCreationFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"data": {"error":"Something went wrong!!!"}}');
            return res;
        }
    }
}