@isTest(seeAllData=true)
private class OrderService_Test {
    
 /*   
    @testSetup
    static void dataSetup() {
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract',Account=newAccount,Status='Draft', Business_Line__c = 'OE Convference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;
        System.debug('103----------------->>');
    }
     */
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
        
        Account acc = [select id from Account where Name='TestAccountName100' LIMIT 1]; 
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLast100@test.com"}}'
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name XYZ'];
        system.assertEquals(order1.Name, 'Test Order Service Name XYZ');
        //system.assertEquals(acc.Description, 'Testing');
        
    }
    
    static testMethod void testPost1() {
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName200',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract200',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'xyzFirst200',LastName = 'XyZLast200',Email='FirstLast200@yahoo.com');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName200']; 
        Contact cc = [select id from contact where FirstName='xyzFirst200'];
        Contract co = [select id from contract where Name='TestContract200'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name 200","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"TestLastName200",'+    
                                '"FirstName":"TestFirstName200"'+
                                '}}'
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name 200'];
        system.assertEquals(order1.Name, 'Test Order Service Name 200');
        //system.assertEquals(acc.Description, 'Testing');
        
    }

    static testMethod void testPost2() {
        System.debug('2----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('200----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName200',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('201----------------->>');
        Contract newContract = new Contract (Name = 'TestContract200',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('202----------------->>');
        Contact newContact = new Contact (FirstName = 'xyzFirst2',LastName = 'XyZLast');
        insert newContact;
        System.debug('203----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName200']; 
        Contact cc = [select id from contact where FirstName='xyzFirst2'];
        Contract co = [select id from contract where Name='TestContract200'];
        
        String jsonString = '{"Account":"","Contact":"","Contract":"","MeetingComplexity":"","Status":"","Region":"","OrderEnteredDate":"","EventName":"","EventType":"","OrderCurrency":"","StartDate":"","EndDate":""}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();
     
    }
    static testMethod void testPost3() {
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName300',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract300',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'xyzFirst3',LastName = 'XyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName300']; 
        Contact cc = [select id from contact where FirstName='xyzFirst3'];
        Contract co = [select id from contract where Name='TestContract300'];
              
        //String jsonString = '{"Account":"0010n00001CtQyM","Contact":"0030n00000qHxDP","Contract":"8000n000000UNVT","MeetingComplexity":"4 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name3","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z"}';
        
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"4 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z"}';


        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();
     
        Integer count = [ SELECT count() FROM Order WHERE Name ='Test Order Service Name3'];
        system.assertEquals(count, 0);
        
    }
    static testMethod void testPost4() {
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName400',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract400',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'xyzFirst4',LastName = 'XyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName400']; 
        Contact cc = [select id from contact where FirstName='xyzFirst4'];
        Contract co = [select id from contract where Name='TestContract400'];
              
        //String jsonString = '{"Account":"0010n00001CtQyM","Contact":"0030n00000qHxDP","Contract":"8000n000000UNVT","MeetingComplexity":"2 - Medium","Status":"Cancel","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name3","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z"}';
        
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"Cancel","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z"}';


        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();
     
        Integer count = [ SELECT count() FROM Order WHERE Name ='Test Order Service Name4'];
        system.assertEquals(count, 0);
        
    } 
    
    static testMethod void testPost5() {
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName500',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract500',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'xyzFirst5',LastName = 'XyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName500']; 
        Contact cc = [select id from contact where FirstName='xyzFirst5'];
        Contract co = [select id from contract where Name='TestContract500'];
              
        //String jsonString = '{"Account":"0010n00001CtQyM","Contact":"0030n00000qHxDP","Contract":"8000n000000UNVT","MeetingComplexity":"2 - Medium","Status":"New","Region":"AMERI","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name3","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z"}';

        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMERI","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();
     
        Integer count = [ SELECT count() FROM Order WHERE Name ='Test Order Service Name5'];
        system.assertEquals(count, 0);
        
    }   
        
    static testMethod void testPost6() {
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName600',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract600',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'xyzFirst6',LastName = 'XyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName600']; 
        Contact cc = [select id from contact where FirstName='xyzFirst6'];
        Contract co = [select id from contract where Name='TestContract600'];
              
        //String jsonString = '{"Account":"0010n00001CtQyM","Contact":"0030n00000qHxDP","Contract":"8000n000000UNVT","MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name3","EventType":"Virtual Conference","OrderCurrency":"USDR","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z"}';
        
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name","EventType":"Virtual Conference","OrderCurrency":"USDR","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();
     
        Integer count = [ SELECT count() FROM Order WHERE Name ='Test Order Service Name6'];
        system.assertEquals(count, 0);
        
    } 
    
    static testMethod void testPut1() {
    
        test.startTest();
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
        
        Account acc = [select id from Account where Name='TestAccountName100' LIMIT 1]; 
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLast100@test.com"}}'
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name XYZ'];
        system.assertEquals(order1.Name, 'Test Order Service Name XYZ');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='Citi' LIMIT 1]; 
        Contact cc2 = [select id from contact where FirstName='xyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
        
        String jsonStringUpdate = '{"Account":'+'"'+acc2.Id+'"'+
                            ',"Contact":'+'"'+cc2.Id+'"'+
                            ',"Contract":'+'"'+co2.Id+'"'+
                            ',"OrderId":'+'"'+order1.Id+'"'+                            
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Order Service Name XYZTest","EventType":"Virtual Conference"'+
                            ',"StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC","OrderCurrency":"USD"}';
       
        System.debug('jsonStringUpdate---->'+jsonStringUpdate);                        
        RestRequest reqUpdate = new RestRequest(); 
        RestResponse resUpdate = new RestResponse();             
        reqUpdate.requestURI = 'services/apexrest/OrderService';

        
        reqUpdate.httpMethod = 'PUT';
        reqUpdate.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = reqUpdate;
        RestContext.response= resUpdate;
        OrderService.updateOrder();
     
        //Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Order Service Name XYZTest'];
        //system.assertEquals(order2.Name, 'Order Service Name XYZTest');
        test.stopTest();
        
    } 
    static testMethod void testPut2() {
    
        test.startTest();
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
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name PQR","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLast100@test.com"}}'
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name PQR'];
        system.assertEquals(order1.Name, 'Test Order Service Name PQR');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='xyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
        
        String jsonStringUpdate = '{"Account":'+'"'+acc2.Id+'"'+
                            ',"Contact":'+'"'+cc2.Id+'"'+
                            ',"Contract":'+'"'+co2.Id+'"'+
                            ',"OrderId":'+'"'+order1.Id+'"'+                            
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name PQR2","EventType":"Virtual Conference"'+
                            ',"StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC","OrderCurrency":"USD"'+
                            ',"RequesterContact":{'+
                                '"LastName":"raju",'+    
                                '"FirstName":"cherukuri",'+
                                '"User":"rajucherukuri101@test.com"}}'
                                ;       
        System.debug('jsonStringUpdate---->'+jsonStringUpdate);                        
        RestRequest reqUpdate = new RestRequest(); 
        RestResponse resUpdate = new RestResponse();             
        reqUpdate.requestURI = 'services/apexrest/OrderService';

        
        reqUpdate.httpMethod = 'PUT';
        reqUpdate.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = reqUpdate;
        RestContext.response= resUpdate;
        OrderService.updateOrder();
     
        Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name PQR2'];
        system.assertEquals(order2.Name, 'Test Order Service Name PQR2');
        test.stopTest();
        
    }     
    static testMethod void testPut3() {
    
        test.startTest();
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
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name PQR","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLast100@test.com"}}'
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name PQR'];
        system.assertEquals(order1.Name, 'Test Order Service Name PQR');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='xyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
        
        String jsonStringUpdate = '{"Account":'+'"'+acc2.Id+'"'+
                            ',"Contact":'+'"'+cc2.Id+'"'+
                            ',"Contract":'+'"'+co2.Id+'"'+
                            ',"OrderId":'+'"'+order1.Id+'"'+                            
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name PQR2","EventType":"Virtual Conference"'+
                            ',"StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC","OrderCurrency":"USD"'+
                            ',"RequesterContact":{'+
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLast100@test.com"}}'
                                ;      
        System.debug('jsonStringUpdate---->'+jsonStringUpdate);                        
        RestRequest reqUpdate = new RestRequest(); 
        RestResponse resUpdate = new RestResponse();             
        reqUpdate.requestURI = 'services/apexrest/OrderService';

        
        reqUpdate.httpMethod = 'PUT';
        reqUpdate.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = reqUpdate;
        RestContext.response= resUpdate;
        OrderService.updateOrder();
     
        Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name PQR2'];
        system.assertEquals(order2.Name, 'Test Order Service Name PQR2');
        test.stopTest();
        
    } 
    static testMethod void testPatch1() {
    
        test.startTest();

        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];

        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;

        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;

        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;

        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLast100@test.com"}}'
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name XYZ'];
        system.assertEquals(order1.Name, 'Test Order Service Name XYZ');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='xyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
        
        String jsonStringUpdate = '{"OrderId":'+'"'+order1.Id+'"'+
                            ',"OECentralURL":"abc@123.com"}';
       
        System.debug('jsonStringUpdate---->'+jsonStringUpdate);                        
        RestRequest reqUpdate = new RestRequest(); 
        RestResponse resUpdate = new RestResponse();             
        reqUpdate.requestURI = 'services/apexrest/OrderService';

        
        reqUpdate.httpMethod = 'PATCH';
        reqUpdate.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = reqUpdate;
        RestContext.response= resUpdate;
        OrderService.patchOrder();
     
        //Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Order Service Name XYZTest'];
        //system.assertEquals(order2.Name, 'Order Service Name XYZTest');
        test.stopTest();
        
    }   
    static testMethod void testPatch2() {
    
        test.startTest();

        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];

        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;

        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;

        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;

        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLast100@test.com"}}'
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name XYZ'];
        system.assertEquals(order1.Name, 'Test Order Service Name XYZ');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='xyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
        
        String jsonStringUpdate = '{"OrderId":'+'""'+
                            ',"OECentralURL":""}';
       
        System.debug('jsonStringUpdate---->'+jsonStringUpdate);                        
        RestRequest reqUpdate = new RestRequest(); 
        RestResponse resUpdate = new RestResponse();             
        reqUpdate.requestURI = 'services/apexrest/OrderService';

        
        reqUpdate.httpMethod = 'PATCH';
        reqUpdate.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = reqUpdate;
        RestContext.response= resUpdate;
        OrderService.patchOrder();
     
        //Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Order Service Name XYZTest'];
        //system.assertEquals(order2.Name, 'Order Service Name XYZTest');
        test.stopTest();
        
    } 
    static testMethod void testPatch3() {
    
        test.startTest();

        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];

        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;

        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;

        Contact newContact = new Contact (FirstName = 'xyzFirst',LastName = 'XyZLast');
        insert newContact;

        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"TestLastName100",'+   
                                '"FirstName":"TestFirstName100",'+ 
                                '"Cancellation_Reason__c":"No Budget",'+
                                '"Cancellation_Fee__c":"No",'+
                                '"Status":"Cancelled",'+
                                '"User":"FirstLast100@test.com"}}'
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name XYZ'];
        system.assertEquals(order1.Name, 'Test Order Service Name XYZ');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='xyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
        
        String jsonStringUpdate = '{"OrderId":'+'"'+order1.Id+'"'+
                            ',"OECentralURL":"abc@123.com"}';
       
        System.debug('jsonStringUpdate---->'+jsonStringUpdate);                        
        RestRequest reqUpdate = new RestRequest(); 
        RestResponse resUpdate = new RestResponse();             
        reqUpdate.requestURI = 'services/apexrest/OrderService';

        
        reqUpdate.httpMethod = 'PATCH';
        reqUpdate.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = reqUpdate;
        RestContext.response= resUpdate;
        OrderService.patchOrder();
     
        //Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Order Service Name XYZTest'];
        //system.assertEquals(order2.Name, 'Order Service Name XYZTest');
        test.stopTest();
        
    }         
 }