@isTest(seeAllData=true)
public class SfOEINsAccountHelper_Test {
    
    @isTest
    static void testOnAfterInsert() {
        
        Account validAccount = new Account(
            Name = 'Valid Account',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            ShippingCountry = 'India'
        );
        insert validAccount;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{validAccount}, new Map<Id, Account>{validAccount.Id => validAccount});
        helper.onAfterInsert(new List<Account>{validAccount}, new Map<Id, Account>{validAccount.Id => validAccount});
        
        Test.stopTest();
        
        //System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE Status = 'Completed'], 'The job should have been queued for processing');
    }
    
    @isTest
    static void testOnAfterUpdate() {
        
        Account validAccount = new Account(
            Name = 'Valid Account',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            ShippingCountry = 'India'
        );
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Account accountNew = new Account(
            Id = validAccount.Id,
            Name = 'Update Account',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            ShippingCountry = 'India'
        );
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{accountNew}, new Map<Id, Account>{accountNew.Id => accountNew});
        helper.onAfterUpdate(new List<Account>{accountNew}, new Map<Id, Account>{accountNew.Id => accountNew}, new Map<Id, Account>{validAccount.Id => validAccount});
        
        Test.stopTest();
        
        //System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE Status = 'Completed'], 'The job should have been queued for processing after update');
    }
    
    @isTest
    static void testOnBeforeInsert() {
        
        Account duplicateAccount = new Account(
            Name = 'Duplicate Account',
            Account_Status__c = 'Active Customer'
        );
        insert duplicateAccount;
        
        Account newAccount = new Account(
            Name = 'Duplicate Account',
            Account_Status__c = 'Active Customer'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{newAccount}, new Map<Id, Account>{newAccount.Id => newAccount});
        helper.onBeforeInsert(new List<Account>{newAccount}, new Map<Id, Account>{newAccount.Id => newAccount});
        
        Test.stopTest();
        
        System.assertEquals(1, newAccount.getErrors().size(), 'There should be a duplicate error');
    }
    
    @isTest
    static void testOnBeforeInsertNull() {
        
        Account newAccount = new Account(
            Name = null,
            Account_Status__c = 'Active Customer'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{newAccount}, new Map<Id, Account>{newAccount.Id => newAccount});
        helper.onBeforeInsert(new List<Account>{newAccount}, new Map<Id, Account>{newAccount.Id => newAccount});
        
        Test.stopTest();
    }
    
    @isTest
    static void testOnBeforeUpdate() {
        
        Account validAccount = new Account(
            Name = 'Valid Account',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            ShippingCountry = 'India'
        );
        insert validAccount;
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Account accountNew = new Account(
            Id = validAccount.Id,
            Name = 'Updated Account',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            ShippingCountry = 'India'
        );
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{accountNew}, new Map<Id, Account>{accountNew.Id => accountNew});
        helper.onBeforeUpdate(new List<Account>{accountNew}, new Map<Id, Account>{accountNew.Id => accountNew}, 
                              new List<Account>{validAccount}, new Map<Id, Account>{validAccount.Id => validAccount});
        
        Test.stopTest();
        
        System.assertEquals(0, accountNew.getErrors().size(), 'There should be no error on account name update');
    }
    
    @isTest
    static void validAccountToProcess1() {
        
        Account invalidAccount = new Account(
            Name = null,
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            ShippingCountry = 'India'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{invalidAccount}, new Map<Id, Account>{invalidAccount.Id => invalidAccount});
        System.assert(!helper.validAccountToProcess( invalidAccount ));
        
        Test.stopTest();
    }
    
    @isTest
    static void validAccountToProcess2() {
        
        Account invalidAccount = new Account(
            Name = null,
            Account_Status__c = 'Prospect',
            BillingCountry = 'India',
            ShippingCountry = 'India'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{invalidAccount}, new Map<Id, Account>{invalidAccount.Id => invalidAccount});
        System.assert(!helper.validAccountToProcess( invalidAccount ));
        
        Test.stopTest();
    }
    
    @isTest
    static void validAccountToProcessUpdate1() {
        
        Account validAccount = new Account(
            Name = 'Something',
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
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Account invalidAccount = new Account(
            Id = validAccount.Id,
            Name = null,
            Account_Status__c = null,
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
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{invalidAccount}, new Map<Id, Account>{invalidAccount.Id => invalidAccount});
        System.assert(!helper.validAccountToProcessUpdate( invalidAccount, new Map<Id, Account>{validAccount.Id => validAccount}));
        
        Test.stopTest();
    }
    
    @isTest
    static void validAccountToProcessUpdate2() {
        
        Account validAccount = new Account(
            Name = 'Something',
            Account_Status__c = 'Prospect',
            BillingCountry = 'India',
            ShippingCountry = 'India'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Account invalidAccount = new Account(
            Id = validAccount.Id,
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            ShippingCountry = 'India'
        );
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{invalidAccount}, new Map<Id, Account>{invalidAccount.Id => invalidAccount});
        System.assert(helper.validAccountToProcessUpdate( invalidAccount, new Map<Id, Account>{validAccount.Id => validAccount}));
        
        Test.stopTest();
    }
    
    @isTest
    static void validAccountToProcessUpdate3() {
        
        Account oldParent = new Account(
            Name = 'Old Parent',
            Account_Status__c = 'Prospect',
            BillingCountry = 'India',
            ShippingCountry = 'India'
        );
        insert oldParent;
        
        Account newParent = new Account(
            Name = 'New Parent',
            Account_Status__c = 'Prospect',
            BillingCountry = 'India',
            ShippingCountry = 'India'
        );
        insert newParent;
        
        Account validAccount = new Account(
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            ParentId = oldParent.Id,
            BillingCountry = 'India',
            ShippingCountry = 'India'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Account newValidAccount = new Account(
            Id = validAccount.Id,
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            ParentId = newParent.Id,
            BillingCountry = 'India',
            ShippingCountry = 'India'
        );
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{newValidAccount}, new Map<Id, Account>{newValidAccount.Id => newValidAccount});
        System.assert(helper.validAccountToProcessUpdate( newValidAccount, new Map<Id, Account>{validAccount.Id => validAccount}));
        
        Test.stopTest();
    }
    
    @isTest
    static void validAccountToProcessUpdate4() {
        
        Account validAccount = new Account(
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            ShippingCountry = 'India'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Account newValidAccount = new Account(
            Id = validAccount.Id,
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'United States',
            ShippingCountry = 'India'
        );
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{newValidAccount}, new Map<Id, Account>{newValidAccount.Id => newValidAccount});
        System.assert(helper.validAccountToProcessUpdate( newValidAccount, new Map<Id, Account>{validAccount.Id => validAccount}));
        
        Test.stopTest();
    }
    
    @isTest
    static void validAccountToProcessUpdate5() {
        
        Account validAccount = new Account(
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            BillingStreet = 'Koppa Gate',
            ShippingCountry = 'India'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Account newValidAccount = new Account(
            Id = validAccount.Id,
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            BillingStreet = 'Vega City',
            ShippingCountry = 'India'
        );
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{newValidAccount}, new Map<Id, Account>{newValidAccount.Id => newValidAccount});
        System.assert(helper.validAccountToProcessUpdate( newValidAccount, new Map<Id, Account>{validAccount.Id => validAccount}));
        
        Test.stopTest();
    }
    
    @isTest
    static void validAccountToProcessUpdate6() {
        
        Account validAccount = new Account(
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            BillingStreet = 'Koppa Gate',
            BillingCity = 'Bangalore',
            ShippingCountry = 'India'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Account newValidAccount = new Account(
            Id = validAccount.Id,
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            BillingStreet = 'Koppa Gate',
            BillingCity = 'Hydrabad',
            ShippingCountry = 'India'
        );
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{newValidAccount}, new Map<Id, Account>{newValidAccount.Id => newValidAccount});
        System.assert(helper.validAccountToProcessUpdate( newValidAccount, new Map<Id, Account>{validAccount.Id => validAccount}));
        
        Test.stopTest();
    }
    
    @isTest
    static void validAccountToProcessUpdate7() {
        
        Account validAccount = new Account(
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            BillingStreet = 'Koppa Gate',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka',
            ShippingCountry = 'India'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Account newValidAccount = new Account(
            Id = validAccount.Id,
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            BillingStreet = 'Koppa Gate',
            BillingCity = 'Bangalore',
            BillingState = 'Himachal Pradesh',
            ShippingCountry = 'India'
        );
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{newValidAccount}, new Map<Id, Account>{newValidAccount.Id => newValidAccount});
        System.assert(helper.validAccountToProcessUpdate( newValidAccount, new Map<Id, Account>{validAccount.Id => validAccount}));
        
        Test.stopTest();
    }
    
    @isTest
    static void validAccountToProcessUpdate8() {
        
        Account validAccount = new Account(
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            BillingStreet = 'Koppa Gate',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka',
            BillingPostalCode = '560076',
            ShippingCountry = 'India'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Account newValidAccount = new Account(
            Id = validAccount.Id,
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            BillingStreet = 'Koppa Gate',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka',
            BillingPostalCode = '425210',
            ShippingCountry = 'India'
        );
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{newValidAccount}, new Map<Id, Account>{newValidAccount.Id => newValidAccount});
        System.assert(helper.validAccountToProcessUpdate( newValidAccount, new Map<Id, Account>{validAccount.Id => validAccount}));
        
        Test.stopTest();
    }
    
    @isTest
    static void validAccountToProcessUpdate9() {
        
        Account validAccount = new Account(
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            BillingStreet = 'Koppa Gate',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka',
            BillingPostalCode = '560076',
            ShippingCountry = 'India'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Account newValidAccount = new Account(
            Id = validAccount.Id,
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            BillingStreet = 'Koppa Gate',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka',
            BillingPostalCode = '560076',
            ShippingCountry = 'United States'
        );
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{newValidAccount}, new Map<Id, Account>{newValidAccount.Id => newValidAccount});
        System.assert(helper.validAccountToProcessUpdate( newValidAccount, new Map<Id, Account>{validAccount.Id => validAccount}));
        
        Test.stopTest();
    }
    
    @isTest
    static void validAccountToProcessUpdate10() {
        
        Account validAccount = new Account(
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            ShippingStreet = 'Koppa Gate',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka',
            BillingPostalCode = '560076',
            ShippingCountry = 'India'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Account newValidAccount = new Account(
            Id = validAccount.Id,
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            ShippingStreet = 'Vega City',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka',
            BillingPostalCode = '560076',
            ShippingCountry = 'India'
        );
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{newValidAccount}, new Map<Id, Account>{newValidAccount.Id => newValidAccount});
        System.assert(helper.validAccountToProcessUpdate( newValidAccount, new Map<Id, Account>{validAccount.Id => validAccount}));
        
        Test.stopTest();
    }
    
    @isTest
    static void validAccountToProcessUpdate11() {
        
        Account validAccount = new Account(
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            ShippingStreet = 'Koppa Gate',
            ShippingCity = 'Bangalore',
            BillingState = 'Karnataka',
            BillingPostalCode = '560076',
            ShippingCountry = 'India'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Account newValidAccount = new Account(
            Id = validAccount.Id,
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            ShippingStreet = 'Koppa Gate',
            ShippingCity = 'Hydrabad',
            BillingState = 'Karnataka',
            BillingPostalCode = '560076',
            ShippingCountry = 'India'
        );
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{newValidAccount}, new Map<Id, Account>{newValidAccount.Id => newValidAccount});
        System.assert(helper.validAccountToProcessUpdate( newValidAccount, new Map<Id, Account>{validAccount.Id => validAccount}));
        
        Test.stopTest();
    }
    
    @isTest
    static void validAccountToProcessUpdate12() {
        
        Account validAccount = new Account(
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            ShippingStreet = 'Koppa Gate',
            ShippingCity = 'Bangalore',
            ShippingState = 'Karnataka',
            BillingPostalCode = '560076',
            ShippingCountry = 'India'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Account newValidAccount = new Account(
            Id = validAccount.Id,
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            ShippingStreet = 'Koppa Gate',
            ShippingCity = 'Bangalore',
            ShippingState = 'Himachal Pradesh',
            BillingPostalCode = '560076',
            ShippingCountry = 'India'
        );
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{newValidAccount}, new Map<Id, Account>{newValidAccount.Id => newValidAccount});
        System.assert(helper.validAccountToProcessUpdate( newValidAccount, new Map<Id, Account>{validAccount.Id => validAccount}));
        
        Test.stopTest();
    }
    
    @isTest
    static void validAccountToProcessUpdate13() {
        
        Account validAccount = new Account(
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            ShippingStreet = 'Koppa Gate',
            ShippingCity = 'Bangalore',
            ShippingState = 'Karnataka',
            ShippingPostalCode = '560076',
            ShippingCountry = 'India'
        );
            
            Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse200());
        Account newValidAccount = new Account(
            Id = validAccount.Id,
            Name = 'Something',
            Account_Status__c = 'Active Customer',
            BillingCountry = 'India',
            ShippingStreet = 'Koppa Gate',
            ShippingCity = 'Bangalore',
            ShippingState = 'Karnataka',
            ShippingPostalCode = '425210',
            ShippingCountry = 'India'
        );
        SfOEINsAccountHelper helper = new SfOEINsAccountHelper(new List<Account>{newValidAccount}, new Map<Id, Account>{newValidAccount.Id => newValidAccount});
        System.assert(helper.validAccountToProcessUpdate( newValidAccount, new Map<Id, Account>{validAccount.Id => validAccount}));
        
        Test.stopTest();
    }
    
    private class MockHttpResponse200 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}');
            return res;
        }
    }
}