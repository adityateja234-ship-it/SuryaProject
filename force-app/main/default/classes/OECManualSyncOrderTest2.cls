@isTest(seeAllData=false)
private class OECManualSyncOrderTest2 {
    
    //Lasso Update Use Case
    static testMethod void testLassoUpdatePost() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
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
        
        // Insert Requestor Contact
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
        
        // Insert Manager 1
        Contact manager1 = new Contact (FirstName = 'ManagerFN1',LastName = 'ManagerLN1',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager1;
        Contact mgr1 = [select id from contact where FirstName='ManagerFN1'];
        
        // Insert Manager 2
        Contact manager2 = new Contact (FirstName = 'ManagerFN2',LastName = 'ManagerLN2',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager2;
        Contact mgr2 = [select id from contact where FirstName='ManagerFN2'];
        
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.id;
        lineItem.Quantity = 24;
        lineItem.UnitPrice = 240;
        lineItem.ListPrice =  240;
        lineItem.Product2id = p.id;
        lineItem.PricebookEntryId=standardPrice.id;
        insert lineItem; 
        
        Order syncedOrd = [select SyncStatus__c from Order where Name='Test Order Future'];
        syncedOrd.Status = 'In Progress';
        syncedOrd.Lasso_Event_ID__c = '12345';
        syncedOrd.Description='Test Description Updated';
        syncedOrd.ProcessedForLasso__c = true;
        syncedOrd.Lasso_New_Sync_Status__c='Synced';
        
        syncedOrd.Project_Manager__c = mgr1.id;
        syncedOrd.Project_Manager_2__c = mgr2.id;
        
        update syncedOrd;
        System.assertEquals('In Progress', syncedOrd.Status);
        
        Test.stopTest();
    }
    
    //Lasso Update Use Case
    static testMethod void testLassoCancelPost() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
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
        
        // Insert Requestor contact
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
        
        // Insert Manager 1
        Contact manager1 = new Contact (FirstName = 'ManagerFN1',LastName = 'ManagerLN1',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager1;
        Contact mgr1 = [select id from contact where FirstName='ManagerFN1'];
        
        // Insert Manager 2
        Contact manager2 = new Contact (FirstName = 'ManagerFN2',LastName = 'ManagerLN2',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager2;
        Contact mgr2 = [select id from contact where FirstName='ManagerFN2'];
        
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.id;
        lineItem.Quantity = 24;
        lineItem.UnitPrice = 240;
        lineItem.ListPrice =  240;
        lineItem.Product2id = p.id;
        lineItem.PricebookEntryId=standardPrice.id;
        insert lineItem; 
        
        Order syncedOrd = [select SyncStatus__c from Order where Name='Test Order Future'];
        syncedOrd.Status = 'In Progress';
        syncedOrd.Lasso_Event_ID__c = '12345';
        syncedOrd.OECEventID__c = '12345';
        syncedOrd.Description='Test Description Updated';
        syncedOrd.ProcessedForLasso__c = true;
        syncedOrd.Lasso_New_Sync_Status__c='Synced';
        
        syncedOrd.Project_Manager__c = mgr1.id;
        syncedOrd.Project_Manager_2__c = mgr2.id;
        
        update syncedOrd;
        System.assertEquals('In Progress', syncedOrd.Status);
        
        Order syncedOrdToCancel = [select SyncStatus__c from Order where Name='Test Order Future'];
        syncedOrdToCancel.ProcessedForLasso__c = true;
        syncedOrdToCancel.Lasso_New_Sync_Status__c  = 'Synced';
        syncedOrdToCancel.CancelledStatusProcessedForOEC__c =  true;
        syncedOrdToCancel.Status = 'Cancelled';
        syncedOrdToCancel.Cancellation_Reason__c = 'No Budget';
        syncedOrdToCancel.Cancellation_Fee__c = 'No';
        update syncedOrdToCancel;
        
        Test.stopTest();
    }
    
    //Cancel Status Use Case
    static testMethod void testStatusPost() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator3());
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
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
        
        // Insert Requestor Contact
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
            Name='Test Order Future1',
            Order_TimeZone__c='(GMT+5:30) India', 
            CurrencyIsoCode='USD',
            Description='Test Description',
            EventNotes__c='Test Notes',
            No_Sync_to_External_Systems__c = false,
            Lasso_Event_ID__c = '12345',
            OECEventID__c = '12345',
            Business_Line_Exception__c = 'OE Connect'
        );
        insert order;
        
        // Insert Manager 1
        Contact manager1 = new Contact (FirstName = 'ManagerFN1',LastName = 'ManagerLN1',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager1;
        Contact mgr1 = [select id from contact where FirstName='ManagerFN1'];
        
        // Insert Manager 2
        Contact manager2 = new Contact (FirstName = 'ManagerFN2',LastName = 'ManagerLN2',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager2;
        Contact mgr2 = [select id from contact where FirstName='ManagerFN2'];
        
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.id;
        lineItem.Quantity = 24;
        lineItem.UnitPrice = 240;
        lineItem.ListPrice =  240;
        lineItem.Product2id = p.id;
        lineItem.PricebookEntryId=standardPrice.id;
        insert lineItem; 
        
        Order syncedOrd = [select SyncStatus__c from Order where Name='Test Order Future1'];
        syncedOrd.Status = 'In Progress';
        
        syncedOrd.Description='Test Description Updated';
        syncedOrd.ProcessedForLasso__c = true;
        syncedOrd.Lasso_New_Sync_Status__c='Synced';
        
        syncedOrd.Project_Manager__c = mgr1.id;
        syncedOrd.Project_Manager_2__c = mgr2.id;
        
        update syncedOrd;
        System.assertEquals('In Progress', syncedOrd.Status);
        
        Order syncedOrdToCancel = [select SyncStatus__c from Order where Name='Test Order Future1'];
        syncedOrdToCancel.ProcessedForLasso__c = true;
        syncedOrdToCancel.Lasso_New_Sync_Status__c  = 'Synced';
        syncedOrdToCancel.CancelledStatusProcessedForOEC__c =  true;
        syncedOrdToCancel.Status = 'Cancelled';
        syncedOrdToCancel.Cancellation_Reason__c = 'No Budget';
        syncedOrdToCancel.Cancellation_Fee__c = 'No';
        update syncedOrdToCancel;
        
        Test.stopTest();
    }
    
    //Update both project manager Use Case
    static testMethod void testUpdateBothProjectManagerPost() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
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
        
        // Insert Requestor Contact
        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        
        // Insert Manager 2
        Contact manager3 = new Contact (FirstName = 'ManagerFN3',LastName = 'ManagerLN3',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager3;
        Contact mgr3 = [select id from contact where FirstName='ManagerFN3'];
        
        // Insert Manager 3
        Contact manager4 = new Contact (FirstName = 'ManagerFN4',LastName = 'ManagerLN4',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager4;
        Contact mgr4 = [select id from contact where FirstName='ManagerFN4'];
        
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
            Business_Line_Exception__c = 'OE Connect',
            Project_Manager__c = mgr3.id,
            Project_Manager_2__c = mgr4.id
        );
        insert order;
        
        // Insert Manager 1
        Contact manager1 = new Contact (FirstName = 'ManagerFN1',LastName = 'ManagerLN1',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager1;
        Contact mgr1 = [select id from contact where FirstName='ManagerFN1'];
        
        // Insert Manager 2
        Contact manager2 = new Contact (FirstName = 'ManagerFN2',LastName = 'ManagerLN2',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager2;
        Contact mgr2 = [select id from contact where FirstName='ManagerFN2'];
        
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.id;
        lineItem.Quantity = 24;
        lineItem.UnitPrice = 240;
        lineItem.ListPrice =  240;
        lineItem.Product2id = p.id;
        lineItem.PricebookEntryId=standardPrice.id;
        insert lineItem; 
        
        Order syncedOrd = [select SyncStatus__c from Order where Name='Test Order Future'];
        syncedOrd.Status = 'In Progress';
        syncedOrd.Lasso_Event_ID__c = '12345';
        syncedOrd.Description='Test Description Updated';
        syncedOrd.ProcessedForLasso__c = true;
        syncedOrd.Lasso_New_Sync_Status__c='Synced';
        
        syncedOrd.Project_Manager__c = mgr1.id;
        syncedOrd.Project_Manager_2__c = mgr2.id;
        
        update syncedOrd;
        System.assertEquals('In Progress', syncedOrd.Status);
        
        Test.stopTest();
    }
    
    //Update project manager Use Case
    static testMethod void testUpdateProjectManagerPost() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
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
        
        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        
        // Insert Manager 3
        Contact manager3 = new Contact (FirstName = 'ManagerFN3',LastName = 'ManagerLN3',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager3;
        Contact mgr3 = [select id from contact where FirstName='ManagerFN3'];
        
        // Insert Manager 4
        Contact manager4 = new Contact (FirstName = 'ManagerFN4',LastName = 'ManagerLN4',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager4;
        Contact mgr4 = [select id from contact where FirstName='ManagerFN4'];
        
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
            Business_Line_Exception__c = 'OE Connect',
            Project_Manager__c = mgr3.id,
            Project_Manager_2__c = mgr4.id
        );
        insert order;
        
        Contact manager1 = new Contact (FirstName = 'ManagerFN1',LastName = 'ManagerLN1',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager1;
        Contact mgr1 = [select id from contact where FirstName='ManagerFN1'];       
        
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.id;
        lineItem.Quantity = 24;
        lineItem.UnitPrice = 240;
        lineItem.ListPrice =  240;
        lineItem.Product2id = p.id;
        lineItem.PricebookEntryId=standardPrice.id;
        insert lineItem; 
        
        Order syncedOrd = [select SyncStatus__c from Order where Name='Test Order Future'];
        syncedOrd.Status = 'In Progress';
        syncedOrd.Lasso_Event_ID__c = '12345';
        syncedOrd.Description='Test Description Updated';
        syncedOrd.ProcessedForLasso__c = true;
        syncedOrd.Lasso_New_Sync_Status__c='Synced';
        
        syncedOrd.Project_Manager__c = mgr1.id;
        
        update syncedOrd;
        System.assertEquals('In Progress', syncedOrd.Status);
        
        Test.stopTest();
    }
    
    //Update co - project manager Use Case
    static testMethod void testUpdateCoProjectManagerPost() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
        
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
        
        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        
        // Insert Manager 3
        Contact manager3 = new Contact (FirstName = 'ManagerFN3',LastName = 'ManagerLN3',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager3;
        Contact mgr3 = [select id from contact where FirstName='ManagerFN3'];
        
        // Insert Manager 4
        Contact manager4 = new Contact (FirstName = 'ManagerFN4',LastName = 'ManagerLN4',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager4;
        Contact mgr4 = [select id from contact where FirstName='ManagerFN4'];
        
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
            Business_Line_Exception__c = 'OE Connect',
            Project_Manager__c = mgr3.id,
            Project_Manager_2__c = mgr4.id
        );
        insert order;
        
        // Insert Manager 1
        Contact manager1 = new Contact (FirstName = 'ManagerFN1',LastName = 'ManagerLN1',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager1;
        Contact mgr1 = [select id from contact where FirstName='ManagerFN1'];
        
        // Insert Manager 2
        Contact manager2 = new Contact (FirstName = 'ManagerFN2',LastName = 'ManagerLN2',Job_Function__c='Employee',Management_Level__c='Manager');
        insert manager2;
        Contact mgr2 = [select id from contact where FirstName='ManagerFN2'];
        
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.id;
        lineItem.Quantity = 24;
        lineItem.UnitPrice = 240;
        lineItem.ListPrice =  240;
        lineItem.Product2id = p.id;
        lineItem.PricebookEntryId=standardPrice.id;
        insert lineItem; 
        
        Order syncedOrd = [select SyncStatus__c from Order where Name='Test Order Future'];
        syncedOrd.Status = 'In Progress';
        syncedOrd.Lasso_Event_ID__c = '12345';
        syncedOrd.Description='Test Description Updated';
        syncedOrd.ProcessedForLasso__c = true;
        syncedOrd.Lasso_New_Sync_Status__c='Synced';
        
        syncedOrd.Project_Manager_2__c = mgr2.id;
        
        update syncedOrd;
        System.assertEquals('In Progress', syncedOrd.Status);
        
        Test.stopTest();
    }
}