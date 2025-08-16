@isTest(seeAllData=true)
private class OrderProductService_Test {
    
    static testMethod void testPost() { // Conference Main

        PriceBook2 pb = [select id from PriceBook2 where Name='Citi OEConference Custom Price Book'];

        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;

        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;
        
        Contact newContact = new Contact (FirstName = 'First100',LastName = 'Last');
        insert newContact;
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='First100'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();

        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Citi - Creditas - Group Meeting'];
                
        system.assertEquals(order1.Name, 'Citi - Creditas - Group Meeting');
        
        String jsonProductString = '{"OrderId":'+'"'+order1.Id+'"'+
                                    //',"pricebookType":"Conference"'+
                                    ',"orderProducts":  [{'+
                                    '"productName": "01t3w000006H0jtAAC"'+
                                    ',"quantity": "1"}]}';                             

        RestRequest prodreq = new RestRequest(); 
        RestResponse prodres = new RestResponse();             
        prodreq.requestURI = 'services/apexrest/OrderProductService';

        
        prodreq.httpMethod = 'POST';
        prodreq.requestBody = Blob.valueof(jsonProductString);
        RestContext.request = prodreq;
        RestContext.response= prodres;
        OrderProductService.insertProduct();
        Order orderProd = [ SELECT Id, Name, (select Id from OrderItems) FROM Order WHERE Name ='Citi - Creditas - Group Meeting'];
        system.assertEquals(orderProd.OrderItems.size(), 1);

    }
    
    
    static testMethod void testPost2() {   // Conference All blank

        PriceBook2 pb = [select id from PriceBook2 where Name='Citi OEConference Custom Price Book'];

        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;

        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;

        Contact newContact = new Contact (FirstName = 'First100',LastName = 'Last');
        insert newContact;

        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='First100'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();

        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Citi - Creditas - Group Meeting'];
        system.assertEquals(order1.Name, 'Citi - Creditas - Group Meeting');

        
        String jsonProductString = '{"OrderId":""'+
                                    //',"pricebookType":""'+
                                    ',"orderProducts":  [{'+
                                    '"productName": ""'+
                                    ',"quantity": ""}]}';                             

        RestRequest prodreq = new RestRequest(); 
        RestResponse prodres = new RestResponse();             
        prodreq.requestURI = 'services/apexrest/OrderProductService';

        
        prodreq.httpMethod = 'POST';
        prodreq.requestBody = Blob.valueof(jsonProductString);
        RestContext.request = prodreq;
        RestContext.response= prodres;
        OrderProductService.insertProduct();
        Order orderProd = [ SELECT Id, Name, (select Id from OrderItems) FROM Order WHERE Name ='Citi - Creditas - Group Meeting'];
        system.assertEquals(orderProd.OrderItems.size(), 1);
     
    }
    
    static testMethod void testPost3() {  //// Conference Invalid LENGTH OrderID

        PriceBook2 pb = [select id from PriceBook2 where Name='Citi OEConference Custom Price Book'];

        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;

        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;

        Contact newContact = new Contact (FirstName = 'First100',LastName = 'Last');
        insert newContact;
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='First100'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();

        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Citi - Creditas - Group Meeting'];
        system.assertEquals(order1.Name, 'Citi - Creditas - Group Meeting');
        
        String jsonProductString = '{"OrderId":'+'"'+order1.Id+'S'+'"'+
                                    //',"pricebookType":"Conference"'+
                                    ',"orderProducts":  [{'+
                                    '"productName": "01t3w000006H0jtAAC"'+
                                    ',"quantity": "1"}]}';                             

        RestRequest prodreq = new RestRequest(); 
        RestResponse prodres = new RestResponse();             
        prodreq.requestURI = 'services/apexrest/OrderProductService';

        
        prodreq.httpMethod = 'POST';
        prodreq.requestBody = Blob.valueof(jsonProductString);
        RestContext.request = prodreq;
        RestContext.response= prodres;
        OrderProductService.insertProduct();
        Order orderProd = [ SELECT Id, Name, (select Id from OrderItems) FROM Order WHERE Name ='Citi - Creditas - Group Meeting'];
        system.assertEquals(orderProd.OrderItems.size(), 1);
        
    }
    
    static testMethod void testPost4() { // Conference Order ID

        PriceBook2 pb = [select id from PriceBook2 where Name='Citi OEConference Custom Price Book'];

        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;

        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;

        Contact newContact = new Contact (FirstName = 'First100',LastName = 'Last');
        insert newContact;
        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='First100'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();

        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Citi - Creditas - Group Meeting'];
        system.assertEquals(order1.Name, 'Citi - Creditas - Group Meeting');
        
        String orderStringId = order1.Id;
        orderStringId.replaceFirst('8','7');
        
        String jsonProductString = '{"OrderId":'+'"'+orderStringId+'"'+
                                    //',"pricebookType":"Conference"'+
                                    ',"orderProducts":  [{'+
                                    '"productName": "01t3w000006H0jtAAC"'+
                                    ',"quantity": "1"}]}';                           

        RestRequest prodreq = new RestRequest(); 
        RestResponse prodres = new RestResponse();             
        prodreq.requestURI = 'services/apexrest/OrderProductService';

        
        prodreq.httpMethod = 'POST';
        prodreq.requestBody = Blob.valueof(jsonProductString);
        RestContext.request = prodreq;
        RestContext.response= prodres;
        OrderProductService.insertProduct();
        Order orderProd = [ SELECT Id, Name, (select Id from OrderItems) FROM Order WHERE Name ='Citi - Creditas - Group Meeting'];
         
    } 
    
    static testMethod void testPost5() {  // Connect Main

        PriceBook2 pb = [select id from PriceBook2 where Name='Citi OEConnect Custom Price Book'];

        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;

        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;

        Contact newContact = new Contact (FirstName = 'First100',LastName = 'Last');
        insert newContact;

        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='First100'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();

        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Citi - Creditas - Group Meeting'];

        system.assertEquals(order1.Name, 'Citi - Creditas - Group Meeting');

        
        String jsonProductString = '{"OrderId":'+'"'+order1.Id+'"'+
                                    //',"pricebookType":"Connect"'+
                                    ',"orderProducts":  [{'+
                                    '"productName": "01t3w000006H0jtAAC"'+
                                    ',"quantity": "1"}]}'; 
                                                               

        RestRequest prodreq = new RestRequest(); 
        RestResponse prodres = new RestResponse();             
        prodreq.requestURI = 'services/apexrest/OrderProductService';

        
        prodreq.httpMethod = 'POST';
        prodreq.requestBody = Blob.valueof(jsonProductString);
        RestContext.request = prodreq;
        RestContext.response= prodres;
        OrderProductService.insertProduct();
        Order orderProd = [ SELECT Id, Name, (select Id from OrderItems) FROM Order WHERE Name ='Citi - Creditas - Group Meeting'];
        system.assertEquals(orderProd.OrderItems.size(), 1);

    }   
        
    static testMethod void testPost6() {
        System.debug('1----------------->>');
        PriceBook2 pb = [select id from PriceBook2 where Name='Citi OEConference Custom Price Book'];

        Account newAccount = new Account (Name = 'TestAccountName100',CurrencyIsoCode='USD',Company_Type__c='Buy Side',Account_Status__c='Customer');
        insert newAccount;

        Contract newContract = new Contract (Name = 'TestContract100',AccountId=newAccount.Id,Status='Draft', Business_Line__c = 'OE Conference',Pricebook2=pb,CurrencyIsoCode='USD');
        insert newContract;

        Contact newContact = new Contact (FirstName = 'First100',LastName = 'Last');
        insert newContact;

        
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='First100'];
        Contract co = [select id from contract where Name='TestContract100'];
              
        String jsonString = '{"Account":'+'"'+acc.Id+'"'+
                            ',"Contact":'+'"'+cc.Id+'"'+
                            ',"Contract":'+'"'+co.Id+'"'+
                            ',"MeetingComplexity":"2 - Medium","Status":"New","Region":"AMER","OrderEnteredDate":"2021-05-09","EventName":"Test Order Service Name","EventType":"Virtual Conference","OrderCurrency":"USD","StartDate":"2021-05-10T10:27:54.14Z","EndDate":"2021-05-11T10:37:54.14Z","TimeZone":"Asia/Kolkata"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'services/apexrest/OrderService';

        
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonString);
        RestContext.request = req;
        RestContext.response= res;
        OrderService.insertOrder();

        Order order1 = [ SELECT Id, Name FROM Order WHERE Name ='Citi - Creditas - Group Meeting'];
        system.assertEquals(order1.Name, 'Citi - Creditas - Group Meeting');
        //system.assertEquals(acc.Description, 'Testing');
        
         String jsonProductString = '{"OrderId":'+'"'+order1.Id+'"'+
                                    //',"pricebookType":"Conference"'+
                                    ',"orderProducts":  [{'+
                                    '"productName": "01t3w000006H0jtAAC"'+
                                    ',"quantity": "1"}]}'; 
                                                              

        RestRequest prodreq = new RestRequest(); 
        RestResponse prodres = new RestResponse();             
        prodreq.requestURI = 'services/apexrest/OrderProductService';

        
        prodreq.httpMethod = 'POST';
        prodreq.requestBody = Blob.valueof(jsonProductString);
        RestContext.request = prodreq;
        RestContext.response= prodres;
        OrderProductService.insertProduct();
        Order orderProd = [ SELECT Id, Name, (select Id from OrderItems) FROM Order WHERE Name ='Citi - Creditas - Group Meeting'];
        system.assertEquals(orderProd.OrderItems.size(), 1);

    }  
 }