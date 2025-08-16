global class OECBatchOrderSync implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.stateful{
    
    global CalloutData__c cData = new CalloutData__c();
    //global OECBatchOrderSyncHelper helper = new OECBatchOrderSyncHelper();
    global OECBatchCombinedOrderSyncHelper helper = new OECBatchCombinedOrderSyncHelper();
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        cData = helper.getCalloutData(); 
        return Database.getQueryLocator([SELECT id,OrderNumber,Account_Legal_Entity__c, Account.Name, teams_created__c,RecordType.Name, Account.Primary_Account_Manager__c,Account.Legal_Entity__c, Description,AccountId, End_Date_Time__c, EventNotes__c,Order_TimeZone__c,Start_Date_Time__c, Event_Type_OE_Defined__c,OEC_Event_Name__c, Name,TimeZone__c,OE_Central_URL__c,SyncStatus__c,Sync_Error_Message__c,Sync_Retry_Count__c,recordtypeid,CreatedBy.Name,Business_Line__c,Status,Sync_to_OEC__c,Account.External_Sync__c, region__c, Project_Manager_2__c,Project_Manager__c,Requester_Contact__r.FirstName,Requester_Contact__r.LastName,Requester_Contact__r.Email from order where SyncStatus__c='Failed']);       
               
    }
    
    global void execute(Database.BatchableContext BC, List<Order> orders){

        helper.processOrders(orders);

    }    
    global void finish(Database.BatchableContext BC){
    
        for(CronTrigger delCron: [select id, CronJobDetail.Name,state from CronTrigger where CronJobDetail.Name like 'OEC Order Sync Batch%' LIMIT 100])  {
            System.abortJob(delCron.Id);
        }
        
        System.debug('Current Time :'+Datetime.now());
        System.debug('Current Time +15 :'+Datetime.now()+(15/1440));
        System.debug('Current Time +15 2 :'+Datetime.now().addMinutes(5));
        Datetime futureRunDate = Datetime.now().addMinutes(5);
        
        String hour = String.valueOf(futureRunDate.hour());
        //You can add any no of Minute you want to add to schedule it for next
        String min = String.valueOf(futureRunDate.minute());
        String ss = String.valueOf(futureRunDate.second());
        
        //parse to a cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        
        //Create an Instance of your Schedule Class
        //scheduleSuccessApi s = new scheduleSuccessApi(apiType,requestIdList,afterDate);
        
        
        OECSyncScheduleBatch s = new OECSyncScheduleBatch();
        //System.schedule(CONSTANT.JOB_NAME+'Started At '+objectName + String.valueOf(Datetime.now()), nextFireTime, s);
        System.schedule('OEC Order Sync Batch '+ + String.valueOf(Datetime.now()), nextFireTime, s);
        
    }
    
    
}