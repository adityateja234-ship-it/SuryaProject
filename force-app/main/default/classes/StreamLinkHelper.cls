public class StreamLinkHelper {


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
    list<Order> ords;  
    public StreamLinkHelper(list<Order> triggerNew,map<Id,Order> triggerNewmap){ 
        System.debug('------------->>>1');
        //loadCalloutParams();
        ords = triggerNew;
         
    } 
    public void onAfterUpdate(list<Order> triggerNew,map<Id,Order> triggerNewmap,map<Id,Order> triggerOldmap){
        System.debug('------------->>>2');
        Map<id,Order> IdOrderMap = new Map<Id,Order>();
        Map<id,Order> IdCanOrderMap = new Map<Id,Order>();
        Map<id,Order> IdTeamOrderMap = new Map<Id,Order>();
        Map<id,Order> IdTeamArchiveOrderMap = new Map<Id,Order>();
        Map<id,Order> IdLassoOrderMap = new Map<Id,Order>();
        Map<id,Order> IdOrderUpdateMap = new Map<Id,Order>();
        Map<id,Order> IdLassoOrderCancelMap = new Map<Id,Order>();
        Map<id,Order> CombinedIdOrderMap=new Map<Id,Order>();
        String createOEC='false';
        String createLasso ='false';
        
        List<Order> updatedStreamLinkOrders = new List<Order>();
        System.debug('------------->>>3'+updatedStreamLinkOrders.size());
        for(Order ord:ords){
            List<Order> oStreamLinkList = new List<Order>();
            oStreamLinkList = [select Id,Related_order_start_date_time__c from Order where Related_Order__c =:ord.Id];
            System.debug('------------->>>3.5'+oStreamLinkList.SIZE());
            for(Order so:oStreamLinkList){
                System.debug('------------->>>4');+
                so.Related_order_start_date_time__c = ord.Start_Date_Time__c;
                updatedStreamLinkOrders.add(so);
            }
        }
        update updatedStreamLinkOrders;
        System.debug('------------->>>5');
             
    }
    
}