// ************************************************************************************************//
//
//  Developer By : Nilesh Bharti 'Salesforce Consultant' (nilesh.bharti@openexc.com)
//  Created on : 08/10/2024
//  JIRA:- OEP-11872
//  
//  Last Modified on : 08/10/2024
//  
//  Description :
//  This Trigger takes care to sync Product in NS.
//
// ************************************************************************************************ //


trigger SalesforceOEINetsuiteProductTrigger on Product2 (before insert, after insert, before update, after update) {
    
    boolean bypassOrderTriggers = Override_Validation_Rules__c.getValues('Override Validation Rules').Override_Product_Triggers__c;
    if(!bypassOrderTriggers){
        
        System.debug('------------->> In trigger');
        
        if(Trigger.isAfter && Trigger.isInsert){
            SfOEINsProductHelper helper = new SfOEINsProductHelper(Trigger.New, Trigger.newMap);
            System.debug('Trigger product after Insert -->>>>>>>>');
            helper.onAfterInsert(Trigger.New, Trigger.newMap);
        }
        
        if(Trigger.isAfter && Trigger.isUpdate){
            SfOEINsProductHelper helper = new SfOEINsProductHelper(Trigger.New, Trigger.newMap);
            system.debug('Trigger product after update -->>>>>>>>');
            helper.onAfterUpdate(Trigger.New, Trigger.newMap, Trigger.oldMap);
        }
        
        if(Trigger.isBefore && Trigger.isInsert){
            SfOEINsProductHelper helper = new SfOEINsProductHelper(Trigger.New, Trigger.newMap);
            system.debug('Trigger product before insert -->>>>>>>>');
            helper.onBeforeInsert(Trigger.New, Trigger.newMap);
        }
        
        if(Trigger.isBefore && Trigger.isUpdate){
            SfOEINsProductHelper helper = new SfOEINsProductHelper(Trigger.New, Trigger.newMap);
            system.debug('Trigger product before update -->>>>>>>>');
            helper.onBeforeUpdate(Trigger.New, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
    }
    
}