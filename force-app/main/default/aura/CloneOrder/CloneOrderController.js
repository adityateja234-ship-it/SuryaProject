({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        console.log('recordId'+recordId);
        var action = component.get("c.getOrderDetails");
        action.setParams({ 
                "orderId" : recordId
            });
        action.setCallback(this, function(response){
            var state = response.getState();
            var todayDate = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({ 
                "entityApiName": "Order",
                "defaultFieldValues":{
                    "AccountId" : result.AccountId,
                    "CustomerAuthorizedById" : result.CustomerAuthorizedById,
                    "Status" : "New",
                    "Name"   : "",
                    "Start_Date_Time__c" : "",
                    "End_Date_Time__c"  : "",
                    "Client_Cost_Code__c"  : "",
                    "Account_Legal_Entity__c" : "OpenExchange",
                    "Lasso_URL__c"  : "",
                    "Veracast_Event_ID__c"  : "",
                    "No_Sync_to_External_Systems__c" : "false",
                    "RecordTypeId" : result.RecordTypeId,
                    "EffectiveDate" : todayDate,
                   
                  "ContractId" : result.ContractId,
                    "Veracast_Conference_ID__c" : result.Veracast_Conference_ID__c
                }                
            });
            createRecordEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})