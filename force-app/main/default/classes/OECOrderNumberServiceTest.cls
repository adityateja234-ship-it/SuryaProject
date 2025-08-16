@isTest(seeAllData=true)
public class OECOrderNumberServiceTest {
    
    static testMethod void testPost() {
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'New',
            PriceBook2Id = pb.Id,
            
            Region__c='APAC', 
            Requester_Contact__c=cc.Id, 
            Meeting_Complexity__c='2 - Medium', 
            //EffectiveDate= date.newInstance(2021, 12, 15),
            Start_Date_Time__c=datetime.newInstance(2024, 04, 01), 
            End_Date_Time__c=datetime.newInstance(2024, 04, 10), 
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
        String jsonString = '{"startDate":"2024-03-03T10:27:54.14Z","endDate":"2024-04-12T10:37:54.14Z"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderNumberService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OECOrderNumberService.getOrderNumbers();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Future'];
        system.assertEquals(order1.Name, 'Test Order Future');
        //system.assertEquals(acc.Description, 'Testing');
        
        
    }
    
    
    static testMethod void testPost1() {
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'New',
            PriceBook2Id = pb.Id,
            
            Region__c='APAC', 
            Requester_Contact__c=cc.Id, 
            Meeting_Complexity__c='2 - Medium', 
            //EffectiveDate= date.newInstance(2021, 12, 15),
            Start_Date_Time__c=datetime.newInstance(2024, 04, 01), 
            End_Date_Time__c=datetime.newInstance(2024, 04, 10), 
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
        String jsonString = '{"startDate":"2024-0344-30T10:27:54.14Z","endDate":"2024-04-12T10:37:54.14Z"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderNumberService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OECOrderNumberService.getOrderNumbers();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Future'];
        system.assertEquals(order1.Name, 'Test Order Future');
        //system.assertEquals(acc.Description, 'Testing');
        
        
    }
    static testMethod void testPost2() {
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'New',
            PriceBook2Id = pb.Id,
            
            Region__c='APAC', 
            Requester_Contact__c=cc.Id, 
            Meeting_Complexity__c='2 - Medium', 
            //EffectiveDate= date.newInstance(2021, 12, 15),
            Start_Date_Time__c=datetime.newInstance(2024, 04, 01), 
            End_Date_Time__c=datetime.newInstance(2024, 04, 10), 
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
        String jsonString = '{"startDate":"2024-03-30T10:27:54.14Z","endDate":"2024-0433-12T10:37:54.14Z"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderNumberService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OECOrderNumberService.getOrderNumbers();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Future'];
        system.assertEquals(order1.Name, 'Test Order Future');
        //system.assertEquals(acc.Description, 'Testing');
        
        
    } 
    static testMethod void testPost3() {
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'New',
            PriceBook2Id = pb.Id,
            
            Region__c='APAC', 
            Requester_Contact__c=cc.Id, 
            Meeting_Complexity__c='2 - Medium', 
            //EffectiveDate= date.newInstance(2021, 12, 15),
            Start_Date_Time__c=datetime.newInstance(2024, 04, 01), 
            End_Date_Time__c=datetime.newInstance(2024, 04, 10), 
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
        String jsonString = '{"startDate":"2024-03-30T10:27:54.14Z","endDate":"2024-0433-12T10:37:54.14Z","wrong":"wrong"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderNumberService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OECOrderNumberService.getOrderNumbers();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Future'];
        system.assertEquals(order1.Name, 'Test Order Future');
        //system.assertEquals(acc.Description, 'Testing');
        
        
    }     
}