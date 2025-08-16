({
	doInit : function(component, event, helper) {
		var recid = component.get("v.recordId");
        console.log('recid::'+recid);
        var action = component.get("c.getOrderDetails");
        action.setParams({ orderId: recid});
        action.setCallback(this, function(response) { 
	var state = response.getState();
	console.log(state);
	if (state === "SUCCESS") {
		var returnData = response.getReturnValue();
		console.log('response :'+JSON.stringify(returnData));
        component.set("v.status", returnData.Status);
        if (returnData.Status == 'New' || returnData.Status == 'In Progress' || returnData.Status == 'Delivered'){
            component.set("v.showPriceBookUpdate", true);
        }
        	}
});
$A.enqueueAction(action);
	},
    updatePricebook : function(component, event, helper) {
        helper.showSpinner(component, event, helper);
    var priceBookId = component.find("priceBookId").get("v.value");
        var recid = component.get("v.recordId");
     console.log('priceBookId in continue::'+priceBookId);
        var action = component.get("c.updatePriceBook");
        action.setParams({ orderId: recid, priceBookId: priceBookId, status: component.get("v.status")});
        action.setCallback(this, function(response) { 
	var state = response.getState();
	console.log(state);
	if (state === "SUCCESS") {
		var returnData = response.getReturnValue();
		console.log('response :'+JSON.stringify(returnData));
        if(returnData != ''){
            component.set("v.errorMsg", returnData);
        }
        else{
        var navEvt = $A.get("e.force:navigateToSObject");
        			navEvt.setParams({
                    recordId: recid,
                    "slideDevName": "detail",
                    "isredirect": true
                });        
            navEvt.fire();}
        helper.hideSpinner(component, event, helper);
	}
});
$A.enqueueAction(action);
	},
    backtoOrder : function(component, event, helper) {
        var recid = component.get("v.recordId");
         var navEvt = $A.get("e.force:navigateToSObject");
        			navEvt.setParams({
                    recordId: recid,
                    "slideDevName": "detail",
                    "isredirect": true
                });        
                navEvt.fire();
    }
})