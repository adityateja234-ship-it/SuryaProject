public class OECOpportunityMSTeamsHelper {


    String apiEnvironment;
    CalloutData__c cd;

    private static Set<Id> alreadyProcessed = new Set<Id>();

    Opportunity[] opps;  
    public OECOpportunityMSTeamsHelper(list<Opportunity> triggerNew,map<Id,Opportunity> triggerNewmap){ 
    
           
        //Load custom settings for the current environment for the API.
        loadCalloutParams();
        opps = [SELECT id,StageName, Processed_For_MSTeams_ClosedWon__c FROM Opportunity where id in :triggerNew  ];
        
        System.debug('CalloutData__c---------------->>'+cd);
         
    } 

    public void onAfterUpdate(list<Opportunity> triggerNew,map<Id,Opportunity> triggerNewmap){
        
        Map<id,Opportunity> IdOppMap = new Map<Id,Opportunity>();

        //updateOECEventName();
        for(opportunity opp:opps){
            
            System.debug('In For loop---------------->>1');
            System.debug('Id---------------->>'+opp.id+':Processed_For_MSTeams_ClosedWon__c'+opp.Processed_For_MSTeams_ClosedWon__c+': StageName'+opp.StageName );
            if( opp.StageName == 'Closed Won' && opp.Processed_For_MSTeams_ClosedWon__c == false){
                System.debug('In In Progress---------------->>2');
                if(!alreadyProcessed.contains(opp.id)){
                    System.debug('In In Progress---------------->>1.2');
                    alreadyProcessed.add(opp.id);
                    IdOppMap.put(opp.id,opp);
                }

            } 
         } 
         System.debug('---------------->>2000:'+'System.isFuture() -'+System.isFuture()+'-System.isBatch():'+System.isBatch());
         //if(!System.isFuture() && !System.isBatch()){
             if(IdOppMap.size() > 0){
             
                 System.debug('In IdOppMap.size---------------->>4:'+IdOppMap.size());
                 //System.enqueueJob(new OECOpportunityMSTeamsServiceQueueble(IdOppMap.keySet(),cd),1);
                 database.executeBatch(new OECOpportunityMSTeamsService(IdOppMap, cd),1);
                        
             }    
     }    
    

    /**
    Finds the right Order needs to be synced back to OEC
    */
    /*
    private boolean validOrderToProcess(Order ord){
    
  
        System.debug(
            'ord.RecordType.Name:'+ Schema.SObjectType.Order.getRecordTypeInfosById().get(ord.recordtypeid).getname()+
            '- ord.CreatedBy.Name:'+ord.CreatedBy.Name+
            '- ord.Business_Line__c:'+ord.Business_Line__c+
            '- ord.Status:'+ord.Status+
            '- ord.Sync_to_OEC__c:'+ord.Sync_to_OEC__c+
            '- ord.Account.External_Sync__c'+ord.Account.External_Sync__c
        );
        
        if (String.isNotBlank(ord.SyncStatus__c)){
            System.debug('Returning due to ------------>>  ord.SyncStatus__c');
            return false; 
            
        }    
        //else if(ord.RecordType.Name == 'Corporate_StreamLinks_Order' || ord.RecordType.Name == 'Corporate_Knovio_Order')
        else if(String.isBlank(ord.RecordType.Name )){
            System.debug('Returning due to ------------>>  ord.RecordType.Name ');
            return false;
        }
        else if(Schema.SObjectType.Order.getRecordTypeInfosById().get(ord.recordtypeid).getname() != 'Standard Order' && 
                Schema.SObjectType.Order.getRecordTypeInfosById().get(ord.recordtypeid).getname() != 'No Contract Required Order')
        {        
            System.debug('Returning due to ------------>>  ord.RecordType.ID ');
            return false;// We will not process Corporate_StreamLinks_Order orders
        }
        else if (ord.CreatedBy.Name == 'API Integration User') 
        {
            System.debug('Returning due to ------------>>  ord.CreatedBy.Name ');
            return false;// We will not process Order created by API Integration User
        }
        else if (ord.Status != 'In Progress')
        {
            System.debug('Returning due to Sync------------>>  ord.Status');
            return false;
        }
        else if (ord.Sync_to_OEC__c == False)
        {
            System.debug('Returning due to ------------>>  Sync_to_OEC__c');
            return false;
        }
        else if(ord.Account.External_Sync__c != true)
        {
            System.debug('Returning due to ------------>>  External_Sync__c ');
            return false;     
        }                
        return true;        
                    
    }
    */
    private void loadCalloutParams(){
    
        Integration_Configuration__mdt ic = [SELECT API_Environment__c from Integration_Configuration__mdt];
        apiEnvironment = ic.API_Environment__c;
        
        System.debug('API Environment getting connected is -----> :'+apiEnvironment); 
        //CalloutData__c cd;

        if (apiEnvironment == 'QA'){
            OECCallOuts__mdt callouts = [SELECT QAClientID__c, QAClientSecret__c, QAAuthURL__c,QAEndpointURL__c,QAPassword__c,QAUserName__c FROM OECCallOuts__mdt where Label ='OECMSTeamsOppo'];
            cd = new CalloutData__c (clientId__c=callouts.QAClientID__c ,clientSecret__c=callouts.QAClientSecret__c, AuthenticationURL__c=callouts.QAAuthURL__c,EndPointURL__c=callouts.QAEndpointURL__c,UserPassword__c=callouts.QAPassword__c,UserName__c=callouts.QAUserName__c);
            
        }
        else if (apiEnvironment == 'Prod'){
            OECCallOuts__mdt callouts = [SELECT ProdClientID__c, ProdClientSecret__c, ProdAuthURL__c,ProdEndpointURL__c,ProdPassword__c,ProdUserName__c FROM OECCallOuts__mdt where Label ='OECMSTeamsOppo'];
            cd = new CalloutData__c(clientId__c=callouts.ProdClientID__c ,clientSecret__c= callouts.ProdClientSecret__c, AuthenticationURL__c=callouts.ProdAuthURL__c,EndPointURL__c=callouts.ProdEndpointURL__c,UserPassword__c=callouts.ProdPassword__c,UserName__c=callouts.ProdUserName__c);
        }
        else {
            
            OECCallOuts__mdt callouts = [SELECT StageClientID__c, StageClientSecret__c, DevAuthURL__c,DevEndpointURL__c,DevPassword__c,DevUserName__c FROM OECCallOuts__mdt where Label ='OECMSTeamsOppo'];
            cd = new CalloutData__c(clientId__c=callouts.StageClientID__c ,clientSecret__c=callouts.StageClientSecret__c, AuthenticationURL__c=callouts.DevAuthURL__c,EndPointURL__c=callouts.DevEndpointURL__c,UserPassword__c=callouts.DevPassword__c,UserName__c=callouts.DevUserName__c);
        }
                
    }
    
    
}