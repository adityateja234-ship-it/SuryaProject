trigger OECOpportunityMSTeamsTrigger on Opportunity (after update) {

    
    //boolean bypassOrderTriggers=Override_Validation_Rules__c.getValues('Override Validation Rules').Override_Order_Triggers__c;
       
    OECOpportunityMSTeamsHelper helper = new OECOpportunityMSTeamsHelper(trigger.New, trigger.newMap);
    //if(!bypassOrderTriggers)
    if(true)
    {
        System.debug('------------->> In OECOpportunityMSTeamsHelper trigger');
        if(trigger.isAfter && trigger.isUpdate)// && !checkRecursive.firstcall)
        {
            System.debug('------------->> In OECOpportunityMSTeamsHelper trigger onAfterUpdate');
            helper.onAfterUpdate(trigger.New, trigger.newMap);

        }
    }
}