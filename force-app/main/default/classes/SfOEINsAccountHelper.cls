// ************************************************************************************************//
//
//  Developer By : Nilesh Bharti 'Salesforce Consultant' (nilesh.bharti@openexc.com)
//  Created on : 12/09/2024
//  JIRA:- OEP-11091
//  
//  Last Modified on : 12/09/2024
//  
//  Description :
//  This is helper class to check condition when to sync Account from Sf to NS.
//
// ************************************************************************************************ //


public class SfOEINsAccountHelper {
    
    String apiCalloutName = 'OECManualOrderCreation';
    static String apiEnvironment;
    static CalloutData__c cd;
    
    List<Account> accList;  
    public SfOEINsAccountHelper(List<Account> triggerNew, Map<Id,Account> triggerNewmap){
        loadCalloutParams();
        accList = triggerNew;
    }
    
    public void onAfterInsert(List<Account> triggerNew, Map<Id,Account> triggerNewmap){
        
        Set<Id> readyProcessCreate = new Set<Id>();
        
        for (Account acc : accList) {
            if(validAccountToProcess(acc) && !AccountTriggerHandler.setExecutedUpdateAccounts.contains(acc.id)){
                AccountTriggerHandler.setExecutedUpdateAccounts.add(acc.id);
                readyProcessCreate.add(acc.Id);
            }
        }
        System.debug('Ready to Create Account After -->>>>>>>> '+readyProcessCreate.size());
        if(readyProcessCreate.size() > 0){
            System.enqueueJob(new SalesforceOEINetsuiteAccountIntegration(readyProcessCreate));
        }
    }
    
    public void onAfterUpdate(List<Account> triggerNew, Map<Id, Account> triggerNewmap, Map<Id,Account> triggerOldmap){
        
        Set<Id> readyProcessUpdate = new Set<Id>();
        
        for (Account acc : accList) {
            if(acc.Account_Status__c == 'Active Customer'){
                if(validAccountToProcessUpdate(acc, triggerOldmap) && !AccountTriggerHandler.setExecutedUpdateAccounts.contains(acc.id)) {
                    AccountTriggerHandler.setExecutedUpdateAccounts.add(acc.id);
                    readyProcessUpdate.add(acc.Id);
                }
            }
        }
        System.debug('Ready to Update Account After -->>>>>>>> '+readyProcessUpdate.size());
        if (readyProcessUpdate.size() > 0) {
            System.enqueueJob(new SalesforceOEINetsuiteAccountIntegration2(readyProcessUpdate));
        }
    }
    
    public void onBeforeInsert(List<Account> triggerNew, Map<Id,Account> triggerNewmap){
        
        List<Account> listAccounts = new List<Account>();
        
        for(Account acc : triggerNew){
            if((String.isBlank(acc.Name)) || acc.isClone())
                acc.Name = acc.Name;
            
            listAccounts.add(acc);
        }
        System.debug('Before Insert -->>>>>>>> '+listAccounts.size());
        if(listAccounts.size() > 0){
            dupCheckonAccountName(listAccounts);
        }
    }
    
    public void onBeforeUpdate(List<Account> triggerNew, Map<Id,Account> triggerNewmap ,List<Account> triggerOld, Map<Id,Account> triggerOldmap){
        
        List<Account> listAccounts = new List<Account>();
        for(Account acc : triggerNew){
            
            if(dupCheckRequire(acc, triggerNewmap , triggerOldmap)){
                listAccounts.add(acc);
            }
        }
        System.debug('Before update -->>>>>>>> '+listAccounts.size());
        if(listAccounts.size() > 0 ){
            dupCheckonAccountNameForUpdate(listAccounts);
        }
    }
    
    public boolean dupCheckRequire(Account acc, Map<Id,Account> triggerNewmap, Map<Id,Account> triggerOldmap){
        
        if(triggerNewmap.get(acc.Id).Name != triggerOldmap.get(acc.Id).Name){
            return true;
        }
        else
            return false;
    }
    
    public void dupCheckonAccountName(List<Account> accountsList){
        if(accountsList.size() > 0) {
            for (Account acc : accountsList) {
                Integer count = [SELECT count() FROM Account WHERE Name = :acc.Name limit 1];
                if (count == 1) {
                    acc.addError('We cannot create a duplicate Account as we have already Account exist with this Name.');
                }
            }
        }
    }
    
    public void dupCheckonAccountNameForUpdate(List<Account> accountsList){
        if(accountsList.size() > 0) {
            for (Account acc : accountsList) {
                if(String.isNotBlank(acc.Name)){
                    Integer count = [SELECT count() FROM Account WHERE Name = :acc.Name AND Id != :acc.Id limit 1];
                    if (count == 1) {
                        acc.addError('We cannot update a duplicate Account as we have already Account exist with this Name.');
                    }
                }
            }
        }
    }
    
    public boolean validAccountToProcess(Account acc){
        
        if (acc.Name == null){
            return false;
        }
        else if(acc.Account_Status__c != 'Active Customer'){
            return false;
        }
        else{
            return true;
        }
    }
    
    public boolean validAccountToProcessUpdate(Account acc, Map<Id,Account> triggerOldmap){
        
        Account oldAccount = new Account();
        oldAccount = triggerOldmap.get(acc.Id);
        
        
        if(String.isBlank(acc.Name) && String.isBlank(acc.Account_Status__c)){
            System.debug('validForUpdate ----------->1');
            return false;
        }
        else if(acc.Name != triggerOldmap.get(acc.Id).Name){
            System.debug('validForUpdate ----------->2');
            return true;
        }
        else if(acc.Account_Status__c != triggerOldmap.get(acc.Id).Account_Status__c && acc.Account_Status__c == 'Active Customer'){
            System.debug('validForUpdate ----------->3');
            return true;
        }
        else if(acc.ParentId != triggerOldmap.get(acc.Id).ParentId){
            System.debug('validForUpdate ----------->4');
            return true;
        }
        else if(acc.BillingCountry != triggerOldmap.get(acc.Id).BillingCountry){
            System.debug('validForUpdate ----------->5');
            return true;
        }
        else if(acc.BillingStreet != triggerOldmap.get(acc.Id).BillingStreet){
            System.debug('validForUpdate ----------->6');
            return true;
        }
        else if(acc.BillingCity != triggerOldmap.get(acc.Id).BillingCity){
            System.debug('validForUpdate ----------->7');
            return true;
        }
        else if(acc.BillingState != triggerOldmap.get(acc.Id).BillingState){
            System.debug('validForUpdate ----------->8');
            return true;
        }
        else if(acc.BillingPostalCode != triggerOldmap.get(acc.Id).BillingPostalCode){
            System.debug('validForUpdate ----------->9');
            return true;
        }
        else if(acc.ShippingCountry != triggerOldmap.get(acc.Id).ShippingCountry){
            System.debug('validForUpdate ----------->10');
            return true;
        }
        else if(acc.ShippingStreet != triggerOldmap.get(acc.Id).ShippingStreet){
            System.debug('validForUpdate ----------->11');
            return true;
        }
        else if(acc.ShippingCity != triggerOldmap.get(acc.Id).ShippingCity){
            System.debug('validForUpdate ----------->12');
            return true;
        }
        else if(acc.ShippingState != triggerOldmap.get(acc.Id).ShippingState){
            System.debug('validForUpdate ----------->13');
            return true;
        }
        else if(acc.ShippingPostalCode != triggerOldmap.get(acc.Id).ShippingPostalCode){
            System.debug('validForUpdate ----------->14');
            return true;
        }
        else{
            System.debug('validForUpdate ----------->15');
            return false;
        }
    }
    
    public static void loadCalloutParams() {
        
        Integration_Configuration__mdt ic = [SELECT API_Environment__c from Integration_Configuration__mdt];
        apiEnvironment = ic.API_Environment__c;
        
        if (apiEnvironment == 'QA'){
            OECCallOuts__mdt callouts = [SELECT QAAccountId__c, QAAuthURL__c, QACreateAccountEndpointURL__c, QAPassword__c, QAUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            cd = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QACreateAccountEndpointURL__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);             
        }
        else if (apiEnvironment == 'Prod'){
            OECCallOuts__mdt callouts = [SELECT ProdAccountId__c, ProdAuthURL__c, ProductionCreateAccountEndpointURL__c, ProdPassword__c, ProdUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            cd = new CalloutData__c(AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProductionCreateAccountEndpointURL__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);              
        }
        else {
            OECCallOuts__mdt callouts = [SELECT DevAccountId__c, DevAuthURL__c, StageCreateAccountEndpointURL__c, DevPassword__c, DevUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            cd = new CalloutData__c(AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.StageCreateAccountEndpointURL__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
        }
    }
    
}