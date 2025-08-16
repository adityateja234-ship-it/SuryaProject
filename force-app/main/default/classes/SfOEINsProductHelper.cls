// ************************************************************************************************//
//
//  Developer By : Nilesh Bharti 'Salesforce Consultant' (nilesh.bharti@openexc.com)
//  Created on : 08/10/2024
//  JIRA:- OEP-11872
//  
//  Last Modified on : 08/10/2024
//  
//  Description :
//  This is helper class to check condition when to sync Product from Sf to NS.
//
// ************************************************************************************************//

public class SfOEINsProductHelper {
    
    String apiCalloutName = 'OECManualOrderCreation';
    static String apiEnvironment;
    static CalloutData__c cd;
    
    List<Product2> productList;  
    public SfOEINsProductHelper(List<Product2> triggerNew, Map<Id,Product2> triggerNewmap){
        loadCalloutParams();
        productList = triggerNew;
    }
    
    public void onAfterInsert(List<Product2> triggerNew, Map<Id,Product2> triggerNewmap){
        
        Set<Id> prdIds = new Set<Id>();
        
        for (Product2 prd : productList) {
            if(validProductToProcess(prd) && !ProductTriggerHandler.setExecutedUpdateProducts.contains(prd.id)){
                ProductTriggerHandler.setExecutedUpdateProducts.add(prd.id);
                prdIds.add(prd.Id);
            }
        }
        System.debug('Ready to Create Product After -->>>>>>>>'+prdIds.size());
        if(prdIds.size() > 0){
            System.enqueueJob(new SalesforceOEINetsuiteProductIntegration(prdIds));
        }
    }
    
    public void onAfterUpdate(List<Product2> triggerNew, Map<Id, Product2> triggerNewmap, Map<Id,Product2> triggerOldmap){
        
        Set<Id> prdIds = new Set<Id>();
        
        for (Product2 prd : productList) {
            if(validProductToProcess(prd)){
                if(validProductToProcessUpdate(prd, triggerOldmap) && !ProductTriggerHandler.setExecutedUpdateProducts.contains(prd.id)) {
                    ProductTriggerHandler.setExecutedUpdateProducts.add(prd.id);
                    prdIds.add(prd.Id);
                }
            }
        }
        System.debug('Ready to Update Product After -->>>>>>>>'+prdIds.size());
        if (prdIds.size() > 0) {
            System.enqueueJob(new SalesforceOEINetsuiteProductIntegration2(prdIds));
        }
    }
    
    public void onBeforeInsert(List<Product2> triggerNew, Map<Id,Product2> triggerNewmap){
        
        List<Product2> listProduct = new List<Product2>();
        
        for(Product2 prd : triggerNew){
            if((String.isBlank(prd.Name)) || prd.isClone()) 
                prd.OE_Product_Name__c = prd.Name;
            
            listProduct.add(prd);
        }
        System.debug('Ready to Create Product Before -->>>>>>>>'+listProduct.size());
        if(listProduct.size() > 0){
            dupCheckonOEProductName(listProduct);
        }
    }
    
    public void onBeforeUpdate(List<Product2> triggerNew, Map<Id,Product2> triggerNewmap ,List<Product2> triggerOld, Map<Id,Product2> triggerOldmap){
        
        List<Product2> listProduct = new List<Product2>();
        for(Product2 prd : triggerNew){
            
            if(dupCheckRequire(prd, triggerNewmap , triggerOldmap)){
                listProduct.add(prd);
            }
        }
        System.debug('Ready to Update Product Before -->>>>>>>>'+listProduct.size());
        if(listProduct.size() > 0 ){
            dupCheckonOEProductNameForUpdate(listProduct);
        }
    }
    
    public boolean dupCheckRequire(Product2 prd, Map<Id,Product2> triggerNewmap, Map<Id,Product2> triggerOldmap){
        
        if(triggerNewmap.get(prd.Id).Name != triggerOldmap.get(prd.Id).Name){
            return true;
        }
        /*else if(triggerNewmap.get(prd.Id).OE_Product_Name__c != triggerOldmap.get(prd.Id).OE_Product_Name__c){
return true;
}*/
        else
            return false;
    }
    
    public void dupCheckonOEProductName(List<Product2> listProduct){
        if(listProduct.size() > 0) {
            for (Product2 prd : listProduct) {
                Integer count = [SELECT count() FROM Product2 WHERE OE_Product_Name__c = :prd.OE_Product_Name__c limit 1];
                if (count == 1) {
                    prd.addError('We cannot create a duplicate Product as we have already OE Product exist with this Name.');
                }
            }
        }
    }
    
    public void dupCheckonOEProductNameForUpdate(List<Product2> listProduct){
        if(listProduct.size() > 0) {
            for (Product2 prd : listProduct) {
                if(String.isNotBlank(prd.OE_Product_Name__c)){
                    Integer count = [SELECT count() FROM Product2 WHERE OE_Product_Name__c = :prd.OE_Product_Name__c AND Id != :prd.Id limit 1];
                    if (count == 1) {
                        prd.addError('We cannot update a duplicate Product as we have already OE Product exist with this Name.');
                    }
                }
            }
        }
    }
    
    public boolean validProductToProcess(Product2 prd){
        
        if(prd.Name == null){
            return false;
        }
        else if(prd.OE_Product_Name__c == null){
            return false;
        }
        else if(prd.Revenue_Recognition_Rule__c == null){
            return false;
        }
        else if(prd.Rev_Rec_Forecast_Rule__c == null){
            return false;
        }
        return true;
    }
    
    public boolean validProductToProcessUpdate(Product2 prd, Map<Id,Product2> triggerOldmap){
        
        Product2 oldProduct = new Product2();
        oldProduct = triggerOldmap.get(prd.Id);
        
        if(String.isBlank(prd.Name) && String.isBlank(prd.Revenue_Recognition_Rule__c)  && String.isBlank(prd.Rev_Rec_Forecast_Rule__c) && String.isBlank(prd.OE_Product_Name__c)){
            System.debug('validForUpdate ----------->1');
            return false;
        }
        else if(prd.Name != triggerOldmap.get(prd.Id).Name){
            System.debug('validForUpdate ----------->2');
            return true;
        }
        else if(prd.OE_Product_Name__c != triggerOldmap.get(prd.Id).OE_Product_Name__c){
            System.debug('validForUpdate ----------->3');
            return true;
        }
        else if(prd.Revenue_Recognition_Rule__c != triggerOldmap.get(prd.Id).Revenue_Recognition_Rule__c){
            System.debug('validForUpdate ----------->4');
            return true;
        }
        else if(prd.Rev_Rec_Forecast_Rule__c != triggerOldmap.get(prd.Id).Rev_Rec_Forecast_Rule__c){
            System.debug('validForUpdate ----------->5');
            return true;
        }
        else if(prd.Family != triggerOldmap.get(prd.Id).Family){
            System.debug('validForUpdate ----------->6');
            return true;
        }
        else if(prd.IsActive != triggerOldmap.get(prd.Id).IsActive){
            System.debug('validForUpdate ----------->7');
            return true;
        }
        else if(prd.Description != triggerOldmap.get(prd.Id).Description){
            System.debug('validForUpdate ----------->8');
            return true;
        }
        else{
            System.debug('validForUpdate ----------->9');
            return false;
        }
    }
    
    public static void loadCalloutParams() {
        
        Integration_Configuration__mdt ic = [SELECT API_Environment__c from Integration_Configuration__mdt];
        apiEnvironment = ic.API_Environment__c;
        
        if (apiEnvironment == 'QA'){
            OECCallOuts__mdt callouts = [SELECT QAAccountId__c, QAAuthURL__c, QACreateProductEndpointURL__c, QAPassword__c, QAUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            cd = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QACreateProductEndpointURL__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);             
        }
        else if (apiEnvironment == 'Prod'){
            OECCallOuts__mdt callouts = [SELECT ProdAccountId__c, ProdAuthURL__c, ProductionCreateProductEndpointURL__c, ProdPassword__c, ProdUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            cd = new CalloutData__c(AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProductionCreateProductEndpointURL__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);              
        }
        else {
            OECCallOuts__mdt callouts = [SELECT DevAccountId__c, DevAuthURL__c, StageCreateProductEndpointURL__c, DevPassword__c, DevUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            cd = new CalloutData__c(AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.StageCreateProductEndpointURL__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
        }
    }
}