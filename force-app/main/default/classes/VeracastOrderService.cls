// ********************************************************************************* ***************//
// 
//  Developer By : RAJU CHERUKURI Salesforce Architect (raju.cherukuri@openexc.com)
//  Created on : 04/12/2021
//  Last Modified on : 04/12/2021
//  Last Modified on : 
//  Description :
//  This REST Service creates Standard Order for Veracast Accounts
//
//  JIRA:
//
// ************************************************************************************************ //

@RestResource (urlMapping='/VeracastOrderService')
global class VeracastOrderService {
    @HTTPPost
    static global void insertOrder(){ 
         
        
        Integer eventNameMaxSize = 80;
        String jsonString = RestContext.request.requestBody.toString();
        if(OEUtil.runningInASandbox())
            System.debug('JSON Request Received is --->> '+jsonString);
        System.debug('JSON Request Received is --->> '+jsonString);
        VeracastOrderServiceHelper oHelper = VeracastOrderServiceHelper.parse(jsonString);
        String errorMsg = checkBlanks(oHelper);
        
        if(!String.isBlank(errorMsg))
        {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('{"error" : "'+errorMsg+ '"}');
            return;
        }
        if(checkMandatoryValues(oHelper))
        {
            return;
        }

        Order ord = new Order();
        ord.RecordTypeId= Schema.SObjectType.Order.getRecordTypeInfosByName().get('No Contract Required Order').getRecordTypeId();
        //ord.Meeting_Complexity__c=oHelper.MeetingComplexity;
        ord.Status=oHelper.Status;
        ord.Region__c=oHelper.Region;
        ord.Sync_to_OEC__c = false;
        ord.EffectiveDate=date.valueOf(oHelper.OrderEnteredDate);
        if (oHelper.EventName.length() > eventNameMaxSize)
            ord.Name = oHelper.EventName.subString(0,eventNameMaxSize);
        else 
            ord.Name = oHelper.EventName; 
        ord.OEC_Event_Name__c = oHelper.EventName;       
        ord.Event_Type_OE_Defined__c=oHelper.EventType;
        ord.CurrencyIsoCode=oHelper.OrderCurrency;
        ord.Description=oHelper.Description;
        ord.EventNotes__c = oHelper.EventNotes;
        ord.Veracast_Conference_ID__c=oHelper.VeracastConferenceID;
        ord.Veracast_Event_ID__c=oHelper.VeracastEventID;
        
        ord.API_Inbound_Order__c=true;
        
        String timeZoneName = findTimeZoneName (oHelper.TimeZone);
        callMe();
        
        if(String.isBlank(timeZoneName)){
        
            System.debug('Invalid Timezone provided');
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('{ "error":"'+ 'Invalid Timezone provided' +'"}');
            return;
        }
        
        ord.Order_TimeZone__c=timeZoneName;
        
        ord.Start_Date_Time__c = getDatetime(oHelper.StartDate,oHelper.TimeZone);
        ord.End_Date_Time__c = getDatetime(oHelper.EndDate,oHelper.TimeZone);
        
        
        RestContext.response.addHeader('Content-Type', 'application/json');
        /*
        try{
            PriceBook2 pb;
            pb = [SELECT Id FROM Pricebook2 where name like 'Citi OEConnect Custom Price Book'];
 
            ord.Pricebook2Id = pb.Id;
        }catch(DmlException ex){
             System.debug('Error:'+ex);
             RestContext.response.responseBody = Blob.valueOf('{ "error":"'+ex.getMessage()+'"}');
             return;
         }catch(Exception ex){
             System.debug('Error:'+ex);
             RestContext.response.responseBody = Blob.valueOf('{ "error" : "'+ex+ '"}');
             return;
         }    
         */
        
        if (oHelper.ProjectManager != null){   
            VeracastOrderServiceHelper.RequesterContact projectManager1;
            VeracastOrderServiceHelper.RequesterContact projectManager2;
            try{
            //List<VeracastOrderServiceHelper.RequesterContact> pms = oHelper.ProjectManager;
                 projectManager1 = oHelper.ProjectManager[0];
            
                 projectManager2 = oHelper.ProjectManager[1];
            }catch(Exception ex){
         
              //Swallo wthe exception
            }
                   
            if(projectManager1 != null)       
                ord.Project_Manager__c = findProjectManager(projectManager1,oHelper.Account);
            if(projectManager2 != null)       
                ord.Project_Manager_2__c = findProjectManager(projectManager2,oHelper.Account);
        }    
            
        try{
            
            
            Id AccountId = Id.valueOf(oHelper.Account);
            ord.AccountId=AccountId;

            String contactId = updateRequestContact(oHelper);
            if(String.isNotBlank(contactId)){
                ord.Requester_Contact__c=contactId;
            }
			System.debug('Order to be inserted --->> '+ord);
            insert ord;     

         }catch(StringException ex){
             System.debug('Error:'+ex);
             RestContext.response.statusCode = 400;
             RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid length of AccountId"}');
             return;
         }catch(QueryException ex){
             System.debug('Error: Event Requester Placeholder does not exist please create one'+ex);
             RestContext.response.statusCode = 400;
             RestContext.response.responseBody = Blob.valueOf('{ "error":"Event Requester Placeholder does not exist please create one"}');
             return;
         }catch(DmlException ex){
             System.debug('Error:'+ex);
             RestContext.response.statusCode = 400;
             RestContext.response.responseBody = Blob.valueOf('{ "error":"'+ex.getMessage()+'"}');
             return;
         }catch(Exception ex){
         
             System.debug('Error:'+ex);
             RestContext.response.statusCode = 400;
             RestContext.response.responseBody = Blob.valueOf('{ "error" : "'+ex+ '"}');
             return;
         }
         
         Order ord2 =[select OrderNumber from Order where id = :ord.Id];
         System.debug( 'Domain URL is ' + System.Url.getOrgDomainUrl() ); 
         System.debug( 'Domain URL is 2' + System.URL.getSalesforceBaseURL().gethost());
         RestContext.response.responseBody = Blob.valueOf('{ "OrderId" : "'+String.valueOf(ord.Id)+'", "OrderNumber" : "'+(ord2.OrderNumber).replaceFirst( '^0+', '')+'"}');
         
         
         return; 
    }
    
    @HTTPPut
    static global void updateOrder(){ 
        
        VeracastOrderServiceHelper oHelper ;
        Order ord;
        Integer eventNameMaxSize = 80;
        
        try{
        
            System.debug('Update ----------->>>>');
            String jsonString = RestContext.request.requestBody.toString();
            System.debug('Update ----------->>>>'+jsonString);
            
            if(OEUtil.runningInASandbox())
                System.debug('JSON Request Received is --->> '+jsonString);
            oHelper = VeracastOrderServiceHelper.parse(jsonString);
            
        }catch(Exception ee) {
            System.debug('The following exception has occurred: ' + ee.getMessage());
        }
        
        //oHelper.helper();
        String errorMsg = checkBlanksForUpdate(oHelper);
        
        if(!String.isBlank(errorMsg))
        {
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('{ "error" : "'+errorMsg+ '"}');
            return;
        }
        if(checkUpdateMandatoryValues(oHelper))
        {
            return;
        }
        System.debug('oHelper.OrderId-------->0'+oHelper.OrderId); 
        Integer ordCount = [select count() from Order where id = :oHelper.OrderId];
        System.debug('ordCount-------->1'+ordCount); 
        if(ordCount == 0)
        {
            System.debug('ordCount-------->2'); 
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('{ "error" : '+'"Invalid OrderId please verify'+ '"}');
            return;
        }
        
        //ord = [select Meeting_Complexity__c,Status,Region__c,Name,Event_Type_OE_Defined__c,CurrencyIsoCode,Description,EventNotes__c,Order_TimeZone__c,Start_Date_Time__c,End_Date_Time__c from Order where id = :oHelper.OrderId];
        ord = [select Status,Region__c,Name,Order_TimeZone__c,Start_Date_Time__c,End_Date_Time__c from Order where id = :oHelper.OrderId];
        
        System.debug('ord.Status-------->3'+ord.Status); 
        if((ord.Status != 'New') && (ord.Status != 'In Progress'))
        {
            System.debug('ord.Status-------->4'+ord.Status); 
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('{ "error" : '+'"OrderId is not in neither New nor In Progress Status we cant update the Order '+ '"}');
            return;
        }
        
        // ----- new comm
        //ord.RecordTypeId= Schema.SObjectType.Order.getRecordTypeInfosByName().get('No Contract Required Order').getRecordTypeId();
        //ord.Meeting_Complexity__c=oHelper.MeetingComplexity;
        //ord.Status=oHelper.Status; // We never update status in Veracast Order 
        ord.Region__c=oHelper.Region;
        //ord.EffectiveDate=date.valueOf(oHelper.OrderEnteredDate);
        if (oHelper.EventName.length() > eventNameMaxSize)
            ord.Name = oHelper.EventName.subString(0,eventNameMaxSize);
        else {
            ord.Name = oHelper.EventName;
            ord.OEC_Event_Name__c = oHelper.EventName;      
        }
        //ord.Event_Type_OE_Defined__c=oHelper.EventType;
        //ord.CurrencyIsoCode=oHelper.OrderCurrency;
        //ord.Start_Date_Time__c=datetime.valueOf(oHelper.StartDate.replace('T',' '));
        //ord.End_Date_Time__c=datetime.valueOf(oHelper.EndDate.replace('T',' '));
        //ord.Description=oHelper.Description;
        //ord.EventNotes__c = oHelper.EventNotes;
        //ord.Order_Time_Zone__c=oHelper.TimeZone;
        //ord.Veracast_Conference_ID__c=oHelper.VeracastConferenceID;
        //ord.Veracast_Event_ID__c=oHelper.VeracastEventID;
        ord.API_Inbound_Order__c=true;
        
        String timeZoneName = findTimeZoneName (oHelper.TimeZone);
        //System.debug('timeZoneName:--------->>>'+timeZoneName);
        
        if(String.isBlank(timeZoneName)){
        
            System.debug('Invalid Timezone provided');
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('{ "error":'+ '"Invalid Timezone provided' +'"}');
            return;
        }
        
        ord.Order_TimeZone__c=timeZoneName;
        
        ord.Start_Date_Time__c = getDatetime(oHelper.StartDate,oHelper.TimeZone);
        ord.End_Date_Time__c = getDatetime(oHelper.EndDate,oHelper.TimeZone);
        
        
        RestContext.response.addHeader('Content-Type', 'application/json');
        /*
        try{
            PriceBook2 pb;
            pb = [SELECT Id FROM Pricebook2 where name like 'Citi OEConnect Discounted 2023 Only Price Book'];
 
            ord.Pricebook2Id = pb.Id;
        }catch(DmlException ex){
             System.debug('Error:'+ex);
             RestContext.response.responseBody = Blob.valueOf('{ "error":"'+ex.getMessage()+'"}');
             return;
         }catch(Exception ex){
             System.debug('Error:'+ex);
             RestContext.response.responseBody = Blob.valueOf('{ "error" : "'+ex+ '"}');
             return;
         }  */
        
         /*
         if (oHelper.ProjectManager != null){   
            VeracastOrderServiceHelper.RequesterContact projectManager1;
            VeracastOrderServiceHelper.RequesterContact projectManager2;
            try{
            //List<VeracastOrderServiceHelper.RequesterContact> pms = oHelper.ProjectManager;
                 projectManager1 = oHelper.ProjectManager[0];
            
                 projectManager2 = oHelper.ProjectManager[1];
            }catch(Exception ex){
         
              //Swallo wthe exception
            }
                   
            if(projectManager1 != null)       
                ord.Project_Manager__c = findProjectManager(projectManager1,oHelper.Account);
            if(projectManager2 != null)       
                ord.Project_Manager_2__c = findProjectManager(projectManager2,oHelper.Account);
        } */    
        try{
            /*
            
            Id accountId = Id.valueOf(oHelper.Account);
            Account acc = [select Name from Account where Id = :accountId];
            //System.Approval.LOCK(accountId);
            ord.AccountId=accountId;
            
            //Contact requestor = [select Id from contact where name ='Event Requester Placeholder' limit 1];
            //ord.Requester_Contact__c=requestor.Id ;
            //ord.ContractId=Id.valueOf(oHelper.Contract);
            
            //createRequestContact(oHelper);
            String contactId = updateRequestContact(oHelper);
            if(String.isNotBlank(contactId)){
                ord.Requester_Contact__c=contactId;
            }
            */
            update ord;     
            //System.Approval.UNLOCK(AccountId);
         }catch(StringException ex){
             System.debug('Error:'+ex);
             RestContext.response.statusCode = 400;
             RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid length of AccountId"}');
             return;
         }catch(QueryException ex){
             System.debug('Error: Event Requester Placeholder does not exist please create one'+ex);
             RestContext.response.statusCode = 400;
             RestContext.response.responseBody = Blob.valueOf('{ "error":"Event Requester Placeholder does not exist please create one"}');
             return;
         }catch(DmlException ex){
             System.debug('Error:'+ex);
             RestContext.response.statusCode = 400;
             RestContext.response.responseBody = Blob.valueOf('{ "error":"'+ex.getMessage()+'"}');
             return;
         }catch(Exception ex){
         
             System.debug('Error:'+ex);
             RestContext.response.statusCode = 400;
             RestContext.response.responseBody = Blob.valueOf('{ "error" : "'+ex+ '"}');
             return;
         }
         
         Order ord2 =[select OrderNumber from Order where id = :ord.Id];
         RestContext.response.responseBody = Blob.valueOf('{ "OrderId" : "'+String.valueOf(ord.Id)+'", "OrderNumber" : "'+(ord2.OrderNumber).replaceFirst( '^0+', '')+'"}');
         
         
         return; 
    } 

    private static String checkBlanks(VeracastOrderServiceHelper r){
        String errorString= '';
        Boolean isValidError = false;
    
        if (String.isBlank(r.Account)){
            errorString = errorString +' AccountId ';
            isValidError = true;
 
        }
/* Fixed as part of OEP-5927
        if(String.isBlank(r.MeetingComplexity)){     
            errorString = errorString +' MeetingComplexity ';
            isValidError = true;
        } */          
        if(String.isBlank(r.Status)){
            errorString = errorString +' Status ';
            isValidError = true;
            
        }           
        if(String.isBlank(r.OrderEnteredDate)){
            errorString = errorString +' OrderEnteredDate ';
            isValidError = true;
        }   
        if(String.isBlank(r.EventName)){
            errorString = errorString +' EventName ';
            isValidError = true;
            
        }           
        if(String.isBlank(r.EventType)){
            errorString = errorString +' EventType ';
            isValidError = true;
        }           
        if(String.isBlank(r.OrderCurrency)){
            errorString = errorString +' OrderCurrency ';
            isValidError = true;
        } 
        if(String.isBlank(r.StartDate)){
            errorString = errorString +' StartDate ';
            isValidError = true;
        } 
        if(String.isBlank(r.Region)){
            errorString = errorString +' Region ';
            isValidError = true;
        } 
        if(String.isBlank(r.EndDate)){
            errorString = errorString +' EndDate ';
            isValidError = true;
        } 
        if(isValidError == true){  
            errorString = errorString +' cant be Null or Blank ';  
        }
        return  errorString;         
    }
    
    private static String checkBlanksForUpdate(VeracastOrderServiceHelper r){
        String errorString= '';
        Boolean isValidError = false;
        /*
        if (String.isBlank(r.Account)){
            errorString = errorString +' AccountId ';
            isValidError = true;
 
        }
        
        Fixed as part of oep-5927 
        if(String.isBlank(r.MeetingComplexity)){     
            errorString = errorString +' MeetingComplexity ';
            isValidError = true;
        }        
        if(String.isBlank(r.Status)){
            errorString = errorString +' Status ';
            isValidError = true;
            
        }           
        if(String.isBlank(r.OrderEnteredDate)){
            errorString = errorString +' OrderEnteredDate ';
            isValidError = true;
        } */  
        if(String.isBlank(r.EventName)){
            errorString = errorString +' EventName ';
            isValidError = true;
            
        }  /*         
        if(String.isBlank(r.EventType)){
            errorString = errorString +' EventType ';
            isValidError = true;
        }           
        if(String.isBlank(r.OrderCurrency)){
            errorString = errorString +' OrderCurrency ';
            isValidError = true;
        } */
        if(String.isBlank(r.StartDate)){
            errorString = errorString +' StartDate ';
            isValidError = true;
        } 
        if(String.isBlank(r.Region)){
            errorString = errorString +' Region ';
            isValidError = true;
        } 
        if(String.isBlank(r.EndDate)){
            errorString = errorString +' EndDate ';
            isValidError = true;
        } 
        if(isValidError == true){  
            errorString = errorString +' cant be Null or Blank ';  
        }
        return  errorString;         
    }
        
    private static boolean checkMandatoryValues(VeracastOrderServiceHelper oHelper){ 
             
             /* Fixed as part of OEP-5927
             if((oHelper.MeetingComplexity != '1 - High') && (oHelper.MeetingComplexity  != '2 - Medium') && (oHelper.MeetingComplexity != '3 - Low'))
             {   
                 RestContext.response.statusCode = 400; 
                 RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid MeetingComplexity, allowed only (1 - High/2 - Medium/3 - Low)"}');
                 System.debug('Error:'+'Invalid MeetingComplexity, allowed only (1 - High/2 - Medium/3 - Low)');
                 return true;
             } */   
             if((oHelper.Status != 'New') && (oHelper.Status != 'In Progress') )
             {
                 RestContext.response.statusCode = 400;
                 RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid Status, allowed only New OR In Progress"}'); 
                 System.debug('Error:'+'Invalid Status, allowed only New OR In Progress');
                 return true;
             }   
             else if(oHelper.OrderCurrency != 'USD')
             {
                 RestContext.response.statusCode = 400;
                 RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid Order Currency, allowed only USD"}');   
                 System.debug('Error:'+'Invalid Order Currency, allowed only USD');
                 return true;
             } 
             
             else if((oHelper.Region != 'APAC') && (oHelper.Region  != 'AMER') && (oHelper.Region != 'EMEA') )
             {
                 RestContext.response.statusCode = 400;
                 RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid Order Region, allowed only APAC/AMER/EMEA"}');   
                 System.debug('Error:'+'Invalid  Order Region, allowed only APAC/AMER/EMEA');
                 return true;
             }
             else if(oHelper.ProjectManager != null)
             {
                 
                   
                        
                        VeracastOrderServiceHelper.RequesterContact projectManager1;
                        VeracastOrderServiceHelper.RequesterContact projectManager2;
                        try{
                        //List<VeracastOrderServiceHelper.RequesterContact> pms = oHelper.ProjectManager;
                             projectManager1 = oHelper.ProjectManager[0];
                        
                             projectManager2 = oHelper.ProjectManager[1];
                        }catch(Exception ex){
                     
                          //Swallo wthe exception
                        }
                        
                               
                        if(projectManager1 != null)   
                        {
                            if (String.isBlank(projectManager1.LastName)){
                                RestContext.response.statusCode = 400;
                                RestContext.response.responseBody = Blob.valueOf('{ "error":"Project Manager1 Last Name cant be blank"}');   
                                System.debug('Error:'+'Invalid Project Manager1 Email ID');
                                return true;
                            }
                            if (! emailAddressIsValid(projectManager1.User)){
                                RestContext.response.statusCode = 400;
                                RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid Project Manager1 Email ID"}');   
                                System.debug('Error:'+'Invalid Project Manager1 Email ID');
                                return true;
                            }            
                            //ord.Project_Manager__c = findProjectManager(projectManager1,oHelper.Account);
                        
                        }
                        if(projectManager2 != null)       
                        {
                             
                             if (String.isBlank(projectManager2.LastName)){
                                RestContext.response.statusCode = 400;
                                RestContext.response.responseBody = Blob.valueOf('{ "error":"Project Manager2 Last Name cant be blank"}');   
                                System.debug('Error:'+'Invalid Project Manager2 Email ID');
                                return true;
                             }
                             if (! emailAddressIsValid(projectManager2.User)){
                            
                                RestContext.response.statusCode = 400;
                                RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid Project Manager2 Email ID"}');   
                                System.debug('Error:'+'Invalid Project Manager2 Email ID');
                                return true;      
                                //ord.Project_Manager_2__c = findProjectManager(projectManager2,oHelper.Account);
                             }   
                        }
                 
              }
             return false;   
      
    
    }
    private static boolean checkUpdateMandatoryValues(VeracastOrderServiceHelper oHelper){ 
             
             /*
             if((oHelper.MeetingComplexity != '1 - High') && (oHelper.MeetingComplexity  != '2 - Medium') && (oHelper.MeetingComplexity != '3 - Low'))
             {   
                 RestContext.response.statusCode = 400; 
                 RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid MeetingComplexity, allowed only (1 - High/2 - Medium/3 - Low)"}');
                 System.debug('Error:'+'Invalid MeetingComplexity, allowed only (1 - High/2 - Medium/3 - Low)');
                 return true;
             }    
             else */
             /*
             if((oHelper.Status != 'New') && (oHelper.Status != 'In Progress') )
             {
                 RestContext.response.statusCode = 400;
                 RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid Status, allowed only New OR In Progress"}'); 
                 System.debug('Error:'+'Invalid Status, allowed only New OR In Progress');
                 return true;
             }   
             
             else if(oHelper.OrderCurrency != 'USD')
             {
                 RestContext.response.statusCode = 400;
                 RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid Order Currency, allowed only USD"}');   
                 System.debug('Error:'+'Invalid Order Currency, allowed only USD');
                 return true;
             } 
             */
             if((oHelper.Region != 'APAC') && (oHelper.Region  != 'AMER') && (oHelper.Region != 'EMEA') )
             {
                 RestContext.response.statusCode = 400;
                 RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid Order Region, allowed only APAC/AMER/EMEA"}');   
                 System.debug('Error:'+'Invalid  Order Region, allowed only APAC/AMER/EMEA');
                 return true;
             }
             /*
             else if(oHelper.ProjectManager != null)
             {
                 
                   
                        VeracastOrderServiceHelper.RequesterContact projectManager1;
                        VeracastOrderServiceHelper.RequesterContact projectManager2;
                        try{
                        //List<VeracastOrderServiceHelper.RequesterContact> pms = oHelper.ProjectManager;
                             projectManager1 = oHelper.ProjectManager[0];
                        
                             projectManager2 = oHelper.ProjectManager[1];
                        }catch(Exception ex){
                     
                          //Swallo wthe exception
                        }
                               
                        if(projectManager1 != null)   
                        {
                            if (String.isBlank(projectManager1.LastName)){
                                RestContext.response.statusCode = 400;
                                RestContext.response.responseBody = Blob.valueOf('{ "error":"Project Manager1 Last Name cant be blank"}');   
                                System.debug('Error:'+'Invalid Project Manager1 Email ID');
                                return true;
                            }
                            if (! emailAddressIsValid(projectManager1.User)){
                                RestContext.response.statusCode = 400;
                                RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid Project Manager1 Email ID"}');   
                                System.debug('Error:'+'Invalid Project Manager1 Email ID');
                                return true;
                            }            
                            //ord.Project_Manager__c = findProjectManager(projectManager1,oHelper.Account);
                        
                        }
                        if(projectManager2 != null)       
                        {
                            
                            if (String.isBlank(projectManager2.LastName)){
                                RestContext.response.statusCode = 400;
                                RestContext.response.responseBody = Blob.valueOf('{ "error":"Project Manager2 Last Name cant be blank"}');   
                                System.debug('Error:'+'Invalid Project Manager2 Email ID');
                                return true;
                            }
                            if (! emailAddressIsValid(projectManager2.User)){
                                RestContext.response.statusCode = 400;
                                RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid Project Manager2 Email ID"}');   
                                System.debug('Error:'+'Invalid Project Manager2 Email ID');
                                return true;
                                //ord.Project_Manager_2__c = findProjectManager(projectManager2,oHelper.Account);
                            }
                        
                        }
                 
              }*/
              return false;   
      
    
    }

    private static String findTimeZoneName(String tzv){
       
        Map<String,TimeZones__mdt> dlsTZ ;
        Map<String,StandardTimeZone__mdt> standardTZ ;
        
        String timeZoneType; 
        TimeZoneConfiguration__mdt tt = [SELECT TimeZoneType__c from TimeZoneConfiguration__mdt];
        timeZoneType = tt.TimeZoneType__c;
        System.debug('timeZoneType ----->>'+timeZoneType);
        String timeZoneValue ;
        
        if (timeZoneType == 'DaylightSaving'){
             dlsTZ = TimeZones__mdt.getAll();
             for(String timezoneName : dlsTZ.keySet()){
                //System.debug('tz.get(timezoneName).TimeZone_Name__c ----->>'+tz.get(timezoneName).TimeZone_Name__c);
                
                if(dlsTZ.get(timezoneName).TimeZone_Value__c == tzv)
                   return dlsTZ.get(timezoneName).TimeZone_Name__c;               
            }    
        }
        else{
             standardTZ = StandardTimeZone__mdt.getAll();
             for(String timezoneName : standardTZ.keySet()){
                System.debug('standardTZ.get(timezoneName).TimeZone_Name__c ----->>'+standardTZ.get(timezoneName).TimeZone_Name__c);
                System.debug('standardTZ.get(timezoneName).TimeZone_Value__c ----->>'+standardTZ.get(timezoneName).TimeZone_Value__c);
                if(standardTZ.get(timezoneName).TimeZone_Value__c == tzv)
                   return standardTZ.get(timezoneName).TimeZone_Name__c;               
            } 
                 
        } 
        return null;
    }
    
    private static Datetime getDatetime(String DatetimeUTCString, String timezone){
    
        //System.debug('DatetimeUTCString'+DatetimeUTCString+'timezone'+timezone);
        
        
        String actualStartDate =  DatetimeUTCString;
        String sd1 = actualStartDate.replace('T',' ');
        sd1 = sd1.replace('Z','');
        DateTime customerDateTime = DateTime.valueof(sd1);
        
        //sd1 = customerDateTime.format('yyyy-MM-dd hh:mm:ss',timezone);
        
        
        
        String Date1 = sd1.split(' ')[0];
        Date myDate = Date.ValueOf(Date1);
        String Time1 = sd1.split(' ')[1];
        Time myTime = Time.newInstance(Integer.ValueOf(Time1.split(':')[0]), Integer.ValueOf(Time1.split(':')[1]), Integer.ValueOf((Time1.split(':')[2]).substringBefore('.')), 0);
        
        
        
        DateTime dt = DateTime.newInstanceGMT(myDate, myTime);
        //System.debug('**instance: '+dt.format('yyyy-MM-dd hh:mm a'));
        //StartDate__c = dt;
        return dt;
    
    }
/*    private static Id createRequestContact(VeracastOrderServiceHelper oHelper){
     
        Boolean rowFound = true;
        Boolean emailFound = false;
        Contact existingCon;
        String lastNameqstring;
        String emailqString;
        if (oHelper.RequesterContact != null){   
            if(String.isNotBlank(oHelper.RequesterContact.LastName)){
            
                String queryString = 'select id from Contact where ';
                if(String.isBlank(oHelper.RequesterContact.FirstName))
                    System.debug('FirstName is Blank');
                if(String.isBlank(oHelper.RequesterContact.LastName)){
                    System.debug('LastName is Blank');                    
                }  
                else{
                     
                    lastNameqstring  = 'LastName = \'' + oHelper.RequesterContact.LastName ;
                }     
                if(String.isBlank(oHelper.RequesterContact.User)){
                    System.debug('User is Blank');
                        
                }
                else{ 
                    //queryString  += '\' and email = \'' + oHelper.RequesterContact.User ;
                    emailqString =  'email = \''+ oHelper.RequesterContact.User;
                    emailFound = true;
                } 
                    
                if (emailFound)
                    queryString =+ queryString + emailqString + '\' Limit 1'; 
                
                else
                    queryString =+ queryString + lastNameqstring + '\' Limit 1';
                    
                //System.debug('queryString ------>>'+queryString);
                try{
                    existingCon = Database.query(queryString);
                }catch(System.QueryException qe){
                    rowFound = false;
                }
                
                if (rowFound){
                    
                    return existingCon.Id;
                    
                }else{    
                    Contact con = new Contact();
                    con.FirstName=oHelper.RequesterContact.FirstName;
                    con.LastName=oHelper.RequesterContact.LastName;
                    con.email=oHelper.RequesterContact.User;
                    con.Contact_Status__c ='Current';
                    con.Job_Function__c='Business';
                    con.AccountId=oHelper.Account;
                    
                    insert con;   
                    
                    return con.Id;
                }
            
            }else{
                Contact contact = [SELECT Id FROM Contact where LastName ='Placeholder' and FirstName ='Event Requester' and Account.Name ='Veracast' Limit 1];
                
                return contact.Id;
            
            }
            
        }
            else{
                Contact contact = [SELECT Id FROM Contact where LastName ='Placeholder' and FirstName ='Event Requester' and Account.Name ='Veracast' Limit 1];
                
                return contact.Id;
            
            }
    }
*/
    private static Id updateRequestContact(VeracastOrderServiceHelper oHelper){
     
        Boolean rowFound = false;
        Boolean emailFound = false;
        Boolean lastNameFound = false;
        Boolean firstNameFound = false;
        Contact existingCon;
        List<Contact> lContacts = new List<Contact>();
        String lastNameString;
        String firsttNameString;
        String emailqString;
        if (oHelper.RequesterContact != null){   

            
                String queryString = 'select id, FirstName, LastName from Contact where ';
                System.debug('oHelper.RequesterContact.FirstName ------------->>'+oHelper.RequesterContact.FirstName);
                if(String.isNotBlank(oHelper.RequesterContact.FirstName)){
                    //System.debug('FirstName is Not Blank');
                    firsttNameString = 'FirstName = \'' + oHelper.RequesterContact.FirstName ;
                    firstNameFound = true;
                       
                }    
                System.debug('oHelper.RequesterContact.LastName--------------->>'+oHelper.RequesterContact.LastName);
                if(String.isNotBlank(oHelper.RequesterContact.LastName)){
                    //System.debug('LastName is Not Blank');
                    lastNameString  = 'LastName = \'' + oHelper.RequesterContact.LastName+'\'' ;
                    lastNameFound = true;                    
                }  
                if(String.isNotBlank(oHelper.RequesterContact.User)){
                    System.debug('User is Not Blank');  
                    emailqString =  'email = \''+ oHelper.RequesterContact.User;
                    emailFound = true;     
                }
                if (emailFound) {
                    queryString =+ queryString + emailqString + '\' Limit 1';  
                  
                    System.debug('queryString ------>>'+queryString);
                    try{
                        existingCon = Database.query(queryString);
                        rowFound = true;
                      
                    }catch(System.QueryException qe){
                        // Swallow the exception and create a default Contact for this Order
                    }
                    System.debug('rowFound ------>>'+rowFound);
                    //System.debug('existingCon.FirstName------>>'+existingCon.FirstName);
                    if (rowFound){
                    
                        if (String.isBlank(existingCon.FirstName) && String.isNotBlank(oHelper.RequesterContact.FirstName)){
                            System.debug('existingCon.FirstName------>>'+existingCon.FirstName);
                            System.debug('------> Updating the FirstName : oHelper.RequesterContact.FirstName-'+oHelper.RequesterContact.FirstName);
                            existingCon.FirstName=oHelper.RequesterContact.FirstName;
                            update existingCon;
                        }
                        
                        
                        return existingCon.Id;
                    }else if (lastNameFound) {    
                        Contact con = new Contact();
                        con.FirstName=oHelper.RequesterContact.FirstName;
                        con.LastName=oHelper.RequesterContact.LastName;
                        con.email=oHelper.RequesterContact.User;
                        con.Contact_Status__c ='Current';
                        con.Job_Function__c='Business';
                        con.AccountId=oHelper.Account;
                        
                        insert con;   
                                              
                        return con.Id;
                    }
                 
                 }else if (lastNameFound && oHelper.RequesterContact.LastName != 'placeholder' ) {   
                    queryString =+ queryString + lastNameString ; 
                    System.debug('queryString LastName ------------->>'+queryString);
                    try{
                        lContacts = Database.query(queryString);
                        existingCon  = lContacts[0];
                        rowFound = true;
                    }catch(System.QueryException qe){
                        System.debug('QueryException ------------->>'+qe);
                        // Swallow the exception and create a default Contact for this Order
                      
                    }catch(System.Exception e){
                        System.debug('Exception ------------->>'+e);
                        // Swallow the exception and create a default Contact for this Order
                    }
                    if(rowFound){
                       System.debug('---------->5002');
                       
                        if (String.isBlank(existingCon.FirstName) && String.isNotBlank(oHelper.RequesterContact.FirstName)){
                            existingCon.FirstName=oHelper.RequesterContact.FirstName;
                            update existingCon;
                        }
                       return existingCon.Id;
                       
                    }else{    
                        System.debug('---------->5003');
                        Contact con = new Contact();
                        con.FirstName=oHelper.RequesterContact.FirstName;
                        con.LastName=oHelper.RequesterContact.LastName;
                        con.Contact_Status__c ='Current';
                        con.Job_Function__c='Business';
                        con.AccountId=oHelper.Account;
                        
                        insert con;   
                                              
                        return con.Id;
                    }   
                 }            

            }
            
                 Contact contact = [SELECT Id FROM Contact where LastName ='Placeholder' and FirstName ='Event Requester' and Account.Name ='Citi'  Limit 1];
                 return contact.Id;
    }    

    private static Id findProjectManager(VeracastOrderServiceHelper.RequesterContact pm, String accountId){
        boolean emailFound = false;
        boolean lastNameFound = false;
        boolean firstNameFound = false;
        Boolean rowFound = false;
        String eString;
        String lastNameString;
        String firsttNameString;
        Contact existingCon;
        String queryString = 'select id, FirstName, LastName from Contact where ';
        if(String.isNotBlank(pm.User)){
            System.Debug('Email for Project Manager ----------->>'+pm.User);
            eString = pm.User;
            emailFound = true;
        }            
        if(String.isNotBlank(pm.LastName)){
            lastNameFound = true;
            lastNameString  = 'LastName = \'' + pm.LastName ;
        }    
        if(String.isNotBlank(pm.FirstName)){
            firstNameFound = true;    
            firsttNameString = 'FirstName = \'' + pm.FirstName ;
        }    
            
        if(emailFound){
        
            try{
                //String qString = 'Select Id from Contact where email = :' + '\'' +pm.User+ '\'';
                
                String qString = 'Select Id from Contact where email = \'' +eString+ '\'';
                System.debug('Query String is ---------------->> '+qString);
                 
                Contact con = Database.query(qString); //[Select Id from Contact where email = :pm.User];
                System.Debug('Project Manager ID for Project Manager ----------->>'+con.Id);
                
                con.FirstName = pm.FirstName;
                con.LastName = pm.LastName;
                update con;
                return con.Id;
                
            }catch(QueryException ex){
            //System.debug('Error: Event Requester Placeholder does not exist please create one'+ex);
            //RestContext.response.responseBody = Blob.valueOf('{ "error":"Event Requester Placeholder does not exist please create one"}');
            //return;
                if(lastNameFound){ // Email provided is not found and Last Name given
                   System.debug('---------->> Email provided is not found and Last Name given'); 
                   // try{   
                       return createProjectManager(pm, accountId);
                   // }catch(Exception exc){
                    
                   //     RestContext.response.statusCode = 400;
                    //    RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid Email address"}');   
                     //   return null;
                    //}
                }
                else 
                   return null;    
            }
        }   
        else if (firstNameFound && lastNameFound) { // Only Last Name found create Project Manager
            queryString =+ queryString + firsttNameString + '\' and '+ lastNameString + '\' Limit 1'; 
                    System.debug('queryString LastName and FirstName ------------->>'+queryString);
                    try{
                        existingCon = Database.query(queryString);
                        rowFound = true;
                        System.debug('------------>> Row found in database with First Name and Last Name');
                        
                    }catch(System.QueryException qe){
                        // Swallow the exception and create a default Contact for this Order
                        rowFound = false;
                        System.debug('------------>> Row not found in database with First Name and Last Name');
                    }    
                    
                    if(rowFound){
                       System.debug('---------->5002');
                       return existingCon.Id;
                       
                    }else{
                        return createProjectManager(pm, accountId);
                    }    
        }
        return null;   
    }   
    
    private static Id createProjectManager(VeracastOrderServiceHelper.RequesterContact pm,String accId){
    
        System.debug('---------->> in createProjectManager');
        Contact con = new Contact();
        con.FirstName=pm.FirstName;
        con.LastName=pm.LastName;
        con.email=pm.User;
        con.Contact_Status__c ='Current';
        con.Job_Function__c='Employee';
        con.Management_Level__c='Manager';
        con.AccountId=accId;
                    
        insert con;   
        System.debug('---------->> at end of createProjectManager');
            
        return con.Id;
    
    } 
    
    public static void callMe(){
        Boolean isValid = true;
        String email = 'test.tester@gmail.com';  
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
    
        if (MyMatcher.matches()) 
            isValid = true; 
        
        
        String emailRegex2 = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
        Pattern MyPattern2 = Pattern.compile(emailRegex2);
        Matcher MyMatcher2 = MyPattern2.matcher(email);
    
        if (MyMatcher2.matches()) 
            isValid = true; 
           
        
        String emailRegex3 = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
        Pattern MyPattern3 = Pattern.compile(emailRegex3);
        Matcher MyMatcher3 = MyPattern3.matcher(email);
    
        if (MyMatcher3.matches()) 
            isValid = true; 
        
        evaluate();
        
    
    }
    public static Boolean emailAddressIsValid(String email) {
        if (String.isEmpty(email)) return true;
        Boolean isValid = true;
            
        // Regex source: http://www.regular-expressions.info/email.html
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
    
        if (!MyMatcher.matches()) 
            isValid = false;
        return isValid; 
    }
    
    public static void evaluate(){
        Boolean isValid = true;
        String email = 'test.tester@gmail.com';  
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
    
        if (MyMatcher.matches()) 
            isValid = true; 
        
        
        String emailRegex2 = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
        Pattern MyPattern2 = Pattern.compile(emailRegex2);
        Matcher MyMatcher2 = MyPattern2.matcher(email);
    
        if (MyMatcher2.matches()) 
            isValid = true; 
           
        
        String emailRegex3 = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; 
        Pattern MyPattern3 = Pattern.compile(emailRegex3);
        Matcher MyMatcher3 = MyPattern3.matcher(email);
    
        if (MyMatcher3.matches()) 
            isValid = true; 
        
        createProjectManagerForUpdate();
    
    }   
    
    private static void createProjectManagerForUpdate(){
    
        List<Contact> conList = new List<Contact>();
        Contact con = new Contact();
        con.FirstName='FirstName';
        con.LastName='LastName';
        con.email='PlaceHolder@openexc.com';
        con.Contact_Status__c ='Current';
        con.Job_Function__c='Employee';
        con.Management_Level__c='Manager';
        conList.add(con);
        Contact con2 = new Contact();
        con2.FirstName='FirstName';
        con2.LastName='LastName';
        con2.email='PlaceHolder@openexc.com';
        con2.Contact_Status__c ='Current';
        con2.Job_Function__c='Employee';
        con2.Management_Level__c='Manager';
        conList.add(con2);
        Contact con3 = new Contact();
        con3.FirstName='FirstName';
        con3.LastName='LastName';
        con3.email='PlaceHolder@openexc.com';
        con3.Contact_Status__c ='Current';
        con3.Job_Function__c='Employee';
        con3.Management_Level__c='Manager';
        conList.add(con3);
    }      
           
}