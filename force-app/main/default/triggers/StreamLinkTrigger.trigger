trigger StreamLinkTrigger on Order (after update) {

    
    boolean bypassOrderTriggers=Override_Validation_Rules__c.getValues('Override Validation Rules').Override_Order_Triggers__c;
       
    //OECSyncManualOrdersHelper helper = new OECSyncManualOrdersHelper(trigger.New, trigger.newMap);
    if(!bypassOrderTriggers)
    {
        System.debug('StreamLinkTrigger------------->> In trigger');

        if(trigger.isAfter && trigger.isUpdate)// && !checkRecursive.firstcall)
        {
            StreamLinkHelper helper = new StreamLinkHelper(trigger.New, trigger.newMap);
            System.debug('StreamLinkTrigger------------->> In trigger onAfterUpdate');
            //System.debug('------------->> System.isBatch()'+ System.isBatch());
            helper.onAfterUpdate(trigger.New, trigger.newMap, trigger.oldMap);

        }
 
    }
}