// ************************************************************************************************//
//
//  Developer By : Nilesh Bharti 'Salesforce Consultant' (nilesh.bharti@openexc.com)
//  Created on : 05/11/2024
//  JIRA:- OEP-12783
//  
//  Last Modified on : 05/11/2024
//  
//  Description :
//  This is helper class to check condition when to sync Order from Sf to NS.
//
// ************************************************************************************************ //

public class SfOEINsOrderHelper {
    
    String apiCalloutName = 'OECManualOrderCreation';
    String apiEnvironment;
    CalloutData__c cd;
    
    List<Order> orderList;
    public SfOEINsOrderHelper(List<Order> triggerNew, Map<Id,Order> triggerNewmap){
        loadCalloutParams();
        orderList = triggerNew;
    }
    
    public void onAfterUpdate(List<Order> triggerNew, Map<Id, Order> triggerNewmap, Map<Id,Order> triggerOldmap){
        
        String syncOrder = 'false';
        List<Order> readyProcessOrder = new List<Order>();
        List<Order> readyProcessUpdate = new List<Order>();
        
        DateTime targetDate = DateTime.newInstance(2025, 1, 25, 0, 0, 0);
        
        for (Order ord : orderList) {
            if (ord.CreatedDate >= targetDate) {
                if(ord.Status == 'Ready to Bill' && ord.region__c != 'TBD' && ord.Billing_Method__c == 'Bill Per Event'){
                    if(validOrderToProcess(ord, triggerOldmap) && !OrderTriggerHandler.setExecutedNetsuiteOrders.contains(ord.id)) {
                        syncOrder = 'true';
                        OrderTriggerHandler.setExecutedNetsuiteOrders.add(ord.id);
                        readyProcessOrder.add(ord);
                    }
                    
                    if(validOrderToProcessUpdate(ord, triggerOldmap) && !OrderTriggerHandler.setExecutedNetsuiteOrders.contains(ord.id)) {
                        if(String.isBlank(ord.Netsuite_Id__c))
                            syncOrder = 'true';
                        OrderTriggerHandler.setExecutedNetsuiteOrders.add(ord.id);
                        readyProcessUpdate.add(ord);
                    }
                }
            }
        }
        System.debug('Ready to Sync Order After -->>>>>>>> '+readyProcessOrder.size());
        if (readyProcessOrder.size() > 0) {
            System.enqueueJob(new SalesforceOEINetsuiteOrderIntegration(readyProcessOrder, syncOrder));
        }
        System.debug('Ready to Update Order After -->>>>>>>> '+readyProcessUpdate.size());
        if (readyProcessUpdate.size() > 0) {
            System.enqueueJob(new SalesforceOEINSOrderIntegrationUpdate(readyProcessUpdate, syncOrder));
        }
    }
    
    public boolean validOrderToProcess(Order ord, Map<Id,Order> triggerOldmap){
        
        if(ord.Status != triggerOldmap.get(ord.Id).Status && ord.Status == 'Ready to Bill'){
            System.debug('validForProcess ----------->1');
            return true;
        }
        else{
            System.debug('validForProcess ----------->3');
            return false;
        }
    }
    
    public boolean validOrderToProcessUpdate(Order ord, Map<Id,Order> triggerOldmap){
        
        Order oldOrder = new Order();
        oldOrder = triggerOldmap.get(ord.Id);
        
        System.debug('ord.Bill_To_Legal_Entity_Name__c ----------->1'+ord.Bill_To_Legal_Entity_Name__c);
        System.debug('triggerOldmap.get(ord.Id).Bill_To_Legal_Entity_Name__c ----------->1'+triggerOldmap.get(ord.Id).Bill_To_Legal_Entity_Name__c);
        
        if(String.isBlank(ord.Name)){
            System.debug('validForUpdate ----------->1');
            return false;
        }
        else if(ord.Bill_To_Legal_Entity_Name__c != triggerOldmap.get(ord.Id).Bill_To_Legal_Entity_Name__c){
            System.debug('validForUpdate ----------->2');
            return true;
        }
        else if(ord.Description != triggerOldmap.get(ord.Id).Description){
            System.debug('validForUpdate ----------->3');
            return true;
        }
        else if(ord.Owner.Name != triggerOldmap.get(ord.Id).Owner.Name){
            System.debug('validForUpdate ----------->4');
            return true;
        }
        else if(ord.region__c != triggerOldmap.get(ord.Id).region__c){
            System.debug('validForUpdate ----------->5');
            return true;
        }
        else if(ord.EffectiveDate != triggerOldmap.get(ord.Id).EffectiveDate){
            System.debug('validForUpdate ----------->6');
            return true;
        }
        else if(ord.Requester_Contact__c != triggerOldmap.get(ord.Id).Requester_Contact__c){
            System.debug('validForUpdate ----------->7');
            return true;
        }
        else if(ord.Event_Type_OE_Defined__c != triggerOldmap.get(ord.Id).Event_Type_OE_Defined__c){
            System.debug('validForUpdate ----------->8');
            return true;
        }
        else if(ord.BillingCountry != triggerOldmap.get(ord.Id).BillingCountry){
            System.debug('validForUpdate ----------->9');
            return true;
        }
        else if(ord.BillingState != triggerOldmap.get(ord.Id).BillingState){
            System.debug('validForUpdate ----------->10');
            return true;
        }
        else if(ord.BillingStreet != triggerOldmap.get(ord.Id).BillingStreet){
            System.debug('validForUpdate ----------->11');
            return true;
        }
        else if(ord.BillingCity != triggerOldmap.get(ord.Id).BillingCity){
            System.debug('validForUpdate ----------->12');
            return true;
        }
        else if(ord.BillingPostalCode != triggerOldmap.get(ord.Id).BillingPostalCode){
            System.debug('validForUpdate ----------->13');
            return true;
        }
        else if(ord.Billing_Contact__c != triggerOldmap.get(ord.Id).Billing_Contact__c){
            System.debug('validForUpdate ----------->14');
            return true;
        }
        else if(ord.Client_Cost_Code__c != triggerOldmap.get(ord.Id).Client_Cost_Code__c){
            System.debug('validForUpdate ----------->15');
            return true;
        }
        else if(ord.Billing_Method__c != triggerOldmap.get(ord.Id).Billing_Method__c && ord.Billing_Method__c == 'Bill Per Event'){
            System.debug('validForUpdate ----------->16');
            return true;
        }
        else if (ord.Business_Line__c != triggerOldmap.get(ord.Id).Business_Line__c){
            System.debug('validForUpdate ----------->19');
            return true;
        }
        else if (ord.Name != triggerOldmap.get(ord.Id).Name){
            System.debug('validForUpdate ----------->20');
            return true;
        }
        else if (ord.Additional_Recipient_1__c != triggerOldmap.get(ord.Id).Additional_Recipient_1__c){
            System.debug('validForUpdate ----------->21');
            return true;
        }
        else if (ord.Additional_Recipient_2__c != triggerOldmap.get(ord.Id).Additional_Recipient_2__c){
            System.debug('validForUpdate ----------->22');
            return true;
        }
        else if (ord.Billing_Notes__c != triggerOldmap.get(ord.Id).Billing_Notes__c){
            System.debug('validForUpdate ----------->23');
            return true;
        }
        else if(ord.Start_Date_Time__c != triggerOldmap.get(ord.Id).Start_Date_Time__c){
            System.debug('validForUpdate ----------->17');
            return true;
        }
        else if(ord.End_Date_Time__c != triggerOldmap.get(ord.Id).End_Date_Time__c){
            System.debug('validForUpdate ----------->18');
            return true;
        }
        else{
            System.debug('validForUpdate ----------->24');
            return false;
        }
    }
    
    private void loadCalloutParams(){
        
        Integration_Configuration__mdt ic = [SELECT API_Environment__c from Integration_Configuration__mdt];
        apiEnvironment = ic.API_Environment__c;
        
        if (apiEnvironment == 'QA'){
            OECCallOuts__mdt callouts = [SELECT QAAccountId__c, QAAuthURL__c, QACreateOrderEndpointURL__c, QAPassword__c, QAUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            cd = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QACreateOrderEndpointURL__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);             
        }
        else if (apiEnvironment == 'Prod'){
            OECCallOuts__mdt callouts = [SELECT ProdAccountId__c, ProdAuthURL__c, ProductionCreateOrderEndpointURL__c, ProdPassword__c, ProdUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            cd = new CalloutData__c(AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProductionCreateOrderEndpointURL__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);              
        }
        else {
            OECCallOuts__mdt callouts = [SELECT DevAccountId__c, DevAuthURL__c, StageCreateOrderEndpointURL__c, DevPassword__c, DevUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            cd = new CalloutData__c(AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.StageCreateOrderEndpointURL__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
        }
    }
}