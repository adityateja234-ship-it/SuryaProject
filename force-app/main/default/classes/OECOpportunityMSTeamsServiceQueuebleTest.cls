@isTest(seeAllData=false)
private class OECOpportunityMSTeamsServiceQueuebleTest {
    
    
     static testMethod void testPost() {
     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorOpportunity());
        
        //insert new Override_Validation_Rules__c(Name ='Override Validation Rules', Override_Order_Triggers__c = false);

        Product2 p = new Product2();
        p.Name = 'Test Product';
        p.Description='Test Product';
        p.productCode = 'ABC';
        p.isActive = true;
        insert p;
                
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = p.Id;
        standardPrice.UnitPrice = 240;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        
        // insert account
        Account acc = new Account(
            Name = 'SFDCPanther.com',
            Rating = 'Hot',
            Industry = 'Banking',
            Phone = '9087654321',
            External_Sync__c = true
        );
        
        insert acc;
        
        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            StageName = 'Discovery',
            Name='Test Opportunity',
            CloseDate=date.newInstance(2024, 12, 15),
            ForecastCategoryName ='Pipeline',
            Type='New Business',
            Opportunity_Subtype__c='Acquisition',
            LeadSource='Cold Call'
        
        );
        /*
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.id;
        lineItem.Quantity = 24;
        lineItem.UnitPrice = 240;
        lineItem.ListPrice =  240;
        lineItem.Product2id = p.id;
        lineItem.PricebookEntryId=standardPrice.id;
        insert lineItem; 
        //Test.startTest();
        Order syncedOrd = [select SyncStatus__c from Order where Name='Test Order Future'];
        syncedOrd.Status = 'In Progress';
        update syncedOrd;
        System.assertEquals('In Progress', syncedOrd.Status);
        //Test.stopTest();
        */
        
        insert opp;
        
        Opportunity updateOpp = [select StageName from Opportunity where id = :opp.Id];
        updateOpp.StageName ='Closed Won';
        update updateOpp;
        
     }
           
       
 }