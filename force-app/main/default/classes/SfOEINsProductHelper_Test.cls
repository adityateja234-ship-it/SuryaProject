@isTest(seeAllData=true)
public class SfOEINsProductHelper_Test {
    
    @isTest
    static void testOnAfterInsert() {
        
        Product2 validProduct = new Product2(
            Name = 'Valid Product',
            OE_Product_Name__c = 'Valid OE Product',
            Description = 'Product Description',
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Family = 'Add-on',
            Sub_Product_Family__c = 'Equipment',
            IsActive = true,
            Product_Ticket_Number__c = 'NS-1001'
        );
        insert validProduct;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SfOEINsProductHelper helper = new SfOEINsProductHelper(new List<Product2> { validProduct }, new Map<Id, Product2> { validProduct.Id => validProduct });
        helper.onAfterInsert(new List<Product2> { validProduct }, new Map<Id, Product2> { validProduct.Id => validProduct });
        
        Test.stopTest();
    }
    
    @isTest
    static void testOnAfterUpdate() {
        
        Product2 validProduct = new Product2(
            Name = 'Valid Product',
            OE_Product_Name__c = 'Valid OE Product',
            Description = 'Product Description',
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Family = 'Add-on',
            Sub_Product_Family__c = 'Equipment',
            IsActive = true,
            Product_Ticket_Number__c = 'NS-1001'
        );
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Product2 productNew = new Product2(
            Id = validProduct.Id, 
            Name = 'Product Name Updated', 
            OE_Product_Name__c = 'Valid OE Product',
            Description = 'Product Description',
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Family = 'Add-on',
            Sub_Product_Family__c = 'Equipment',
            IsActive = true,
            Product_Ticket_Number__c = 'NS-1001'
        );
        SfOEINsProductHelper helper = new SfOEINsProductHelper(new List<Product2> { productNew }, new Map<Id, Product2> { productNew.Id => productNew });
        helper.onAfterUpdate(new List<Product2> { productNew }, new Map<Id, Product2> { productNew.Id => productNew }, new Map<Id, Product2> { validProduct.Id => validProduct });
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testOnBeforeInsert() {
        
        Product2 duplicateProduct = new Product2(
            Name = 'Duplicate Product',
            Product_Ticket_Number__c = 'NS-1001',
            OE_Product_Name__c = 'Valid OE Product',
            Description = 'Product Description',
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates'
        );
        insert duplicateProduct;
        
        Product2 newProduct = new Product2(
            Name = 'Duplicate Product',
            Product_Ticket_Number__c = 'NS-1001',
            OE_Product_Name__c = 'Valid OE Product',
            Description = 'Product Description',
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SfOEINsProductHelper helper = new SfOEINsProductHelper(new List<Product2>{newProduct}, new Map<Id, Product2>{newProduct.Id => newProduct});
        helper.onBeforeInsert(new List<Product2>{newProduct}, new Map<Id, Product2>{newProduct.Id => newProduct});
        
        Test.stopTest();
        
        System.assertEquals(1, newProduct.getErrors().size(), 'There should be a duplicate error');
    }
    
    @isTest
    static void testOnBeforeInsertNull() {
        
        Product2 newProduct = new Product2(
            Name = null,
            Product_Ticket_Number__c = 'NS-1001',
            OE_Product_Name__c = 'Valid OE Product',
            Description = 'Product Description',
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SfOEINsProductHelper helper = new SfOEINsProductHelper(new List<Product2>{newProduct}, new Map<Id, Product2>{newProduct.Id => newProduct});
        helper.onBeforeInsert(new List<Product2>{newProduct}, new Map<Id, Product2>{newProduct.Id => newProduct});
        
        Test.stopTest();
    }
    
    @isTest
    static void testOnBeforeUpdate() {
        
        Product2 validProduct = new Product2(
            Name = 'Valid Product',
            OE_Product_Name__c = 'Valid OE Product',
            Description = 'Product Description',
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Family = 'Add-on',
            Sub_Product_Family__c = 'Equipment',
            IsActive = true,
            Product_Ticket_Number__c = 'NS-1001'
        );
        insert validProduct;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Product2 productNew = new Product2(
            Id = validProduct.Id, 
            Name = 'Product Name Updated', 
            OE_Product_Name__c = 'Valid OE Product',
            Description = 'Product Description',
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Family = 'Add-on',
            Sub_Product_Family__c = 'Equipment',
            IsActive = true,
            Product_Ticket_Number__c = 'NS-1001'
        );
        SfOEINsProductHelper helper = new SfOEINsProductHelper(new List<Product2> { productNew }, new Map<Id, Product2> { productNew.Id => productNew });
        helper.onBeforeUpdate(new List<Product2> { productNew }, new Map<Id, Product2> { productNew.Id => productNew }, 
                              new List<Product2> { validProduct }, new Map<Id, Product2> { validProduct.Id => validProduct });
        
        Test.stopTest();
        
        System.assertEquals(0, productNew.getErrors().size(), 'There should be no error on OE Product name update');
    }
    
    @isTest
    static void testValidProductToProcess1() {
        
        Product2 newProduct = new Product2(
            Name = null,
            OE_Product_Name__c = 'Existing OE Product',
            Description = 'Product Description',
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Family = 'Add-on',
            Sub_Product_Family__c = 'Equipment',
            IsActive = true,
            Product_Ticket_Number__c = 'NS-1001'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SfOEINsProductHelper helper = new SfOEINsProductHelper(new List<Product2> { newProduct }, new Map<Id, Product2>());
        System.assert(!helper.validProductToProcess( newProduct ));
        
        Test.stopTest();
    }
    
    @isTest
    static void testValidProductToProcess2() {
        
        Product2 newProduct = new Product2(
            Name = 'Something',
            OE_Product_Name__c = null,
            Description = 'Product Description',
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Family = 'Add-on',
            Sub_Product_Family__c = 'Equipment',
            IsActive = true,
            Product_Ticket_Number__c = 'NS-1001'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SfOEINsProductHelper helper = new SfOEINsProductHelper(new List<Product2> { newProduct }, new Map<Id, Product2>());
        System.assert(!helper.validProductToProcess( newProduct ));
        
        Test.stopTest();
    }
    
    @isTest
    static void testValidProductToProcess3() {
        
        Product2 newProduct = new Product2(
            Name = 'Something',
            OE_Product_Name__c = 'OE Product Something',
            Description = 'Product Description',
            Revenue_Recognition_Rule__c = null,
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Family = 'Add-on',
            Sub_Product_Family__c = 'Equipment',
            IsActive = true,
            Product_Ticket_Number__c = 'NS-1001'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SfOEINsProductHelper helper = new SfOEINsProductHelper(new List<Product2> { newProduct }, new Map<Id, Product2>());
        System.assert(!helper.validProductToProcess( newProduct ));
        
        Test.stopTest();
    }
    
    @isTest
    static void testValidProductToProcess4() {
        
        Product2 newProduct = new Product2(
            Name = 'Something',
            OE_Product_Name__c = 'OE Product Something',
            Description = 'Product Description',
            Revenue_Recognition_Rule__c = 'Straight-line, Flexible Dates',
            Rev_Rec_Forecast_Rule__c = null,
            Family = 'Add-on',
            Sub_Product_Family__c = 'Equipment',
            IsActive = true,
            Product_Ticket_Number__c = 'NS-1001'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SfOEINsProductHelper helper = new SfOEINsProductHelper(new List<Product2> { newProduct }, new Map<Id, Product2>());
        System.assert(!helper.validProductToProcess( newProduct ));
        
        Test.stopTest();
    }
    
    @isTest
    static void testValidations3() {
        
        Product2 productOld = new Product2(
            Name = 'Old Name',
            OE_Product_Name__c= 'OE Old Name',
            Product_Ticket_Number__c = 'NS-1001',
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates'
        );
        insert productOld;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Product2 productNew = new Product2(Id = productOld.Id, Name = 'Old Name', OE_Product_Name__c = 'OE New Name', Product_Ticket_Number__c = 'NS-1001');
        SfOEINsProductHelper helper = new SfOEINsProductHelper(new List<Product2>(), new Map<Id, Product2>());
        System.assert(helper.validProductToProcessUpdate( productNew, new Map<Id, Product2>{productOld.Id => productOld}));
        
        Test.stopTest();
    }
    
    @isTest
    static void testValidations4() {
        
        Product2 productOld = new Product2(
            Name = 'Old Name',
            OE_Product_Name__c= 'OE Old Name',
            Product_Ticket_Number__c = 'NS-1001',
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates'
        );
        insert productOld;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Product2 productNew = new Product2(
            Id = productOld.Id, Name = 'Old Name', OE_Product_Name__c = 'OE Old Name', 
            Revenue_Recognition_Rule__c = 'Straight-line, Flexible Dates', Product_Ticket_Number__c = 'NS-1001'
        );
        SfOEINsProductHelper helper = new SfOEINsProductHelper(new List<Product2>(), new Map<Id, Product2>());
        System.assert(helper.validProductToProcessUpdate( productNew, new Map<Id, Product2>{productOld.Id => productOld}));
        
        Test.stopTest();
    }
    
    @isTest
    static void testValidations5() {
        
        Product2 productOld = new Product2(
            Name = 'Old Name',
            OE_Product_Name__c= 'OE Old Name',
            Product_Ticket_Number__c = 'NS-1001',
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates'
        );
        insert productOld;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Product2 productNew = new Product2(
            Id = productOld.Id, Name = 'Old Name', OE_Product_Name__c = 'OE Old Name', 
            Revenue_Recognition_Rule__c = 'OE Immediate', 
            Rev_Rec_Forecast_Rule__c = 'OE Immediate',
            Product_Ticket_Number__c = 'NS-1001'
        );
        SfOEINsProductHelper helper = new SfOEINsProductHelper(new List<Product2>(), new Map<Id, Product2>());
        System.assert(helper.validProductToProcessUpdate( productNew, new Map<Id, Product2>{productOld.Id => productOld}));
        
        Test.stopTest();
    }
    
    @isTest
    static void testValidations6() {
        
        Product2 productOld = new Product2(
            Name = 'Old Name',
            OE_Product_Name__c= 'OE Old Name',
            Family = 'Add-on',
            Product_Ticket_Number__c = 'NS-1001',
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates'
        );
        insert productOld;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Product2 productNew = new Product2(
            Id = productOld.Id, Name = 'Old Name', OE_Product_Name__c = 'OE Old Name', 
            Revenue_Recognition_Rule__c = 'OE Immediate', 
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Family = 'Meeting', Product_Ticket_Number__c = 'NS-1001'
        );
        SfOEINsProductHelper helper = new SfOEINsProductHelper(new List<Product2>(), new Map<Id, Product2>());
        System.assert(helper.validProductToProcessUpdate( productNew, new Map<Id, Product2>{productOld.Id => productOld}));
        
        Test.stopTest();
    }
    
    @isTest
    static void testValidations7() {
        
        Product2 productOld = new Product2(
            Name = 'Old Name',
            OE_Product_Name__c= 'OE Old Name',
            Family = 'Add-on',
            Description = 'Old description',
            Product_Ticket_Number__c = 'NS-1001',
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates'
        );
        insert productOld;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Product2 productNew = new Product2(
            Id = productOld.Id, Name = 'Old Name', OE_Product_Name__c = 'OE Old Name', 
            Revenue_Recognition_Rule__c = 'OE Immediate', Family = 'Add-on',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Description = 'New description', Product_Ticket_Number__c = 'NS-1001'
        );
        SfOEINsProductHelper helper = new SfOEINsProductHelper(new List<Product2>(), new Map<Id, Product2>());
        System.assert(helper.validProductToProcessUpdate( productNew, new Map<Id, Product2>{productOld.Id => productOld}));
        
        Test.stopTest();
    }
    
    @isTest
    static void testValidations8() {
        
        Product2 productOld = new Product2(
            Name = 'Old Name',
            OE_Product_Name__c= 'OE Old Name',
            Family = 'Add-on',
            Description = 'Old description',
            IsActive = true,
            Product_Ticket_Number__c = 'NS-1001',
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates'
        );
        insert productOld;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Product2 productNew = new Product2(
            Id = productOld.Id, Name = 'Old Name', OE_Product_Name__c = 'OE Old Name', 
            Revenue_Recognition_Rule__c = 'OE Immediate', Family = 'Add-on',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates',
            Description = 'Old description',
            IsActive = false, Product_Ticket_Number__c = 'NS-1001'
        );
        SfOEINsProductHelper helper = new SfOEINsProductHelper(new List<Product2>(), new Map<Id, Product2>());
        System.assert(helper.validProductToProcessUpdate( productNew, new Map<Id, Product2>{productOld.Id => productOld}));
        
        Test.stopTest();
    }
    
    @isTest
    static void testValidations9() {
        
        Product2 productOld = new Product2(
            Name = 'Old Name',
            OE_Product_Name__c= 'OE Old Name',
            Family = 'Add-on',
            Description = 'Old description',
            IsActive = true,
            Product_Ticket_Number__c = 'NS-1001',
            Revenue_Recognition_Rule__c = 'OE Immediate',
            Rev_Rec_Forecast_Rule__c = 'Straight-line, Flexible Dates'
        );
        insert productOld;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Product2 productNew = new Product2(Id = productOld.Id);
        SfOEINsProductHelper helper = new SfOEINsProductHelper(new List<Product2>(), new Map<Id, Product2>());
        System.assert(!helper.validProductToProcessUpdate( productNew, new Map<Id, Product2>{productOld.Id => productOld}));
        
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
    
}