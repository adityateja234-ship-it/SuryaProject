@isTest(seeAllData=true)
private class OECLassoSyncManualOrdersQueuebleTest {
    
    @isTest
    static void testOECLassoSyncOrderQueueble() {
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Description='Test Product';
        p.productCode = 'ABC';
        p.isActive = true;
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
        
        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast', email='test@test.com');
        insert newContact;
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        
        // Insert Manager 1 
        Contact manager1 = new Contact (FirstName = 'ManagerFN1',LastName = 'ManagerLN1',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager1;
        Contact mgr1 = [select id from contact where FirstName='ManagerFN1'];
        
        // Insert Manager 2
        Contact manager2 = new Contact (FirstName = 'ManagerFN2',LastName = 'ManagerLN2',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager2;
        Contact mgr2 = [select id from contact where FirstName='ManagerFN2'];
        
        Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'New',
            PriceBook2Id = Test.getStandardPricebookId(),
            Region__c='AMER',
            Requester_Contact__c=cc.Id,
            Meeting_Complexity__c='2 - Medium',
            RecordTypeId='0121L000001QT76QAG',
            Start_Date_Time__c=datetime.newInstance(2022, 12, 18),
            End_Date_Time__c=datetime.newInstance(2022, 12, 20),
            Event_Type_OE_Defined__c='Virtual Conference',
            Name='Test Order Future',
            Order_TimeZone__c='(GMT+5:30) India',
            CurrencyIsoCode='USD',
            Description='Test Description',
            EventNotes__c='Test Notes',
            No_Sync_to_External_Systems__c = false,
            Business_Line_Exception__c = 'OE Connect',
            Lasso_New_Sync_Status__c  = 'Never Synced'
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
        
        Order syncedOrd = [SELECT Region__c, Status FROM Order WHERE Name = 'Test Order Future'];
        syncedOrd.Region__c = 'APAC';
        syncedOrd.Status = 'In Progress';
        syncedOrd.Project_Manager__c = mgr1.id;
        syncedOrd.Project_Manager_2__c = mgr2.id;
        update syncedOrd;
        
        Set<Id> orderIds = new Set<Id>{syncedOrd.Id};
            
            Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.enqueueJob(new OECLassoSyncManualOrdersQueueble(orderIds));
        Test.stopTest();
        System.assertEquals('In Progress', syncedOrd.Status);
    }
    
    @isTest
    static void testOECLassoSyncOrderUpdate() { 
        
        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Description='Test Product';
        p.productCode = 'ABC';
        p.isActive = true;
        insert p;
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 240;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        // insert account
        Account acc = new Account(
            Name = 'SFDCPanther.com',
            Rating = 'Hot',
            Industry = 'Banking',
            Phone = '9087654321',
            External_Sync__c = true
        );
        
        insert acc;
        
        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast', email='test@test.com');
        insert newContact;
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        
        // Insert Manager 1 
        Contact manager1 = new Contact (FirstName = 'ManagerFN1',LastName = 'ManagerLN1',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager1;
        Contact mgr1 = [select id from contact where FirstName='ManagerFN1'];
        
        // Insert Manager 2
        Contact manager2 = new Contact (FirstName = 'ManagerFN2',LastName = 'ManagerLN2',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager2;
        Contact mgr2 = [select id from contact where FirstName='ManagerFN2'];
        
        
        Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'New',
            PriceBook2Id = Test.getStandardPricebookId(),
            Region__c='AMER',
            Requester_Contact__c=cc.Id, 
            Meeting_Complexity__c='2 - Medium', 
            RecordTypeId='0121L000001QT76QAG',
            Start_Date_Time__c=datetime.newInstance(2022, 12, 18), 
            End_Date_Time__c=datetime.newInstance(2022, 12, 20), 
            Event_Type_OE_Defined__c='Virtual Conference', 
            Name='Test Order Future',
            Order_TimeZone__c='(GMT+5:30) India', 
            CurrencyIsoCode='USD',
            Description='Test Description',
            EventNotes__c='Test Notes',
            No_Sync_to_External_Systems__c = false,
            Business_Line_Exception__c = 'OE Connect',
            Lasso_Event_ID__c = '123456',
            OECEventId__c = '334556'
        );
        insert order;
        
        Map<Id, Order> oldMap = new Map<Id, Order>(
            [SELECT Id, Name, Region__c, Business_Line__c, Order_TimeZone__c,
             Start_Date_Time__c, End_Date_Time__c, Project_Manager__c, Project_Manager_2__c
             FROM Order WHERE Id = :order.Id]
        );
        
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.id;
        lineItem.Quantity = 24;
        lineItem.UnitPrice = 240;
        lineItem.ListPrice =  240;
        lineItem.Product2id = p.id;
        lineItem.PricebookEntryId=standardPrice.id;
        insert lineItem;
        
        Order syncedOrd = [SELECT SyncStatus__c, Region__c, Status FROM Order WHERE Name = 'Test Order Future'];
        syncedOrd.Region__c = 'APAC';
        syncedOrd.Status = 'In Progress';
        syncedOrd.ProcessedForLasso__c = true;
        syncedOrd.Lasso_New_Sync_Status__c  = 'Synced';
        syncedOrd.Project_Manager__c = mgr1.id;
        syncedOrd.Project_Manager_2__c = mgr2.id;
        update syncedOrd;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.enqueueJob(new OECLassoSyncManualOrderUpdateQueueble(new Set<Id>{order.Id}, oldMap));
        Test.stopTest();
        
        Order updatedOrd = [SELECT Id, Status FROM Order WHERE Id = :Order.Id AND Status = 'In Progress'];
        System.assertEquals('In Progress', updatedOrd.Status);  
    }
}