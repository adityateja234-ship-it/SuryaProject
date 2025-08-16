({
	showSpinner: function(component,event,helper) {

 var spinnerMain = component.find("Spinner");

 $A.util.removeClass(spinnerMain, "slds-hide");

 },

 hideSpinner : function(component,event,helper) {

 var spinnerMain = component.find("Spinner");

 $A.util.addClass(spinnerMain, "slds-hide");

 }
})