@isTest
global class MockHttpResponseGenerator2 implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://qa-oe-api.com/auth', req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        /**
        Account acc = [select id from Account where Name='TestAccountName100']; 
        Contact cc = [select id from contact where FirstName='xyzFirst'];
        //Contract co = [select id from contract where Name='TestContract100'];
        
        Order ord = new Order (Status='New', Region__c='APAC', Requester_Contact__c=cc.Id, Meeting_Complexity__c='2 - Medium', EffectiveDate= date.newInstance(2021, 12, 15),Start_Date_Time__c=datetime.newInstance(2021, 12, 18), End_Date_Time__c=datetime.newInstance(2021, 12, 20), Event_Type_OE_Defined__c='Virtual Conference', Name='Test Order Future',Order_TimeZone__c='(GMT+5:30) India', CurrencyIsoCode='USD',AccountId=acc.id,Description='Test Description',EventNotes__c='Test Notes');
        insert Ord;
        */
        Order ord = [Select id from Order limit 1];
        res.setBody('{"errorMessages":"Failed to Test","example":"test","idToken":"asdfasdfiuy254kdfakjf","eventLink":"https://connect.qa-oe-central.com/account/243/events/691495/meetings/list","orderId":"'+ord.Id+'"}');
        res.setStatusCode(200);
        return res;
    }
}