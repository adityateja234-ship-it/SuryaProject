@isTest(seeAllData=true)
public class SfOEINsOrderHelper_Test {
    
    @isTest
    static void testOnAfterUpdateSync1() {
        
        Account testAccount = new Account(
            Name = 'Test Account 1001',
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
        
        Order insertOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'New',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Pricebook2Id = standardPricebook.Id,
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Assam',
            BillingStreet = 'xyz',
            BillingCity = 'Lanka',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        insert insertOrder;
        
        OrderItem orderItem = new OrderItem(
            OrderId = insertOrder.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100.00
        );
        insert orderItem;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Order newOrder = new Order(
            Id = insertOrder.Id,
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Pricebook2Id = standardPricebook.Id,
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Assam',
            BillingStreet = 'xyz',
            BillingCity = 'Lanka',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        OrderTriggerHandler.setExecutedNetsuiteOrders.clear();
        OrderTriggerHandler.setExecutedNetsuiteUpdateOrders.clear();
        
        SfOEINsOrderHelper helper = new SfOEINsOrderHelper(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder });
        helper.onAfterUpdate(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder }, new Map<Id, Order> { insertOrder.Id => insertOrder });
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testOnAfterUpdateSync2() {
        
        Account testAccount = new Account(
            Name = 'Test Account 1001',
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
        
        Order insertOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Pricebook2Id = standardPricebook.Id,
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        insert insertOrder;
        
        OrderItem orderItem = new OrderItem(
            OrderId = insertOrder.Id,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100.00
        );
        insert orderItem;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Order newOrder = new Order(
            Id = insertOrder.Id,
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Pricebook2Id = standardPricebook.Id,
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        OrderTriggerHandler.setExecutedNetsuiteOrders.clear();
        OrderTriggerHandler.setExecutedNetsuiteUpdateOrders.clear();
        
        SfOEINsOrderHelper helper = new SfOEINsOrderHelper(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder });
        helper.onAfterUpdate(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder }, new Map<Id, Order> { insertOrder.Id => insertOrder });
        
        Test.stopTest();
        
    }
    
    @isTest
    static void validOrderToProcessUpdateNameNull() {
        
        Account testAccount = new Account(
            Name = 'Test Account 1001',
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
        
        Order insertOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Order newOrder = new Order(
            Id = insertOrder.Id,
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = null,
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        SfOEINsOrderHelper helper = new SfOEINsOrderHelper(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder });
        System.assert(!helper.validOrderToProcessUpdate( newOrder, new Map<Id, Order>{insertOrder.Id => insertOrder}));
        
        Test.stopTest();
        
    }
    
    @isTest
    static void validOrderToProcessEntity() {
        
        Account testAccount = new Account(
            Name = 'Test Account 1001',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'United States',
            ShippingCountry = 'United States'
        );
        insert testAccount;
        
        Account testAccount2 = new Account(
            Name = 'Test Account 1002',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'United States',
            ShippingCountry = 'United States'
        );
        insert testAccount2;
        
        Contact testContact = new Contact(
            FirstName = 'FirstTest',
            LastName = 'LastName',
            Contact_Status__c = 'Current',
            AccountId = testAccount.Id
        );
        insert testContact;
        
        Order insertOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Order newOrder = new Order(
            Id = insertOrder.Id,
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount2.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        SfOEINsOrderHelper helper = new SfOEINsOrderHelper(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder });
        System.assert(helper.validOrderToProcessUpdate( newOrder, new Map<Id, Order>{insertOrder.Id => insertOrder}));
        
        Test.stopTest();
        
    }
    
    @isTest
    static void validOrderToProcessDesc() {
        
        Account testAccount = new Account(
            Name = 'Test Account 1001',
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
        
        Order insertOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Order newOrder = new Order(
            Id = insertOrder.Id,
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Update in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        SfOEINsOrderHelper helper = new SfOEINsOrderHelper(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder });
        System.assert(helper.validOrderToProcessUpdate( newOrder, new Map<Id, Order>{insertOrder.Id => insertOrder}));
        
        Test.stopTest();
        
    }
    
    @isTest
    static void validOrderToProcessRegion() {
        
        Account testAccount = new Account(
            Name = 'Test Account 1001',
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
        
        Order insertOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Order newOrder = new Order(
            Id = insertOrder.Id,
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'AMER',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        SfOEINsOrderHelper helper = new SfOEINsOrderHelper(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder });
        System.assert(helper.validOrderToProcessUpdate( newOrder, new Map<Id, Order>{insertOrder.Id => insertOrder}));
        
        Test.stopTest();
        
    }
    
    @isTest
    static void validOrderToProcessRequestor() {
        
        Account testAccount = new Account(
            Name = 'Test Account 1001',
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
        
        Contact testContact2 = new Contact(
            FirstName = 'FirstTest',
            LastName = 'LastName',
            Contact_Status__c = 'Current',
            AccountId = testAccount.Id
        );
        insert testContact2;
        
        Order insertOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Order newOrder = new Order(
            Id = insertOrder.Id,
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact2.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        SfOEINsOrderHelper helper = new SfOEINsOrderHelper(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder });
        System.assert(helper.validOrderToProcessUpdate( newOrder, new Map<Id, Order>{insertOrder.Id => insertOrder}));
        
        Test.stopTest();
        
    }
    
    @isTest
    static void validOrderToProcessEventType() {
        
        Account testAccount = new Account(
            Name = 'Test Account 1001',
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
        
        Order insertOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Order newOrder = new Order(
            Id = insertOrder.Id,
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Trade Show',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        SfOEINsOrderHelper helper = new SfOEINsOrderHelper(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder });
        System.assert(helper.validOrderToProcessUpdate( newOrder, new Map<Id, Order>{insertOrder.Id => insertOrder}));
        
        Test.stopTest();
        
    }
    
    @isTest
    static void validOrderToProcessBillStreet() {
        
        Account testAccount = new Account(
            Name = 'Test Account 1001',
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
        
        Order insertOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Order newOrder = new Order(
            Id = insertOrder.Id,
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Lodipur',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        SfOEINsOrderHelper helper = new SfOEINsOrderHelper(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder });
        System.assert(helper.validOrderToProcessUpdate( newOrder, new Map<Id, Order>{insertOrder.Id => insertOrder}));
        
        Test.stopTest();
        
    }
    
    @isTest
    static void validOrderToProcessBillCity() {
        
        Account testAccount = new Account(
            Name = 'Test Account 1001',
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
        
        Order insertOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Order newOrder = new Order(
            Id = insertOrder.Id,
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Purnia',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        SfOEINsOrderHelper helper = new SfOEINsOrderHelper(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder });
        System.assert(helper.validOrderToProcessUpdate( newOrder, new Map<Id, Order>{insertOrder.Id => insertOrder}));
        
        Test.stopTest();
        
    }
    
    @isTest
    static void validOrderToProcessBillPostal() {
        
        Account testAccount = new Account(
            Name = 'Test Account 1001',
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
        
        Order insertOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Order newOrder = new Order(
            Id = insertOrder.Id,
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '853201',
            Billing_Notes__c = 'Billing Notes'
        );
        
        SfOEINsOrderHelper helper = new SfOEINsOrderHelper(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder });
        System.assert(helper.validOrderToProcessUpdate( newOrder, new Map<Id, Order>{insertOrder.Id => insertOrder}));
        
        Test.stopTest();
        
    }
    
    @isTest
    static void validOrderToProcessBillContact() {
        
        Account testAccount = new Account(
            Name = 'Test Account 1001',
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
        
        Contact testContact2 = new Contact(
            FirstName = 'FirstTest',
            LastName = 'LastName',
            Contact_Status__c = 'Current',
            AccountId = testAccount.Id
        );
        insert testContact2;
        
        Order insertOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Order newOrder = new Order(
            Id = insertOrder.Id,
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact2.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        SfOEINsOrderHelper helper = new SfOEINsOrderHelper(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder });
        System.assert(helper.validOrderToProcessUpdate( newOrder, new Map<Id, Order>{insertOrder.Id => insertOrder}));
        
        Test.stopTest();
        
    }
    
    @isTest
    static void validOrderToProcessClientCost() {
        
        Account testAccount = new Account(
            Name = 'Test Account 1001',
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
        
        Order insertOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Order newOrder = new Order(
            Id = insertOrder.Id,
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613961',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        SfOEINsOrderHelper helper = new SfOEINsOrderHelper(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder });
        System.assert(helper.validOrderToProcessUpdate( newOrder, new Map<Id, Order>{insertOrder.Id => insertOrder}));
        
        Test.stopTest();
        
    }
    
    @isTest
    static void validOrderToProcessName() {
        
        Account testAccount = new Account(
            Name = 'Test Account 1001',
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
        
        Order insertOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Order newOrder = new Order(
            Id = insertOrder.Id,
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1 Update',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        SfOEINsOrderHelper helper = new SfOEINsOrderHelper(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder });
        System.assert(helper.validOrderToProcessUpdate( newOrder, new Map<Id, Order>{insertOrder.Id => insertOrder}));
        
        Test.stopTest();
        
    }
    
    @isTest
    static void validOrderToProcessBillNote() {
        
        Account testAccount = new Account(
            Name = 'Test Account 1001',
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
        
        Order insertOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Order newOrder = new Order(
            Id = insertOrder.Id,
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes Update'
        );
        
        SfOEINsOrderHelper helper = new SfOEINsOrderHelper(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder });
        System.assert(helper.validOrderToProcessUpdate( newOrder, new Map<Id, Order>{insertOrder.Id => insertOrder}));
        
        Test.stopTest();
        
    }
    
    @isTest
    static void validOrderToProcessBillCountry() {
        
        Account testAccount = new Account(
            Name = 'Test Account 1001',
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
        
        Order insertOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Order newOrder = new Order(
            Id = insertOrder.Id,
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'Australia',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        SfOEINsOrderHelper helper = new SfOEINsOrderHelper(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder });
        System.assert(helper.validOrderToProcessUpdate( newOrder, new Map<Id, Order>{insertOrder.Id => insertOrder}));
        
        Test.stopTest();
        
    }
    
    @isTest
    static void validOrderToProcessBillState() {
        
        Account testAccount = new Account(
            Name = 'Test Account 1001',
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
        
        Order insertOrder = new Order(
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Bihar',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Order newOrder = new Order(
            Id = insertOrder.Id,
            AccountId = testAccount.Id,
            Requester_Contact__c = testContact.Id,
            Status = 'Ready to Bill',
            Region__c = 'APAC',
            EffectiveDate = System.today(),
            Name = 'Event Test Order1',
            Event_Type_OE_Defined__c = 'Virtual Conference',
            Start_Date_Time__c = System.now(),
            End_Date_Time__c = System.now().addDays(1),
            Description = 'Insert in NS',
            Billing_Method__c = 'Bill Per Event',
            Billing_Time_Sensitivity__c ='Within 72 Hours',
            Client_Cost_Code__c = 'C613951',
            Bill_To_Legal_Entity_Name__c = testAccount.Id,
            Billing_Contact__c = testContact.Id,
            BillingCountry = 'India',
            BillingState = 'Karnataka',
            BillingStreet = 'Toll Plaza',
            BillingCity = 'Bhagalpur',
            BillingPostalCode = '200001',
            Billing_Notes__c = 'Billing Notes'
        );
        
        SfOEINsOrderHelper helper = new SfOEINsOrderHelper(new List<Order> { newOrder }, new Map<Id, Order> { newOrder.Id => newOrder });
        System.assert(helper.validOrderToProcessUpdate( newOrder, new Map<Id, Order>{insertOrder.Id => insertOrder}));
        
        Test.stopTest();
        
    }
    
    private class MockHttpResponse200 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}');
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
}