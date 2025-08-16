@isTest(seeAllData=true)
private class SalesforceOEINetAccountIntegr_Test {
    
    @isTest
    static void testCreateWithAuthSuccess() {
        
        Account testAccount = new Account(
            Name = 'Test Account 01',
            Account_Status__c = 'Active Customer',
            BillingStreet = '123 Test St',
            BillingCity = 'AS',
            BillingState = 'Alaska',
            BillingPostalCode = '12345',
            BillingCountry = 'United States',
            ShippingStreet = '123 Test St',
            ShippingCity = 'NY',
            ShippingState = 'New York',
            ShippingPostalCode = '12345',
            ShippingCountry = 'United States'
        );
        insert testAccount;
        
        Set<Id> accountIds = new Set<Id>{ testAccount.Id };
            
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SalesforceOEINetsuiteAccountIntegration job = new SalesforceOEINetsuiteAccountIntegration(accountIds);
        System.enqueueJob(job);
        
        Test.stopTest();
    }
    
    @isTest
    static void testCreateWithAuthFailure() {
        
        Account testAccount = new Account(
            Name = 'Test Account 02',
            Account_Status__c = 'Active Customer',
            BillingStreet = '123 Test St',
            BillingCity = 'NY',
            BillingState = 'New York',
            BillingPostalCode = '12345',
            BillingCountry = 'United States',
            ShippingStreet = '123 Test St',
            ShippingCity = 'NY',
            ShippingState = 'New York',
            ShippingPostalCode = '12345',
            ShippingCountry = 'United States'
        );
        insert testAccount;
        
        Set<Id> accountIds = new Set<Id>{testAccount.Id};
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse401());
        SalesforceOEINetsuiteAccountIntegration job = new SalesforceOEINetsuiteAccountIntegration(accountIds);
        System.enqueueJob(job);
            
        Test.stopTest();
    }
    
    @isTest
    static void testCreateSendAccWithAddrSuccess() {
        
        Account testAccountParent = new Account(
            Name = 'Parent Test Account'
        );
        insert testAccountParent;
        
        Account testAccount = new Account(
            Name = 'Test Account 03',
            Account_Status__c = 'Active Customer',
            ShippingStreet = '123 Test St',
            ShippingCity = 'NY',
            ShippingState = 'New York',
            ShippingPostalCode = '12345',
            ShippingCountry = 'United States',
            BillingCountry = 'India',
            ParentId = testAccountParent.Id
        );
        insert testAccount;
        
        Set<Id> accountIds = new Set<Id>{testAccount.Id};
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200WithCreation());
        SalesforceOEINetsuiteAccountIntegration job = new SalesforceOEINetsuiteAccountIntegration(accountIds);
        System.enqueueJob(job);
        
        Test.stopTest();
        
        Account updatedAccount = [SELECT Id, billingAddressId__c, shippingAddressId__c, Netsuite_External_Name__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals('331427', updatedAccount.billingAddressId__c, 'Billing address ID should be updated');
        System.assertEquals('331428', updatedAccount.shippingAddressId__c, 'Shipping address ID should be updated');
        System.assertEquals('82028', updatedAccount.Netsuite_External_Name__c, 'Netsuite ID should be updated');
    }
    
    @isTest
    static void testCreateSendAccWithoutAddrSuccess() {
        
        Account testAccountParent = new Account(
            Name = 'Parent Test Account'
        );
        insert testAccountParent;
        
        Account testAccount = new Account(
            Name = 'Test Account 04',
            Account_Status__c = 'Active Customer',
            ParentId = testAccountParent.Id
        );
        insert testAccount;
        
        Set<Id> accountIds = new Set<Id>{testAccount.Id};
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200WithCreation());
        SalesforceOEINetsuiteAccountIntegration job = new SalesforceOEINetsuiteAccountIntegration(accountIds);
        System.enqueueJob(job);
            
        Test.stopTest();
        
        Account updatedAccount = [SELECT Id, billingAddressId__c, shippingAddressId__c, Netsuite_External_Name__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals('82028', updatedAccount.Netsuite_External_Name__c, 'Netsuite ID should be updated');
    }
    
    @isTest
    static void testCreateSendAccFailure() {
        
        Account testAccountParent = new Account(
            Name = 'Parent Test Account'
        );
        insert testAccountParent;
        
        Account testAccount = new Account(
            Name = 'Test Account 05',
            Account_Status__c = 'Active Customer',
            BillingStreet = '123 Test St',
            BillingCity = 'TX',
            BillingState = 'Texas',
            BillingPostalCode = '12345',
            BillingCountry = 'United States',
            ShippingStreet = '123 Test St',
            ShippingCity = 'NY',
            ShippingState = 'New York',
            ShippingPostalCode = '12345',
            ShippingCountry = 'United States',
            ParentId = testAccountParent.Id
        );
        insert testAccount;
        
        Set<Id> accountIds = new Set<Id>{testAccount.Id};
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200WithCreationFailure());
        SalesforceOEINetsuiteAccountIntegration job = new SalesforceOEINetsuiteAccountIntegration(accountIds);
        System.enqueueJob(job);
            
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateWithAuthSuccess() {
        
        Account testAccount = new Account(
            Name = 'Test Account 01',
            Account_Status__c = 'Active Customer',
            BillingStreet = '123 Test St',
            BillingCity = 'AS',
            BillingState = 'Alaska',
            BillingPostalCode = '12345',
            BillingCountry = 'United States',
            ShippingStreet = '123 Test St',
            ShippingCity = 'NY',
            ShippingState = 'New York',
            ShippingPostalCode = '12345',
            ShippingCountry = 'United States'
        );
        insert testAccount;
        
        Set<Id> accountIds = new Set<Id>{ testAccount.Id };
            
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SalesforceOEINetsuiteAccountIntegration2 job = new SalesforceOEINetsuiteAccountIntegration2(accountIds);
        System.enqueueJob(job);
        
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateWithAuthFailure() {
        
        Account testAccount = new Account(
            Name = 'Test Account 02',
            Account_Status__c = 'Active Customer',
            BillingStreet = '123 Test St',
            BillingCity = 'NY',
            BillingState = 'New York',
            BillingPostalCode = '12345',
            BillingCountry = 'United States',
            ShippingStreet = '123 Test St',
            ShippingCity = 'NY',
            ShippingState = 'New York',
            ShippingPostalCode = '12345',
            ShippingCountry = 'United States'
        );
        insert testAccount;
        
        Set<Id> accountIds = new Set<Id>{testAccount.Id};
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse401());
        SalesforceOEINetsuiteAccountIntegration2 job = new SalesforceOEINetsuiteAccountIntegration2(accountIds);
        System.enqueueJob(job);
            
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateSendAccWithAddrSuccess() {
        
        Account testAccountParent = new Account(
            Name = 'Parent Test Account'
        );
        insert testAccountParent;
        
        Account testAccount = new Account(
            Name = 'Test Account 03',
            Account_Status__c = 'Active Customer',
            ShippingStreet = '123 Test St',
            ShippingCity = 'NY',
            ShippingState = 'New York',
            ShippingPostalCode = '12345',
            ShippingCountry = 'United States',
            BillingCountry = 'India',
            ParentId = testAccountParent.Id
        );
        insert testAccount;
        
        Set<Id> accountIds = new Set<Id>{testAccount.Id};
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200WithCreation());
        SalesforceOEINetsuiteAccountIntegration2 job = new SalesforceOEINetsuiteAccountIntegration2(accountIds);
        System.enqueueJob(job);
        
        Test.stopTest();
        
        Account updatedAccount = [SELECT Id, billingAddressId__c, shippingAddressId__c, Netsuite_External_Name__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals('331427', updatedAccount.billingAddressId__c, 'Billing address ID should be updated');
        System.assertEquals('331428', updatedAccount.shippingAddressId__c, 'Shipping address ID should be updated');
        System.assertEquals('82028', updatedAccount.Netsuite_External_Name__c, 'Netsuite ID should be updated');
    }
    
    @isTest
    static void testUpdateSendAccWithoutAddrSuccess() {
        
        Account testAccountParent = new Account(
            Name = 'Parent Test Account'
        );
        insert testAccountParent;
        
        Account testAccount = new Account(
            Name = 'Test Account 04',
            Account_Status__c = 'Active Customer',
            ParentId = testAccountParent.Id
        );
        insert testAccount;
        
        Set<Id> accountIds = new Set<Id>{testAccount.Id};
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200WithCreation());
        SalesforceOEINetsuiteAccountIntegration2 job = new SalesforceOEINetsuiteAccountIntegration2(accountIds);
        System.enqueueJob(job);
            
        Test.stopTest();
        
        Account updatedAccount = [SELECT Id, billingAddressId__c, shippingAddressId__c, Netsuite_External_Name__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals('82028', updatedAccount.Netsuite_External_Name__c, 'Netsuite ID should be updated');
    }
    
    @isTest
    static void testUpdateSendAccFailure() {
        
        Account testAccountParent = new Account(
            Name = 'Parent Test Account'
        );
        insert testAccountParent;
        
        Account testAccount = new Account(
            Name = 'Test Account 05',
            Account_Status__c = 'Active Customer',
            BillingStreet = '123 Test St',
            BillingCity = 'TX',
            BillingState = 'Texas',
            BillingPostalCode = '12345',
            BillingCountry = 'United States',
            ShippingStreet = '123 Test St',
            ShippingCity = 'NY',
            ShippingState = 'New York',
            ShippingPostalCode = '12345',
            ShippingCountry = 'United States',
            ParentId = testAccountParent.Id
        );
        insert testAccount;
        
        Set<Id> accountIds = new Set<Id>{testAccount.Id};
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200WithCreationFailure());
        SalesforceOEINetsuiteAccountIntegration2 job = new SalesforceOEINetsuiteAccountIntegration2(accountIds);
        System.enqueueJob(job);
            
        Test.stopTest();
    }
    
    public class MockHttpResponse200 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"idToken":"mockedIdToken"}');
            return res;
        }
    }
    
    public class MockHttpResponse401 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(401);
            res.setBody('{"error":"Authentication failed"}');
            return res;
        }
    }
    
    public class MockHttpResponse200WithCreation implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"data": {"billingAddressId": "331427", "shippingAddressId": "331428", "internalId": "82028"}}');
            return res;
        }
    }
    
    public class MockHttpResponse200WithCreationFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"data": {"error":"Something went wrong!!!"}}');
            return res;
        }
    }
    
}