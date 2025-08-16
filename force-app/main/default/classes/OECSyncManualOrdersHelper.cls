public class OECSyncManualOrdersHelper {
    
    String apiCalloutName = 'OECManualOrderCreation';
    String apiEnvironment;
    CalloutData__c cd;
    CalloutData__c combinedCreateCD;
    CalloutData__c cancelledcd;
    CalloutData__c teamscd;
    CalloutData__c archiveTeamscd;
    CalloutData__c lassoCancelledcd;
    CalloutData__c combinedCancelledcd;
    
    private static Set<Id> alreadyProcessedForCombined = new Set<Id>();
    private static Set<Id> alreadyProcessed = new Set<Id>();
    private static Set<Id> alreadyProcessedForTeams = new Set<Id>();
    private static Set<Id> alreadyProcessedForCancelledOrds = new Set<Id>();
    private static Set<Id> alreadyProcessedForArchiveOrds = new Set<Id>();
    private static Set<Id> alreadyProcessedForLasso = new Set<Id>();
    private static Set<Id> alreadyProcessedForLassoUpdate = new Set<Id>();
    private static Set<Id> alreadyProcessedForOECUpdate = new Set<Id>();
    private static Set<Id> alreadyProcessedForLassoCancel = new Set<Id>();
    
    private Integer eventNameMaxSize = 80;
    List<Order> ords;
    
    public OECSyncManualOrdersHelper(List<Order> triggerNew, Map<Id,Order> triggerNewmap){
        loadCalloutParams();
        ords = triggerNew;
    }
    
    public void onAfterUpdate(List<Order> triggerNew, Map<Id,Order> triggerNewmap, Map<Id,Order> triggerOldmap){
        
        Map<id,Order> IdOrderMap = new Map<Id,Order>();
        Map<id,Order> IdCanOrderMap = new Map<Id,Order>();
        Map<id,Order> IdTeamOrderMap = new Map<Id,Order>();
        Map<id,Order> IdTeamArchiveOrderMap = new Map<Id,Order>();
        Map<id,Order> IdLassoOrderMap = new Map<Id,Order>();
        Map<id,Order> IdOrderUpdateMap = new Map<Id,Order>();
        Map<id,Order> IdLassoOrderCancelMap = new Map<Id,Order>();
        Map<id,Order> CombinedIdOrderMap = new Map<Id,Order>();
        String createOEC = 'false';
        String createLasso = 'false';
        String createTeam = 'false';
        
        // Added by Nilesh Bharti as Part of OEP-21744
        Set<Id> orderIds = new Set<Id>();
        for (Order ord : ords) {
            if(ord.Status == 'New')
                return;
            orderIds.add(ord.Id);
        }
        
        Map<Id, Order> orderWithAccountMap = new Map<Id, Order>(
            [SELECT Id, Account.External_Sync__c, CreatedBy.Name FROM Order WHERE Id IN :orderIds]
        );
        
        for(Order ord:ords){
            
            Order accDetails = orderWithAccountMap.get(ord.Id);
            
            if(validOrderToProcess(ord,accDetails))
                createOEC = 'true';
            
            if(!ord.No_Staff_Required__c)
                createLasso = 'true';
            
            // Added by Nilesh Bharti as Part of OEP-18254
            if(ord.Sync_to_Teams__c)
                createTeam = 'true';
            
            // Combined create
            if(ord.Status == 'In Progress' && (String.isBlank(ord.SyncStatus__c) && String.isBlank(ord.Lasso_Event_ID__c)  && String.isBlank(ord.Team_ID_Created__c))){
                if((validOrderToProcess(ord,accDetails) || validOrderToProcessForLasso(ord) || validOrderToProcessTeamsCreation(ord)) && !OrderTriggerHandler.setExecutedCombinedOrders.contains(ord.id)){
                    OrderTriggerHandler.setExecutedCombinedOrders.add(ord.id);
                    CombinedIdOrderMap.put(ord.id,ord);
                }
            }
            
            // COMBINED CANCEL
            if(
                ((ord.Status == 'Cancelled'|| ord.status == 'Paid' || ord.status == 'Delivered' || ord.status == 'Awaiting Confirmation' || ord.status == 'Ready to Bill' || ord.status == 'Invoice Sent') && String.isNotBlank(ord.OECEventID__c) && !ord.CancelledStatusProcessedForOEC__c  && !alreadyProcessedForCancelledOrds.contains(ord.id) && !ord.Processed_For_Archive__c)
                ||
                ((ord.Status == 'Cancelled'|| ord.status == 'Paid' || ord.status == 'Delivered' || ord.status == 'Awaiting Confirmation' || ord.status == 'Ready to Bill' || ord.status == 'Invoice Sent') && String.isNotBlank(ord.Lasso_Event_ID__c) && !ord.CancelledStatusProcessedForLasso__c && !alreadyProcessedForCancelledOrds.contains(ord.id) && !ord.Processed_For_Archive__c)
            ){   
                alreadyProcessedForCancelledOrds.add(ord.id);
                IdCanOrderMap.put(ord.id,ord);
            }
            
            // Combined Update
            if( ord.Status == 'In Progress' && !OrderTriggerHandler.setExecutedCombinedUpdateOrders.contains(ord.id) && validForUpdate(ord,triggerOldmap) ) {
                
                // Added by Nilesh Bharti as hot fix
                // Added by Nilesh Bharti as part of OEP-19830
                if(String.isBlank(ord.OECEventId__c) && accDetails.Account.External_Sync__c && ord.Sync_to_OEC__c)
                    createOEC = 'true';
                
                OrderTriggerHandler.setExecutedCombinedUpdateOrders.add(ord.id);
                IdOrderUpdateMap.put(ord.id,ord);
            }
        }
        if(CombinedIdOrderMap.size() > 0){
            System.debug('Calling combined create future method with '+CombinedIdOrderMap.size() + ' Orders');
            OECCombinedSyncManualOrdersFuture.callManualOrderSync(CombinedIdOrderMap.keySet(),createOEC,createLasso,createTeam);
        }
        if(IdCanOrderMap.size() > 0){
            System.debug('Calling combined cancel method with '+ IdCanOrderMap.size() + ' Orders');
            System.enqueueJob(new OECCombinedOrderStatusSyncQueueble (IdCanOrderMap.keySet(),combinedCancelledcd),1);
        }
        if(IdOrderUpdateMap.size() > 0){
            System.debug('Calling combined update method with '+ IdOrderUpdateMap.size() + ' Orders');
            System.enqueueJob(new OECCombinedSyncManualOrderUpdateQueueble(IdOrderUpdateMap.keySet(), triggerOldmap,createOEC,createLasso,createTeam));
        }
    }
    
    public void onBeforeInsert(List<Order> triggerNew, Map<Id,Order> triggerNewmap){
        
        List<Order> listOrders = new List<Order>();
        
        for(Order ord : triggerNew){
            if((String.isBlank(ord.OEC_Event_Name__c)) || ord.isClone())
                ord.OEC_Event_Name__c = ord.Name;
            listOrders.add(ord);
        }
        
        if(listOrders.size() > 0){
            dupCheckonOECEventName(triggerNew);
        }
    }
    
    public void onBeforeUpdate(List<Order> triggerNew, Map<Id,Order> triggerNewmap, List<Order> triggerOld, Map<Id,Order> triggerOldMap){
        
        
        List<Order> listOrders = new List<Order>();
        
        for(Order ord : triggerNew){
            
            // Added by Nilesh Bharti as Part of OEP-19232
            Order oldOrd = triggerOldMap.get(ord.Id);
            if (ord.Name != oldOrd.Name) {
                ord.OEC_Event_Name__c = ord.Name;
            }
            
            if (dupCheckRequire(ord, triggerNewmap , triggerOldmap)){
                listOrders.add(ord);
            }
        }
        
        if(listOrders.size() > 0 ){
            dupCheckonOECEventNameForUpdate(triggerNew);
        }
    }
    
    public boolean dupCheckRequire(Order ord, Map<Id,Order> triggerNewmap, Map<Id,Order> triggerOldmap){
        
        if ( triggerNewmap.get(ord.Id).name != triggerOldmap.get(ord.Id).name){
            return true;
        }
        else
            return false;
    }
    
    // Finds the right Order needs to be synced back to OEC
    private boolean validOrderToProcess(Order ord, Order accOrd){
        
        /*if (ord.SyncStatus__c == 'Synced'){
			return false;
        }
        else */if (accOrd.CreatedBy.Name == 'API Integration User'){
            return false;// We will not process Order created by API Integration User
        }
        else if (ord.Status != 'In Progress'){
            return false;
        }
        else if (ord.Sync_to_OEC__c == False){
            return false;
        }
        else if(accOrd.Account.External_Sync__c != true){
            return false;
        }
        return true;
    }
    
    // Finds the right Order needs to be synced to LASSO
    private boolean validOrderToProcessForLasso(Order ord){
        
        if(Schema.SObjectType.Order.getRecordTypeInfosById().get(ord.recordtypeid).getname() != 'Standard Order' && 
           Schema.SObjectType.Order.getRecordTypeInfosById().get(ord.recordtypeid).getname() != 'No Contract Required Order'){        
               return false;// We will not process Corporate_StreamLinks_Order orders
           }
        else if (ord.Status != 'In Progress'){
            return false;
        }
        else if (String.isNotBlank(ord.Lasso_Event_ID__c)){
            return false;
        }
        else if (ord.No_Staff_Required__c){
            return false;
        }
        return true;
    }
    
    // Finds the right Order needs to be used to create Teams Group
    private boolean validOrderToProcessTeamsCreation(Order ord){
        
        if (ord.teams_created__c != 'Pending'){
            return false;
        }
        if (String.isBlank(ord.Project_Manager__c) && String.isBlank(ord.Project_Manager__c)){
            return false;
        }
        return true;
    }
    
    private void loadCalloutParams() {
        
        Integration_Configuration__mdt ic = [SELECT API_Environment__c from Integration_Configuration__mdt];
        apiEnvironment = ic.API_Environment__c;
        
        if (apiEnvironment == 'QA'){
            OECCallOuts__mdt callouts = [SELECT QACombinedCancel__c, QALassoOrderCancelEndpoint__c, QAMSTeamsArchiveEndpointURL__c,QATeamsCreationEndpointURL__c, QACancelEndpointURL__c, QAAccountId__c,QAAuthURL__c,QAEndpointURL__c,QAPassword__c,QAUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            cd = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QAEndpointURL__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);
            teamscd = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QATeamsCreationEndpointURL__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);
            cancelledcd = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QACancelEndpointURL__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);
            archiveTeamscd = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QAMSTeamsArchiveEndpointURL__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);
            lassoCancelledcd = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QALassoOrderCancelEndpoint__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);
            combinedCancelledcd = new CalloutData__c (AccountId__c=callouts.QAAccountId__c,AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QACombinedCancel__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);
        }
        else if (apiEnvironment == 'Prod'){
            OECCallOuts__mdt callouts = [SELECT ProdCombinedCancelEvent__c,ProductionLassoOrderCancelEndpoint__c,ProdMSTeamsArchiveEndpointURL__c,ProdTeamsCreationEndpointURL__c,ProdCancelEndpointURL__c, ProdAccountId__c,ProdAuthURL__c,ProdEndpointURL__c,ProdPassword__c,ProdUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            cd = new CalloutData__c(AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProdEndpointURL__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);
            teamscd = new CalloutData__c (AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProdTeamsCreationEndpointURL__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);
            cancelledcd = new CalloutData__c (AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProdCancelEndpointURL__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);
            archiveTeamscd = new CalloutData__c (AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProdMSTeamsArchiveEndpointURL__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);
            lassoCancelledcd = new CalloutData__c (AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProductionLassoOrderCancelEndpoint__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);
            combinedCancelledcd = new CalloutData__c (AccountId__c=callouts.ProdAccountId__c,AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProdCombinedCancelEvent__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);
        }
        else {
            OECCallOuts__mdt callouts = [SELECT StageCombinedCancelEvent__c,StageLassoOrderCancelEndpoint__c,StageMSTeamsArchiveEndpointURL__c, StageTeamsCreationEndpointURL__c,StageCancelEndpointURL__c, DevAccountId__c,DevAuthURL__c,DevEndpointURL__c,DevPassword__c,DevUserName__c FROM OECCallOuts__mdt where Label ='OECManualOrderCreation'];
            cd = new CalloutData__c(AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.DevEndpointURL__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
            teamscd = new CalloutData__c (AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.StageTeamsCreationEndpointURL__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
            cancelledcd = new CalloutData__c (AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.StageCancelEndpointURL__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
            archiveTeamscd = new CalloutData__c (AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.StageMSTeamsArchiveEndpointURL__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
            lassoCancelledcd = new CalloutData__c (AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.StageLassoOrderCancelEndpoint__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
            combinedCancelledcd = new CalloutData__c (AccountId__c=callouts.DevAccountId__c,AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.StageCombinedCancelEvent__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
        }
    }
    
    
    private void dupCheckonOECEventName(List<Order> ordersList) {
        if(ordersList.size() > 0) {
            for (Order ord : ordersList) {
                Integer count = [select count() from Order where OEC_Event_Name__c = :ord.OEC_Event_Name__c and Start_Date__c = :ord.Start_Date__c limit 1];
                if (count == 1) {
                    ord.addError('We cant create a duplicate Order as we have already Order exist with this OEC Event Name/ Event Name and Order Start Date.');
                }
            }
        }
    }
    
    private void dupCheckonOECEventNameForUpdate(List<Order> ordersList){
        if(ordersList.size() > 0) {
            for (Order ord : ordersList) {
                if(String.isNotBlank(ord.Name)){
                    Integer count = [select count() from Order where OEC_Event_Name__c = :ord.OEC_Event_Name__c and Start_Date__c = :ord.Start_Date__c and id != :ord.Id limit 1];
                    if (count == 1) {
                        ord.addError('We cant create a duplicate Order as we have already Order exist with this OEC Event Name/ Event Name and Order Start Date.');
                    }
                }
            }
        }
    }
    
    
    private boolean validForUpdate(Order ord, Map<Id,Order> triggerOldmap) {
        
        Order oldOrder = new Order();
        oldOrder = triggerOldmap.get(ord.Id);
        
        // Combined create
        if(String.isBlank(ord.SyncStatus__c) && String.isBlank(ord.Lasso_Event_ID__c)  && String.isBlank(ord.Team_ID_Created__c) ){
            System.debug('validForUpdate ----------->1');
            return false;
        }
        else if (ord.Name != triggerOldmap.get(ord.ID).Name){
            System.debug('validForUpdate ----------->2');
            return true;
        }
        else if(ord.Start_Date_Time__c != triggerOldmap.get(ord.ID).Start_Date_Time__c){
            System.debug('validForUpdate ----------->3');
            return true;
        }
        else if(ord.End_Date_Time__c != triggerOldmap.get(ord.ID).End_Date_Time__c){
            System.debug('validForUpdate ----------->4');
            return true;
        }
        else if(ord.region__c != triggerOldmap.get(ord.ID).region__c){
            System.debug('validForUpdate ----------->5');
            return true;
        }
        else if (ord.Business_Line__c != triggerOldmap.get(ord.ID).Business_Line__c){
            System.debug('validForUpdate ----------->6');
            return true;
        }
        else if(ord.Order_TimeZone__c != triggerOldmap.get(ord.ID).Order_TimeZone__c){
            System.debug('validForUpdate ----------->7');
            return true;
        }
        else if(ord.Event_Type_OE_Defined__c != triggerOldmap.get(ord.ID).Event_Type_OE_Defined__c){
            System.debug('validForUpdate ----------->8');
            return true;
        }
        else if(ord.Project_Manager__c != triggerOldmap.get(ord.ID).Project_Manager__c){
            System.debug('validForUpdate ----------->9');
            return true;
        }
        else if(ord.Project_Manager_2__c != triggerOldmap.get(ord.ID).Project_Manager_2__c){
            System.debug('validForUpdate ----------->10');
            return true;
        }
        else if(ord.Requester_Contact__c != triggerOldmap.get(ord.ID).Requester_Contact__c){
            System.debug('validForUpdate ----------->11');
            return true;
        }
        else if(ord.Account.Primary_Account_Manager__c != triggerOldmap.get(ord.ID).Account.Primary_Account_Manager__c){
            System.debug('validForUpdate ----------->12');
            return true;
        }
        else if(ord.Status != triggerOldmap.get(ord.ID).Status && ord.Status == 'In Progress' && triggerOldmap.get(ord.ID).Status == 'New' &&  (String.isNotBlank(ord.OECEventId__c) || String.isNotBlank(ord.Lasso_Event_ID__c) || String.isNotBlank(ord.Team_ID_Created__c) ) ){
            System.debug('validForUpdate ----------->13');
            return true;
        }
        else if(ord.No_Staff_Required__c != triggerOldmap.get(ord.ID).No_Staff_Required__c && ord.No_Staff_Required__c == false && triggerOldmap.get(ord.ID).No_Staff_Required__c == true ) {
            System.debug('validForUpdate ----------->14');
            return true;
        }
        else if(ord.Sync_to_OEC__c != triggerOldmap.get(ord.ID).Sync_to_OEC__c && ord.Sync_to_OEC__c == true && triggerOldmap.get(ord.ID).Sync_to_OEC__c == false ) {
            System.debug('validForUpdate ----------->15');
            return true;
        }
        else if(ord.Channel_Agency_Referral__c != triggerOldmap.get(ord.ID).Channel_Agency_Referral__c ) {
            System.debug('validForUpdate ----------->16');
            return true;
        }
        else if(ord.Department__c != triggerOldmap.get(ord.ID).Department__c ) {
            System.debug('validForUpdate ----------->17');
            return true;
        }
        else if(ord.Sync_to_Teams__c != triggerOldmap.get(ord.ID).Sync_to_Teams__c ) {
            System.debug('validForUpdate ----------->18');
            return true;
        }
        else{
            System.debug('validForUpdate ----------->19');
            return false;
        }
    }
}