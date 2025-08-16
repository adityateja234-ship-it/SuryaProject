global class FourPackBatch implements Database.Batchable<sObject>,Database.stateful{
    
    public OrderHelper helper = new OrderHelper();
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('---------- In FourPackBatch Batch start method '); 
        
        return Database.getQueryLocator([SELECT id,Description,AccountId, End_Date_Time__c, Pricebook2Id, Corporate_Related__c,OEC_Event_Name__c,
                                                Requester_Contact__c, Meeting_Complexity__c, EventNotes__c,Order_TimeZone__c,Start_Date_Time__c, 
                                                Event_Type_OE_Defined__c, Name,TimeZone__c,EffectiveDate,opportunityId,
                                                recordtypeid,Business_Line__c,Status,
                                                Account_Legal_Entity__c,BillingStreet, BillingCity, BillingState, BillingPostalCode,BillingCountry,
                                                Client_Cost_Code__c,Order_Confirmed_Date__c,Order_Source__c,OwnerId,Project_Manager__c,
                                                region__c, Dhruvsoft__convert_from_opportunity__c,Dhruvsoft__Opportunity__c,Four_Pack_Order_from_Opportunity__c,
                                                Dhruvsoft__OrderAmtFromOpportunityAmt__c,Billing_Method__c,Bill_To_Legal_Entity_Name__c,Billing_Notes__c,
                                                Additional_Recipient_1__c,Additional_Recipient_2__c,OE_Passport__c,
                                                (select UnitPrice, Quantity, PriceBookEntryId,Product2Id from OrderItems) 
                                                from order where Four_Pack_Status__c='Participate']);       
               
    }
    
    global void execute(Database.BatchableContext BC, List<Order> orders){
        System.debug('FourPackBatch---------- In Batch FourPackBatch Excecute method Starting 1'); 
        for(Order ord:orders){   
            
            System.debug('Name --------------->>'+ord.Name);
            System.debug('OEC EVENT Name --------------->>'+ord.OEC_Event_Name__c);      
            System.debug('Order ID ---------->'+ord.Id);  
        } 
         System.debug('FourPackBatch---------- In Batch FourPackBatch Excecute method Starting 2');   
        helper.processFourPack(orders);

    }    
    global void finish(Database.BatchableContext BC){
    
        for(CronTrigger delCron: [select id, CronJobDetail.Name,state from CronTrigger where CronJobDetail.Name like 'Four Pack Order Batch%' LIMIT 100])  {
            System.abortJob(delCron.Id);
        }
        /*
        String hour = String.valueOf(Datetime.now().hour());
        //You can add any no of Minute you want to add to schedule it for next
        String min = String.valueOf(Datetime.now().addMinutes(2).minute());
        String ss = String.valueOf(Datetime.now().second());
        
        //parse to a cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        
        //Create an Instance of your Schedule Class
        //scheduleSuccessApi s = new scheduleSuccessApi(apiType,requestIdList,afterDate);
        */
        
        System.debug('Current Time :'+Datetime.now());
        System.debug('Current Time +15 :'+Datetime.now()+(15/1440));
        System.debug('Current Time +15 2 :'+Datetime.now().addMinutes(5));
        Datetime futureRunDate = Datetime.now().addMinutes(15);
        
        String hour = String.valueOf(futureRunDate.hour());
        //You can add any no of Minute you want to add to schedule it for next
        String min = String.valueOf(futureRunDate.minute());
        String ss = String.valueOf(futureRunDate.second());
        
        //parse to a cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        
        //Create an Instance of your Schedule Class
        //scheduleSuccessApi s = new scheduleSuccessApi(apiType,requestIdList,afterDate);
        
        
        FourPackSyncBatch s = new FourPackSyncBatch();
        //System.schedule(CONSTANT.JOB_NAME+'Started At '+objectName + String.valueOf(Datetime.now()), nextFireTime, s);
        
         System.schedule('Four Pack Order Batch ' + + String.valueOf(Datetime.now()), nextFireTime, s);
        
    }
    
    
}