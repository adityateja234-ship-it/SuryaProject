@IsTest
public class CloneOrderControllerTest {
    @IsTest
    public static void testGetOrderDetails() {
        test.startTest();
        
        insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);
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
            //EffectiveDate= date.newInstance(2021, 12, 15),
            Start_Date_Time__c=datetime.newInstance(2022, 12, 18), 
            End_Date_Time__c=datetime.newInstance(2022, 12, 20), 
            Event_Type_OE_Defined__c='Virtual Conference', 
            Name='Test Order Future',
            Order_TimeZone__c='(GMT+5:30) India', 
            CurrencyIsoCode='USD',
            //AccountId=acc.id,
            Description='Test Description',
            EventNotes__c='Test Notes',
            No_Sync_to_External_Systems__c = false,
            Business_Line_Exception__c = 'OE Connect'
        );
        insert order;
        
        CloneOrderController.getOrderDetails(order.Id);
        test.stopTest();
        }
    }