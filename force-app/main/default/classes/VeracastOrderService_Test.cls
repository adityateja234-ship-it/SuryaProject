@isTest(seeAllData=true)
private class VeracastOrderService_Test {
    

    static testMethod void testPost() { // Positive test case
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZ'];
        system.assertEquals(order1.Name, 'Test Order Service Name Veracast XYZ');
        //system.assertEquals(acc.Description, 'Testing');
        
    }
   
    static testMethod void testPost2() { // Negative MeetingComplexity
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Mediumm","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();

     
    }
    static testMethod void testPost3() {// Negative Status
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"NewStatus","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
        
    }
    static testMethod void testPost4() { // Negative OrderCurrency
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ","EventType":"Virtual Conference","OrderCurrency":"UKD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();

        
    } 
    
    static testMethod void testPost5() { // Negative Blank Account ID
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();

    }   
        
    static testMethod void testPost6() { // Negative EventName Greater than 80
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ Test Order Service Name Test Order Service Name Test Order Service Name Test Order Service Name","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
        
    } 
    static testMethod void testPost7() { // Negative Blank TimeZone
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
        
    }   
    static testMethod void testPost8() { // Negative All Blanks 
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"","Status":"","Region":"AMER","OrderEnteredDate":"","EventName":"","EventType":"","OrderCurrency":"","StartDate":"","EndDate":"","TimeZone":"","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
        
    }
    static testMethod void testPut1() { // Positive test case
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZ'];
        system.assertEquals(order1.Name, 'Test Order Service Name Veracast XYZ');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
              
        String jsonStringUpdate = '{"Account":'+'"'+acc2.Id+'"'+
                            ',"Contact":'+'"'+cc2.Id+'"'+
                            ',"Contract":'+'"'+co2.Id+'"'+
                            ',"OrderId":'+'"'+order1.Id+'"'+  
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZUpdate","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonStringUpdate);
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req2.httpMethod = 'PUT';
        req2.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = req2;
        RestContext.response= res2;
        VeracastOrderService.updateOrder();
     
        //Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZUpdate'];
        //system.assertEquals(order2.Name, 'Test Order Service Name Veracast XYZUpdate');        
        
    }           

    static testMethod void testPut2() { // Negative test case
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZ'];
        system.assertEquals(order1.Name, 'Test Order Service Name Veracast XYZ');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
              
        String jsonStringUpdate = '{"Account":'+'"'+acc2.Id+'"'+
                            ',"Contact":'+'"'+cc2.Id+'"'+
                            ',"Contract":'+'"'+co2.Id+'"'+
                            ',"OrderId":'+'"'+order1.Id+'"'+  
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"3 - Medium","Status":"Cancelled","Region":"AMERICA","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZUpdate","EventType":"Virtual Conference","OrderCurrency":"USDD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonStringUpdate);
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req2.httpMethod = 'PUT';
        req2.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = req2;
        RestContext.response= res2;
        VeracastOrderService.updateOrder();
     
        //Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZUpdate'];
        //system.assertEquals(order2.Name, 'Test Order Service Name Veracast XYZUpdate');        
        
    }

    static testMethod void testPut3() { // Positive test case
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZ'];
        system.assertEquals(order1.Name, 'Test Order Service Name Veracast XYZ');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
              
        String jsonStringUpdate = '{"Account":'+'"'+acc2.Id+'"'+
                            ',"Contact":'+'"'+cc2.Id+'"'+
                            ',"Contract":'+'"'+co2.Id+'"'+
                            ',"OrderId":'+'"'+order1.Id+'"'+  
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZUpdate","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName1000",'+    
                                '"FirstName":"VeracastTestFirstName1000",'+
                                '"User":""},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName1000",'+    
                                '"FirstName":"TestFirstName1000",'+
                                '"User":""},{'+ 
                                '"LastName":"TestLastName1001",'+    
                                '"FirstName":"TestFirstName1001",'+
                                '"User":""}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonStringUpdate);
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req2.httpMethod = 'PUT';
        req2.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = req2;
        RestContext.response= res2;
        VeracastOrderService.updateOrder();
     
        //Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZUpdate'];
        //system.assertEquals(order2.Name, 'Test Order Service Name Veracast XYZUpdate');        
        
    } 

    static testMethod void testPut4() { // Positive test case
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZ'];
        system.assertEquals(order1.Name, 'Test Order Service Name Veracast XYZ');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
              
        String jsonStringUpdate = '{"Account":'+'"'+acc2.Id+'"'+
                            ',"Contact":'+'"'+cc2.Id+'"'+
                            ',"Contract":'+'"'+co2.Id+'"'+
                            ',"OrderId":'+'"'+order1.Id+'"'+  
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZUpdate","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName1000",'+    
                                '"FirstName":"VeracastTestFirstName1000",'+
                                '"User":""},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName1000",'+    
                                '"FirstName":"TestFirstName1000",'+
                                '"User":"FirstLastMgr1test.com"},{'+ 
                                '"LastName":"TestLastName1001",'+    
                                '"FirstName":"TestFirstName1001",'+
                                '"User":"FirstLastMgr2test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonStringUpdate);
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req2.httpMethod = 'PUT';
        req2.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = req2;
        RestContext.response= res2;
        VeracastOrderService.updateOrder();
     
        //Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZUpdate'];
        //system.assertEquals(order2.Name, 'Test Order Service Name Veracast XYZUpdate');        
        
    }  

    static testMethod void testPut5() { // Positive test case
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZ'];
        system.assertEquals(order1.Name, 'Test Order Service Name Veracast XYZ');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
              
        String jsonStringUpdate = '{"Account":'+'"'+acc2.Id+'"'+
                            ',"Contact":'+'"'+cc2.Id+'"'+
                            ',"Contract":'+'"'+co2.Id+'"'+
                            ',"OrderId":'+'"'+order1.Id+'"'+  
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZUpdate","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName1000",'+    
                                '"FirstName":"VeracastTestFirstName1000",'+
                                '"User":""},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName1000",'+    
                                '"FirstName":"TestFirstName1000",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName1001",'+    
                                '"FirstName":"TestFirstName1001",'+
                                '"User":"FirstLastMgr2test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonStringUpdate);
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req2.httpMethod = 'PUT';
        req2.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = req2;
        RestContext.response= res2;
        VeracastOrderService.updateOrder();
     
        //Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZUpdate'];
        //system.assertEquals(order2.Name, 'Test Order Service Name Veracast XYZUpdate');        
        
    }       

    static testMethod void testPut6() { // Positive test case
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZ'];
        system.assertEquals(order1.Name, 'Test Order Service Name Veracast XYZ');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
              
        String jsonStringUpdate = '{"Account":'+'"'+acc2.Id+'"'+
                            ',"Contact":'+'"'+cc2.Id+'"'+
                            ',"Contract":'+'"'+co2.Id+'"'+
                            ',"OrderId":'+'"'+order1.Id+'"'+  
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZUpdate","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName1000",'+    
                                '"FirstName":"VeracastTestFirstName1000",'+
                                '"User":""},'+
                            '"ProjectManager":[{'+
                                '"LastName":"",'+    
                                '"FirstName":"TestFirstName1000",'+
                                '"User":"FirstLastMgr1test.com"},{'+ 
                                '"LastName":"TestLastName1001",'+    
                                '"FirstName":"TestFirstName1001",'+
                                '"User":"FirstLastMgr@2test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonStringUpdate);
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req2.httpMethod = 'PUT';
        req2.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = req2;
        RestContext.response= res2;
        VeracastOrderService.updateOrder();
     
        //Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZUpdate'];
        //system.assertEquals(order2.Name, 'Test Order Service Name Veracast XYZUpdate');        
        
    }       
    /*
    static testMethod void testPut7() { // Negative test case Event Name > 80 OR Invalid Timezone
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ Test Order Service Name Veracast XYZ Test Order Service Name Veracast XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZ Test Order Service Name Veracast XYZ Test O'];
        system.assertEquals(order1.Name, 'Test Order Service Name Veracast XYZ Test Order Service Name Veracast XYZ Test O');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
              
        String jsonStringUpdate = '{"Account":'+'"'+acc2.Id+'"'+
                            ',"Contact":'+'"'+cc2.Id+'"'+
                            ',"Contract":'+'"'+co2.Id+'"'+
                            ',"OrderId":'+'"'+order1.Id+'"'+  
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"3 - Medium","Status":"Cancelled","Region":"AMERICA","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ Test Order Service Name Veracast XYZ Test Mrder Service Name Veracast XYZUpdate","EventType":"Virtual Conference","OrderCurrency":"USDD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonStringUpdate);
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req2.httpMethod = 'PUT';
        req2.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = req2;
        RestContext.response= res2;
        VeracastOrderService.updateOrder();
     
        //Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZUpdate'];
        //system.assertEquals(order2.Name, 'Test Order Service Name Veracast XYZUpdate');        
        
    }
    */
    static testMethod void testPut7() { // // Negative test case Event Name > 80
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZ'];
        system.assertEquals(order1.Name, 'Test Order Service Name Veracast XYZ');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
              
        String jsonStringUpdate = '{"Account":'+'"'+acc2.Id+'"'+
                            ',"Contact":'+'"'+cc2.Id+'"'+
                            ',"Contract":'+'"'+co2.Id+'"'+
                            ',"OrderId":'+'"'+order1.Id+'"'+  
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ Test Order Service Name Veracast XYZ Test Mrder Service Name Veracast XYZUpdate","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonStringUpdate);
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req2.httpMethod = 'PUT';
        req2.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = req2;
        RestContext.response= res2;
        VeracastOrderService.updateOrder();
     
        //Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZUpdate'];
        //system.assertEquals(order2.Name, 'Test Order Service Name Veracast XYZUpdate');        
        
    } 

    static testMethod void testPut8() { // // Invalid Timezone
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZPUT8","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZPUT8'];
        system.assertEquals(order1.Name, 'Test Order Service Name Veracast XYZPUT8');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
              
        String jsonStringUpdate = '{"Account":'+'"'+acc2.Id+'"'+
                            ',"Contact":'+'"'+cc2.Id+'"'+
                            ',"Contract":'+'"'+co2.Id+'"'+
                            ',"OrderId":'+'"'+order1.Id+'"'+  
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ Test Order Service Name Veracast XYZ Test Mrder Service Name Veracast XYZUpdate","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonStringUpdate);
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req2.httpMethod = 'PUT';
        req2.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = req2;
        RestContext.response= res2;
        VeracastOrderService.updateOrder();
     
        //Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZUpdate'];
        //system.assertEquals(order2.Name, 'Test Order Service Name Veracast XYZUpdate');        
        
    }     

    static testMethod void testPut9() { // // Invalid Order Number
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZPUT8","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZPUT8'];
        system.assertEquals(order1.Name, 'Test Order Service Name Veracast XYZPUT8');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
              
        String jsonStringUpdate = '{"Account":'+'"'+acc2.Id+'"'+
                            ',"Contact":'+'"'+cc2.Id+'"'+
                            ',"Contract":'+'"'+co2.Id+'"'+
                            ',"OrderId":'+'"'+cc2.Id+'"'+  
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ Test Order Service Name Veracast XYZ Test Mrder Service Name Veracast XYZUpdate","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonStringUpdate);
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req2.httpMethod = 'PUT';
        req2.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = req2;
        RestContext.response= res2;
        VeracastOrderService.updateOrder();
     
        //Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZUpdate'];
        //system.assertEquals(order2.Name, 'Test Order Service Name Veracast XYZUpdate');        
        
    }
    
    static testMethod void testPut11() { // Negative test case Invalid Region in Put
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZ'];
        system.assertEquals(order1.Name, 'Test Order Service Name Veracast XYZ');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
              
        String jsonStringUpdate = '{"Account":'+'"'+acc2.Id+'"'+
                            ',"Contact":'+'"'+cc2.Id+'"'+
                            ',"Contract":'+'"'+co2.Id+'"'+
                            ',"OrderId":'+'"'+order1.Id+'"'+  
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER1","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZUpdate","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC1"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonStringUpdate);
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req2.httpMethod = 'PUT';
        req2.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = req2;
        RestContext.response= res2;
        VeracastOrderService.updateOrder();
     
        //Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZUpdate'];
        //system.assertEquals(order2.Name, 'Test Order Service Name Veracast XYZUpdate');        
        
    }  
    
    static testMethod void testPut12() { // Negative test case Blank Event Name Error Message
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZ'];
        system.assertEquals(order1.Name, 'Test Order Service Name Veracast XYZ');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
              
        String jsonStringUpdate = '{"Account":'+'"'+acc2.Id+'"'+
                            ',"Contact":'+'"'+cc2.Id+'"'+
                            ',"Contract":'+'"'+co2.Id+'"'+
                            ',"OrderId":'+'"'+order1.Id+'"'+  
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonStringUpdate);
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req2.httpMethod = 'PUT';
        req2.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = req2;
        RestContext.response= res2;
        VeracastOrderService.updateOrder();
     
        //Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZUpdate'];
        //system.assertEquals(order2.Name, 'Test Order Service Name Veracast XYZUpdate');        
        
    }    

    static testMethod void testPut13() { // Negative test case Order status in Cancelled status
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Bank of America OEConference Custom Price Book'];
        System.debug('100----------------->>');
        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;
        System.debug('101----------------->>');
        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        System.debug('102----------------->>');
        Contact newContact = new Contact (FirstName = 'VeracastxyzFirst',LastName = 'VeracastXyZLast');
        insert newContact;
        System.debug('103----------------->>');
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZ","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonString);
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        VeracastOrderService.insertOrder();
        
        Order canOrder = [ SELECT Id, Cancellation_Reason__c, Cancellation_Other__c, Cancellation_Fee__c, status, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZ'];
        canOrder.Cancellation_Reason__c = 'Other';
        canOrder.Cancellation_Other__c ='No Budget';
        canOrder.Cancellation_Fee__c ='No';
        canOrder.Status ='Cancelled';
        update canOrder;
        
     
        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZ'];
        system.assertEquals(order1.Name, 'Test Order Service Name Veracast XYZ');
        //system.assertEquals(acc.Description, 'Testing');
        
        Account acc2 = [select id from Account where Name='TestAccountName100']; 
        Contact cc2 = [select id from contact where FirstName='VeracastxyzFirst'];
        Contract co2 = [select id from contract where Name='TestContract100'];
              
        String jsonStringUpdate = '{"Account":'+'"'+acc2.Id+'"'+
                            ',"Contact":'+'"'+cc2.Id+'"'+
                            ',"Contract":'+'"'+co2.Id+'"'+
                            ',"OrderId":'+'"'+order1.Id+'"'+  
                            ',"VeracastConferenceID":"ConferenceID","VeracastEventID":"EventID"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name Veracast XYZUpdate","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata","Description":"Test Description","EventNotes":"Test Event Notes","Region":"APAC"'+
                            ',"RequesterContact":{'+
                                '"LastName":"VeracastTestLastName100",'+    
                                '"FirstName":"VeracastTestFirstName100",'+
                                '"User":"VeracastFirstLast100@test.com"},'+
                            '"ProjectManager":[{'+
                                '"LastName":"TestLastName100",'+    
                                '"FirstName":"TestFirstName100",'+
                                '"User":"FirstLastMgr1@test.com"},{'+ 
                                '"LastName":"TestLastName101",'+    
                                '"FirstName":"TestFirstName101",'+
                                '"User":"FirstLastMgr2@test.com"}]}'    
                                ;
        
        System.debug('JsonString ----->'+jsonStringUpdate);
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();             
        req.requestURI = 'services/apexrest/VeracastOrderService';

        
        req2.httpMethod = 'PUT';
        req2.requestBody = Blob.valueof(jsonStringUpdate);
        RestContext.request = req2;
        RestContext.response= res2;
        VeracastOrderService.updateOrder();
     
        //Order order2 = [ SELECT Id, Name FROM Order WHERE Name ='Test Order Service Name Veracast XYZUpdate'];
        //system.assertEquals(order2.Name, 'Test Order Service Name Veracast XYZUpdate');        
        
    }                                            

 }