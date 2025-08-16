@IsTest
public class UpdatePriceBookControllerTest {
    @IsTest
    public static void testUpdatePriceBook(){
        
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
        
        Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'New',
            PriceBook2Id = Test.getStandardPricebookId(),
            Region__c='APAC', 
            Requester_Contact__c=newContact.Id, 
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
        
        PriceBook2 pb = new PriceBook2 (Name='Bank of America OEConference Custom Price Book');
        insert pb;
        
        test.startTest();
        UpdatePriceBookController.updatePriceBook(order.Id, pb.Id, 'In Progress');
        UpdatePriceBookController.updatePriceBook(order.Id, pb.Id, '');
        Order orderObj = [SELECT Id, PriceBook2Id FROM Order WHERE Id =: Order.Id];
        System.assertEquals(pb.Id, orderObj.PriceBook2Id, 'PriceBook2Id should be updated on the order');
        UpdatePriceBookController.getOrderDetails(order.Id);
        test.stopTest();
    }
}