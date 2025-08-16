@isTest(seeAllData=true)
public class SalesforceOEINetProductIntegr_Test {
    
    @isTest
    static void createTestAuthSuccess() {
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Description = 'Test Description',
            Family = 'Add-on',
            Sub_Product_Family__c = 'Equipment',
            OE_Product_Name__c = 'Test OE Product',
            IsActive = true,
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Product_Ticket_Number__c = 'NS-1001'
        );
        insert testProduct;

        Set<Id> productIds = new Set<Id>{ testProduct.Id };
            
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SalesforceOEINetsuiteProductIntegration job = new SalesforceOEINetsuiteProductIntegration(productIds);
        System.enqueueJob(job);
        
        Test.stopTest();
        
        Product2 updatedProduct = [SELECT Id, Netsuite_Creation_Message__c, Netsuite_Id__c FROM Product2 WHERE Id = :testProduct.Id];
        System.assertEquals(updatedProduct.Netsuite_Id__c, null, 'The Netsuite_Id__c should have been populated');
    }

    @isTest
    static void createTestAuthFailure() {
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Description = 'Test Description',
            Family = 'Add-on',
            Sub_Product_Family__c = 'Equipment',
            OE_Product_Name__c = 'Test OE Product',
            IsActive = true,
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Product_Ticket_Number__c = 'NS-1001'
        );
        insert testProduct;

        Set<Id> productIds = new Set<Id>{ testProduct.Id };
            
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse401());
        SalesforceOEINetsuiteProductIntegration job = new SalesforceOEINetsuiteProductIntegration(productIds);
        System.enqueueJob(job);
        
        Test.stopTest();
        
        Product2 updatedProduct = [SELECT Id, Netsuite_Creation_Message__c FROM Product2 WHERE Id = :testProduct.Id];
        System.assert(updatedProduct.Netsuite_Creation_Message__c.contains('Authentication failed at Creation'),'The error message should contain "Authentication failed at Creation"');
    }

    @isTest
    static void createTestProductSuccess() {
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Description = 'Test Description',
            Family = 'Add-on',
            Sub_Product_Family__c = 'Equipment',
            OE_Product_Name__c = 'Test OE Product',
            IsActive = true,
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Product_Ticket_Number__c = 'NS-1001'
        );
        insert testProduct;

        Set<Id> productIds = new Set<Id>{ testProduct.Id };
            
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200WithCreation());
        SalesforceOEINetsuiteProductIntegration job = new SalesforceOEINetsuiteProductIntegration(productIds);
        System.enqueueJob(job);
        
        Test.stopTest();
        
        Product2 updatedProduct = [SELECT Id, Netsuite_Id__c FROM Product2 WHERE Id = :testProduct.Id];
        System.assertEquals('12345', updatedProduct.Netsuite_Id__c,'Success');
    }
    
    @isTest
    static void createTestProductFailure() {
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Description = 'Test Description',
            Family = 'Add-on',
            Sub_Product_Family__c = 'Equipment',
            OE_Product_Name__c = 'Test OE Product',
            IsActive = true,
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Product_Ticket_Number__c = 'NS-1001'
        );
        insert testProduct;

        Set<Id> productIds = new Set<Id>{ testProduct.Id };
            
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200WithCreationFailure());        
        SalesforceOEINetsuiteProductIntegration job = new SalesforceOEINetsuiteProductIntegration(productIds);
        System.enqueueJob(job);
        
        Test.stopTest();
        
        Product2 updatedProduct = [SELECT Id, Netsuite_Creation_Message__c FROM Product2 WHERE Id = :testProduct.Id];
        System.assert(updatedProduct.Netsuite_Creation_Message__c.contains('Creation failed'),'The error message should contain "Creation failed"');
    }
    
    @isTest
    static void updateTestAuthSuccess() {
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Description = 'Test Description',
            Family = 'Add-on',
            Sub_Product_Family__c = 'Equipment',
            OE_Product_Name__c = 'Test OE Product',
            IsActive = true,
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Product_Ticket_Number__c = 'NS-1001'
        );
        insert testProduct;

        Set<Id> productIds = new Set<Id>{ testProduct.Id };
            
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SalesforceOEINetsuiteProductIntegration2 job = new SalesforceOEINetsuiteProductIntegration2(productIds);
        System.enqueueJob(job);
        
        Test.stopTest();
        
        Product2 updatedProduct = [SELECT Id, Netsuite_Id__c FROM Product2 WHERE Id = :testProduct.Id];
        System.assertEquals(updatedProduct.Netsuite_Id__c, null, 'The Netsuite_Id__c should have been populated');
    }

    @isTest
    static void updateTestAuthFailure() {
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Description = 'Test Description',
            Family = 'Add-on',
            Sub_Product_Family__c = 'Equipment',
            OE_Product_Name__c = 'Test OE Product',
            IsActive = true,
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Product_Ticket_Number__c = 'NS-1001'
        );
        insert testProduct;

        Set<Id> productIds = new Set<Id>{ testProduct.Id };
            
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse401());
        SalesforceOEINetsuiteProductIntegration2 job = new SalesforceOEINetsuiteProductIntegration2(productIds);
        System.enqueueJob(job);
        
        Test.stopTest();
        
        Product2 updatedProduct = [SELECT Id, Netsuite_Creation_Message__c FROM Product2 WHERE Id = :testProduct.Id];
        System.assert(updatedProduct.Netsuite_Creation_Message__c.contains('Authentication failed at Updation'),'The error message should contain "Authentication failed at Updation"');
    }

    @isTest
    static void updateTestProductSuccess() {
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Description = 'Test Description',
            Family = 'Add-on',
            Sub_Product_Family__c = 'Equipment',
            OE_Product_Name__c = 'Test OE Product',
            IsActive = true,
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Product_Ticket_Number__c = 'NS-1001',
            Netsuite_Id__c = null
        );
        insert testProduct;
        
        testProduct.Ghost_Update__c = false;
        update testProduct;

        Set<Id> productIds = new Set<Id>{ testProduct.Id };
            
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200WithCreation());
        SalesforceOEINetsuiteProductIntegration2 job = new SalesforceOEINetsuiteProductIntegration2(productIds);
        System.enqueueJob(job);
        
        Test.stopTest();
        
        Product2 updatedProduct = [SELECT Id, Netsuite_Id__c FROM Product2 WHERE Id = :testProduct.Id];
        System.assertEquals('12345', updatedProduct.Netsuite_Id__c,'Success');
    }
    
    @isTest
    static void updateTestProductFailure() {
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            Description = 'Test Description',
            Family = 'Add-on',
            Sub_Product_Family__c = 'Equipment',
            OE_Product_Name__c = 'Test OE Product',
            IsActive = true,
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Product_Ticket_Number__c = 'NS-1001'
        );
        insert testProduct;

        Set<Id> productIds = new Set<Id>{ testProduct.Id };
            
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200WithCreationFailure());        
        SalesforceOEINetsuiteProductIntegration2 job = new SalesforceOEINetsuiteProductIntegration2(productIds);
        System.enqueueJob(job);
        
        Test.stopTest();
        
        Product2 updatedProduct = [SELECT Id, Netsuite_Creation_Message__c FROM Product2 WHERE Id = :testProduct.Id];
        System.assert(updatedProduct.Netsuite_Creation_Message__c.contains('Updation failed'),'The error message should contain "Updation failed"');
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
            res.setBody('{"data": {"internalId": "12345"}}');
            return res;
        }
    }
    
    public class MockHttpResponse200WithCreationFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"data": {}}');
            return res;
        }
    }

}