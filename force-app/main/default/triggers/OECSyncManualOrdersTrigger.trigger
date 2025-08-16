trigger OECSyncManualOrdersTrigger on Order (before insert, after insert, before update, after update) {
    
    
    boolean bypassOrderTriggers = Override_Validation_Rules__c.getValues('Override Validation Rules').Override_Order_Triggers__c;
    boolean bypassNetsuiteIntegration = Override_Validation_Rules__c.getValues('Override Validation Rules').IsSFNSIntegrationEnabled__c;
    
    if(!bypassOrderTriggers) {
        System.debug('------------->> In trigger');
        if(trigger.isBefore && trigger.isUpdate){
            System.debug('------------->> In trigger onBeforeUpdate');
            OECSyncManualOrdersHelper helper = new OECSyncManualOrdersHelper(trigger.New, trigger.newMap);
            helper.onBeforeUpdate(trigger.New, trigger.newMap,trigger.Old, trigger.oldMap);
        }
        
        if(trigger.isAfter && trigger.isUpdate){
            System.debug('------------->> In trigger onAfterUpdate');
            
            if(!bypassNetsuiteIntegration){
                //**************Added by Nilesh Bharti as a Part of Jira OEP-12783*******************//
                SfOEINsOrderHelper orderSync = new SfOEINsOrderHelper(trigger.New, trigger.newMap);
                orderSync.onAfterUpdate(trigger.New, trigger.newMap, trigger.oldMap);
                //***********************************************************************************//
            }
            
            OECSyncManualOrdersHelper helper = new OECSyncManualOrdersHelper(trigger.New, trigger.newMap);
            helper.onAfterUpdate(trigger.New, trigger.newMap, trigger.oldMap);
        }
        
        if(trigger.isAfter && trigger.isInsert){
            System.debug('------------->> In trigger onAfterInsert');
        }
        
        if(trigger.isBefore && trigger.isInsert){
            System.debug('------------->> In trigger onBeforeInsert');
            OECSyncManualOrdersHelper helper = new OECSyncManualOrdersHelper(trigger.New, trigger.newMap);
            helper.onBeforeInsert(trigger.New, trigger.newMap);
        }
    }
}