// ************************************************************************************************//
//
//  Developer By : Nilesh Bharti 'Salesforce Consultant' (nilesh.bharti@openexc.com)
//  Created on : 12/09/2024
//  JIRA:- OEP-11091
//  
//  Last Modified on : 12/09/2024
//  
//  Description :
//  This Trigger takes care to sync Account in NS.
//  
//  Deployment : OEP-14229 on 21/12/2024
//
// ************************************************************************************************ //

trigger SalesforceOEINetsuiteAccountTrigger on Account (before insert, after insert, before update, after update) {
    
    boolean bypassOrderTriggers = Override_Validation_Rules__c.getValues('Override Validation Rules').Override_Account_Triggers__c;
    if(!bypassOrderTriggers){
        
        System.debug('------------->> In trigger');
        
        if(Trigger.isAfter && Trigger.isInsert){
            SfOEINsAccountHelper helper = new SfOEINsAccountHelper(Trigger.New, Trigger.newMap);
            System.debug('Trigger account after Insert -->>>>>>>>');
            helper.onAfterInsert(Trigger.New, Trigger.newMap);
        }
        
        if(Trigger.isAfter && Trigger.isUpdate){
            SfOEINsAccountHelper helper = new SfOEINsAccountHelper(Trigger.New, Trigger.newMap);
            system.debug('Trigger account after update -->>>>>>>>');
            helper.onAfterUpdate(Trigger.New, Trigger.newMap, Trigger.oldMap);
        }
        
        if(Trigger.isBefore && Trigger.isInsert){
            SfOEINsAccountHelper helper = new SfOEINsAccountHelper(Trigger.New, Trigger.newMap);
            system.debug('Trigger account before insert -->>>>>>>>');
            helper.onBeforeInsert(Trigger.New, Trigger.newMap);
        }
        
        if(Trigger.isBefore && Trigger.isUpdate){
            SfOEINsAccountHelper helper = new SfOEINsAccountHelper(Trigger.New, Trigger.newMap);
            system.debug('Trigger account before update -->>>>>>>>');
            helper.onBeforeUpdate(Trigger.New, Trigger.newMap, Trigger.old, Trigger.oldMap);
        }
    }
    
}