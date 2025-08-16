@isTest
private class OECBatchOrderSyncTest {
    
     static testMethod void testPost4() {
     
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
        
        // insert account
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
        
        
        Contact pmContact = new Contact (FirstName = 'xyzFirst1',LastName = 'XyZLast1', email ='raju1@oe.com', Job_Function__c='Employee', Management_Level__c='Manager');
        insert pmContact;
        
        Contact copmContact = new Contact (FirstName = 'xyzFirst2',LastName = 'XyZLast2', email ='raju2@oe.com', Job_Function__c='Employee', Management_Level__c='Manager');
        insert copmContact;
        
        Contact pm = [select id from contact where FirstName='xyzFirst1'];
        
        Contact copm = [select id from contact where FirstName='xyzFirst2'];
        
        
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
            Account_Legal_Entity__c = 'OpenExchange',
            CurrencyIsoCode='USD',
            Description='Test Description',
            EventNotes__c='Test Notes',
            No_Sync_to_External_Systems__c = false,
            Business_Line_Exception__c = 'OE Connect',
            SyncStatus__c = 'Failed',
            Project_Manager__c = pm.Id,
            Project_Manager_2__c = copm.Id
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
        //Test.startTest();
        Order syncedOrd = [SELECT SyncStatus__c FROM Order WHERE Name = 'Test Order Future'];
        syncedOrd.Status = 'In Progress';
        update syncedOrd;
        System.assertEquals('In Progress', syncedOrd.Status);
        //Test.stopTest();
        /*
        OECSyncScheduleBatch sh1 = new OECSyncScheduleBatch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        */
        
        Database.executeBatch(new OECBatchOrderSync(),1);
     }
 }