/***************************************************************************************
* 
* Version 1
* Developer:        RAJU CHERUKURI
* Role:             Salesforce Architect
* Email:            raju.cherukuri@openexc.com
* Created On:       05/04/2021
* 
*
* Version 2
* Developer:		Nilesh Bharti
* Role:				Salesforce Consultant
* Email:			nilesh.bharti@openexc.com
* Last Modified On: 30/04/2025
* 
* Description:
* This REST Service creates a 'No Contract Required Order' for the CITI, RBC Capital Markets LLC & Barclays Account received as request from API.
*
* JIRA:
*
***************************************************************************************/

@RestResource (urlMapping='/OrderService')
global class OrderService {
    @HTTPPost
    static global void insertOrder(){
        
        Integer eventNameMaxSize = 80;
        String jsonString = RestContext.request.requestBody.toString();
        System.debug('JSON Request Received is --->> '+jsonString);
        if(OEUtil.runningInASandbox())
            System.debug('JSON Request Received is --->> '+jsonString);
        OrderServiceHelper oHelper = OrderServiceHelper.parse(jsonString);
        String errorMsg = checkBlanks(oHelper);
        
        if(!String.isBlank(errorMsg)){
            RestContext.response.responseBody = Blob.valueOf('{ "error" : '+errorMsg+ '}');
            return;
        }
        if(checkMandatoryValues(oHelper)){
            return;
        }
        
        Order ord = new Order();
        ord.RecordTypeId= Schema.SObjectType.Order.getRecordTypeInfosByName().get('No Contract Required Order').getRecordTypeId();
        ord.Meeting_Complexity__c = oHelper.MeetingComplexity;
        ord.Status = oHelper.Status;
        ord.Region__c = oHelper.Region;
        ord.EffectiveDate=date.valueOf(oHelper.OrderEnteredDate);
        
        if (oHelper.EventName.length() > eventNameMaxSize)
            ord.Name = oHelper.EventName.subString(0,eventNameMaxSize);
        else
            ord.Name = oHelper.EventName;
        ord.OEC_Event_Name__c = oHelper.EventName;
        ord.Event_Type_OE_Defined__c = oHelper.EventType;
        ord.CurrencyIsoCode = oHelper.OrderCurrency;
        ord.Description = oHelper.Description;
        ord.EventNotes__c = oHelper.EventNotes;
        ord.API_Inbound_Order__c = true;
        
        String timeZoneName = findTimeZoneName (oHelper.TimeZone);
        if(String.isBlank(timeZoneName)){
            System.debug('Invalid Timezone provided');
            RestContext.response.responseBody = Blob.valueOf('{ "error":"'+ 'Invalid Timezone provided' +'"}');
            return;
        }
        
        ord.Order_TimeZone__c = timeZoneName;
        ord.Start_Date_Time__c = getDatetime(oHelper.StartDate,oHelper.TimeZone);
        ord.End_Date_Time__c = getDatetime(oHelper.EndDate,oHelper.TimeZone);
        
        RestContext.response.addHeader('Content-Type', 'application/json');
        try{
            Id AccountId = Id.valueOf(oHelper.Account);
            System.debug('AccountId:- '+AccountId);
            //System.Approval.LOCK(AccountId);
            ord.AccountId = AccountId;
            
            Account acc = [SELECT Id, Name FROM Account where Id =:AccountId LIMIT 1];
            System.debug('Account from API :--------->>> '+acc);
            
            String pricebookId = updatePricebook(acc.Name);
            if(String.isNotBlank(pricebookId)){
                ord.Pricebook2Id = Id.valueOf(pricebookId);
            }
            
            String contactId = updateRequestContact(oHelper);
            if(String.isNotBlank(contactId)){
                ord.Requester_Contact__c = contactId;
            }
            
            insert ord;
            //System.Approval.UNLOCK(AccountId);
        }catch(StringException ex){
            System.debug('Error:'+ex);
            RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid length of AccountId"}');
            return;
        }catch(QueryException ex){
            System.debug('Error: Event Requester Placeholder does not exist please create one'+ex);
            RestContext.response.responseBody = Blob.valueOf('{ "error":"Event Requester Placeholder does not exist please create one"}');
            return;
        }catch(DmlException ex){
            System.debug('Error:'+ex);
            RestContext.response.responseBody = Blob.valueOf('{ "error":"'+ex.getMessage()+'"}');
            return;
        }catch(Exception ex){
            System.debug('Error:'+ex);
            RestContext.response.responseBody = Blob.valueOf('{ "error" : "'+ex+ '"}');
            return;
        }
        
        Order ord2 = [SELECT OrderNumber FROM Order WHERE id = :ord.Id];
        RestContext.response.responseBody = Blob.valueOf('{ "OrderId" : "'+String.valueOf(ord.Id)+'", "OrderNumber" : "'+(ord2.OrderNumber).replaceFirst( '^0+', '')+'"}');
        return;
    }
    
    @HTTPPut
    static global void updateOrder(){ 
        
        OrderServiceHelper oHelper ;
        Order ord;
        Integer eventNameMaxSize = 80;
        
        try{
            String jsonString = RestContext.request.requestBody.toString();
            System.debug('Update ----------->>>>'+jsonString);
            
            if(OEUtil.runningInASandbox())
                System.debug('JSON Request Received is --->> '+jsonString);
            oHelper = OrderServiceHelper.parse(jsonString);
            
        }catch(Exception ee) {
            System.debug('The following exception has occurred: ' + ee.getMessage());
        }
        
        String errorMsg = checkBlanks(oHelper);
        
        if(!String.isBlank(errorMsg)){
            RestContext.response.responseBody = Blob.valueOf('{ "error" : '+errorMsg+ '}');
            return;
        }
        if(checkMandatoryValues(oHelper)){
            return;
        }
        System.debug('oHelper.OrderId-------->0'+oHelper.OrderId);
        Integer ordCount = [SELECT count() FROM Order WHERE Id = :oHelper.OrderId];
        System.debug('ordCount-------->1'+ordCount);
        
        if(ordCount == 0){
            System.debug('ordCount-------->2');
            RestContext.response.responseBody = Blob.valueOf('{ "error" : '+'Invalid OrderId please verify'+ '}');
            return;
        }
        
        ord = [SELECT Meeting_Complexity__c, Status, Region__c, Name, Event_Type_OE_Defined__c, 
               CurrencyIsoCode, Description,EventNotes__c, Order_TimeZone__c, Start_Date_Time__c, End_Date_Time__c 
               FROM Order WHERE Id = :oHelper.OrderId];
        System.debug('ord.Status-------->3'+ord.Status);
        
        if(ord.Status != 'New'){
            RestContext.response.responseBody = Blob.valueOf('{ "error" : '+'OrderId is not in New Status we cant update the Order '+ '}');
            return;
        }
        
        ord.RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByName().get('No Contract Required Order').getRecordTypeId();
        ord.Meeting_Complexity__c = oHelper.MeetingComplexity;
        ord.Status = oHelper.Status;
        ord.EffectiveDate = date.valueOf(oHelper.OrderEnteredDate);
        
        if (oHelper.EventName.length() > eventNameMaxSize)
            ord.Name = oHelper.EventName.subString(0,eventNameMaxSize);
        else {
            ord.Name = oHelper.EventName;
            ord.OEC_Event_Name__c = oHelper.EventName;
        }
        
        ord.Event_Type_OE_Defined__c = oHelper.EventType;
        ord.CurrencyIsoCode = oHelper.OrderCurrency;
        ord.Description = oHelper.Description;
        ord.EventNotes__c = oHelper.EventNotes;
        ord.API_Inbound_Order__c = true;
        
        String timeZoneName = findTimeZoneName (oHelper.TimeZone);
        if(String.isBlank(timeZoneName)){
            System.debug('Invalid Timezone provided');
            RestContext.response.responseBody = Blob.valueOf('{ "error":"'+ 'Invalid Timezone provided' +'"}');
            return;
        }
        
        ord.Order_TimeZone__c = timeZoneName;
        ord.Start_Date_Time__c = getDatetime(oHelper.StartDate,oHelper.TimeZone);
        ord.End_Date_Time__c = getDatetime(oHelper.EndDate,oHelper.TimeZone);
        
        RestContext.response.addHeader('Content-Type', 'application/json');
        try{
            Id AccountId = Id.valueOf(oHelper.Account);
            //System.Approval.LOCK(AccountId);
            ord.AccountId = AccountId;
            
            Account acc = [SELECT Id, Name FROM Account WHERE Id =:AccountId LIMIT 1];
            System.debug('Account from API :--------->>> '+acc);
            
            String pricebookId = updatePricebook(acc.Name);
            if(String.isNotBlank(pricebookId)){
                ord.Pricebook2Id = Id.valueOf(pricebookId);
            }
            
            String contactId = updateRequestContact(oHelper);
            if(String.isNotBlank(contactId)){
                ord.Requester_Contact__c = contactId;
            }
            
            update ord;
            //System.Approval.UNLOCK(AccountId);
        }catch(StringException ex){
            System.debug('Error:'+ex);
            RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid length of AccountId"}');
            return;
        }catch(QueryException ex){
            System.debug('Error: Event Requester Placeholder does not exist please create one'+ex);
            RestContext.response.responseBody = Blob.valueOf('{ "error":"Event Requester Placeholder does not exist please create one"}');
            return;
        }catch(DmlException ex){
            System.debug('Error:'+ex);
            RestContext.response.responseBody = Blob.valueOf('{ "error":"'+ex.getMessage()+'"}');
            return;
        }catch(Exception ex){
            System.debug('Error:'+ex);
            RestContext.response.responseBody = Blob.valueOf('{ "error" : "'+ex+ '"}');
            return;
        }
        
        Order ord2 = [SELECT OrderNumber FROM Order WHERE id = :ord.Id];
        RestContext.response.responseBody = Blob.valueOf('{ "OrderId" : "'+String.valueOf(ord.Id)+'", "OrderNumber" : "'+(ord2.OrderNumber).replaceFirst( '^0+', '')+'"}');
        return;
    }
    
    @HTTPPatch
    static global void patchOrder(){ 
        
        OrderServiceHelper oHelper ;
        Order ord;
        Integer eventNameMaxSize = 80;
        
        try{
            
            String jsonString = RestContext.request.requestBody.toString();
            
            if(OEUtil.runningInASandbox())
                System.debug('JSON Request Received is --->> '+jsonString);
            oHelper = OrderServiceHelper.parse(jsonString);
            
        }catch(Exception ee) {
            System.debug('The following exception has occurred: ' + ee.getMessage());
        }
        
        String errorMsg = checkPatchBlanks(oHelper);
        if(!String.isBlank(errorMsg)){
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('{ "error" : '+errorMsg+ '}');
            return;
        }
        
        Integer ordCount = [SELECT count() FROM Order WHERE Id = :oHelper.OrderId];
        
        if(ordCount == 0){
            RestContext.response.responseBody = Blob.valueOf('{ "error" : '+'Invalid OrderId please verify'+ '}');
            return;
        }
        
        ord = [SELECT OE_Central_URL__c, Status, OECEventId__c, OECExternalEventId__c,
               Client_Cost_Code__c, SyncStatus__c, Sync_Datetime__c, Sync_to_OEC__c
               FROM Order WHERE Id = :oHelper.OrderId];
        
        if(ord.Status != 'New' && ord.Status != 'In Progress'){            
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf('{ "error" : '+'"OrderId is not in eiter New or In Progress Status we cant update the Order "'+ '}');
            return;
        }
        
        ord.OE_Central_URL__c = oHelper.OECentralURL;
        ord.OECEventId__c = oHelper.EventId;
        ord.Client_Cost_Code__c = oHelper.ExternalEventId;
        ord.OECExternalEventId__c = oHelper.ExternalEventId;
        ord.SyncStatus__c = 'Synced';
        ord.Sync_Datetime__c = System.now();
        ord.Sync_to_OEC__c = true;
        
        RestContext.response.addHeader('Content-Type', 'application/json');
        try{
            update ord;            
        }catch(QueryException ex){
            System.debug('Error: Event Requester Placeholder does not exist please create one'+ex);
            RestContext.response.responseBody = Blob.valueOf('{ "error":"Event Requester Placeholder does not exist please create one"}');
            return;
        }catch(DmlException ex){
            System.debug('Error:'+ex);
            RestContext.response.responseBody = Blob.valueOf('{ "error":"'+ex.getMessage()+'"}');
            return;
        }catch(Exception ex){
            System.debug('Error:'+ex);
            RestContext.response.responseBody = Blob.valueOf('{ "error" : "'+ex+ '"}');
            return;
        }
        
        Order ord2 = [SELECT OrderNumber FROM Order WHERE Id = :ord.Id];
        RestContext.response.responseBody = Blob.valueOf('{ "OrderId" : "'+String.valueOf(ord.Id)+'", "OrderNumber" : "'+(ord2.OrderNumber).replaceFirst( '^0+', '')+'"}');
        return;
    }
    
    private static String checkPatchBlanks(OrderServiceHelper r){
        String errorString= '';
        Boolean isValidError = false;
        
        if(String.isBlank(r.OrderId)){
            errorString = errorString +' OrderId ';
            isValidError = true;
        }
        if(String.isBlank(r.OECentralURL)){
            errorString = errorString +' OECentralURL ';
            isValidError = true;
        }
        if(isValidError == true){
            errorString = errorString +' cant be Null or Blank ';
        }
        return  errorString;
    }
    
    private static String checkBlanks(OrderServiceHelper r){
        String errorString= '';
        Boolean isValidError = false;
        
        if (String.isBlank(r.Account)){
            errorString = errorString +' AccountId ';
            isValidError = true;
        }
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
        if(String.isBlank(r.EndDate)){
            errorString = errorString +' EndDate ';
            isValidError = true;
        }
        if(isValidError == true){
            errorString = errorString +' cant be Null or Blank ';
        }
        return  errorString;
    }
    
    private static boolean checkMandatoryValues(OrderServiceHelper oHelper){
        
        if((oHelper.MeetingComplexity != '1 - High') && (oHelper.MeetingComplexity  != '2 - Medium') && (oHelper.MeetingComplexity != '3 - Low')){
            RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid MeetingComplexity, allowed only (1 - High/2 - Medium/3 - Low)"}');
            System.debug('Error:'+'Invalid MeetingComplexity, allowed only (1 - High/2 - Medium/3 - Low)');
            return true;
        }
        else if(oHelper.Status != 'New'){
            RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid Status, allowed only New"}');
            System.debug('Error:'+'Invalid Status, allowed only New');
            return true;
        }
        else if(oHelper.OrderCurrency != 'USD'){
            RestContext.response.responseBody = Blob.valueOf('{ "error":"Invalid Order Currency, allowed only USD"}');
            System.debug('Error:'+'Invalid Order Currency, allowed only USD');
            return true;
        }
        return false;
    }
    
    private static String findTimeZoneName(String tzv){
        
        Map<String,TimeZones__mdt> dlsTZ ;
        Map<String,StandardTimeZone__mdt> standardTZ ;
        
        String timeZoneType;
        TimeZoneConfiguration__mdt tt = [SELECT TimeZoneType__c FROM TimeZoneConfiguration__mdt];
        timeZoneType = tt.TimeZoneType__c;
        System.debug('timeZoneType ----->>'+timeZoneType);
        String timeZoneValue ;
        
        if (timeZoneType == 'DaylightSaving'){
            dlsTZ = TimeZones__mdt.getAll();
            for(String timezoneName : dlsTZ.keySet()){
                if(dlsTZ.get(timezoneName).TimeZone_Value__c == tzv)
                    return dlsTZ.get(timezoneName).TimeZone_Name__c;
            }
        }
        else{
            standardTZ = StandardTimeZone__mdt.getAll();
            for(String timezoneName : standardTZ.keySet()){
                if(standardTZ.get(timezoneName).TimeZone_Value__c == tzv)
                    return standardTZ.get(timezoneName).TimeZone_Name__c;
            }
        }
        return null;
    }
    
    private static Datetime getDatetime(String DatetimeUTCString, String timezone){        
        
        String actualStartDate =  DatetimeUTCString;
        String sd1 = actualStartDate.replace('T',' ');
        sd1 = sd1.replace('Z','');
        DateTime customerDateTime = DateTime.valueof(sd1);
        
        String Date1 = sd1.split(' ')[0];
        Date myDate = Date.ValueOf(Date1);
        String Time1 = sd1.split(' ')[1];
        Time myTime = Time.newInstance(Integer.ValueOf(Time1.split(':')[0]), Integer.ValueOf(Time1.split(':')[1]), Integer.ValueOf((Time1.split(':')[2]).substringBefore('.')), 0);
        
        DateTime dt = DateTime.newInstanceGMT(myDate, myTime);
        return dt;
    }
    
    // Method to get the Pricebook based on the Account --- Added by Nilesh Bharti
    private static String updatePricebook(String acc){
        PriceBook2 pb;
        if(acc == 'Citi'){
            //pb = [SELECT Id FROM Pricebook2 where name like 'Citi OEConnect 15% Discounted Against Deposit Price Book']; //OEP-10832 new pricebook --> OEP-12049 Changed Pricebook
            pb = [SELECT Id FROM Pricebook2 where Id = '01sEa000001V2L7IAK']; //OEP-12048
            //pb = [SELECT Id FROM Pricebook2 where Id = '01sQr00000CQy4xIAD']; //OEP-12048 for prod
            return pb.Id;
        } else if(acc == 'RBC Capital Markets LLC'){ //OEP-14046
            pb = [SELECT Id FROM Pricebook2 where Id = '01s1L00000222DBQAY']; //OEP-16789
            return pb.Id;
        } else if(acc == 'Barclays'){ //OEP-18821
            pb = [SELECT Id FROM Pricebook2 where Id = '01s3w000001hXAoAAM'];
            return pb.Id;
        } else{
            //pb = [SELECT Id FROM Pricebook2 where name like 'Citi OEConnect Discounted 2023 Only Price Book'];
            pb = [SELECT Id FROM Pricebook2 where Id = '01s8X0000026vX2QAI']; //OEP-12048
            return pb.Id;
        }
    }
    
    private static Id updateRequestContact(OrderServiceHelper oHelper){
        
        Boolean rowFound = false;
        Boolean emailFound = false;
        Boolean lastNameFound = false;
        Boolean firstNameFound = false;
        Contact existingCon;
        String lastNameString;
        String firsttNameString;
        String emailqString;
        
        if (oHelper.RequesterContact != null){
            String queryString = 'select id, FirstName, LastName from Contact where ';
            System.debug('oHelper.RequesterContact.FirstName ------------->>'+oHelper.RequesterContact.FirstName);
            if(String.isNotBlank(oHelper.RequesterContact.FirstName)){
                firsttNameString = 'FirstName = \'' + oHelper.RequesterContact.FirstName ;
                firstNameFound = true;
            }
            System.debug('oHelper.RequesterContact.LastName--------------->>'+oHelper.RequesterContact.LastName);
            if(String.isNotBlank(oHelper.RequesterContact.LastName)){
                lastNameString  = 'LastName = \'' + oHelper.RequesterContact.LastName ;
                lastNameFound = true;
            }
            if(String.isNotBlank(oHelper.RequesterContact.User)){
                System.debug('User is Not Blank');
                emailqString = 'email = \''+ oHelper.RequesterContact.User;
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
                
                if (rowFound){
                    existingCon.FirstName = oHelper.RequesterContact.FirstName;
                    existingCon.LastName = oHelper.RequesterContact.LastName;
                    update existingCon;
                    return existingCon.Id;
                }else{
                    Contact con = new Contact();
                    con.FirstName = oHelper.RequesterContact.FirstName;
                    con.LastName = oHelper.RequesterContact.LastName;
                    con.email = oHelper.RequesterContact.User;
                    con.Contact_Status__c = 'Current';
                    con.Job_Function__c= 'Business';
                    con.AccountId = oHelper.Account;
                    
                    insert con;
                    return con.Id;
                }
                
            }else if (firstNameFound && lastNameFound) {
                queryString =+ queryString + firsttNameString + '\' and '+ lastNameString + '\' Limit 1';
                System.debug('queryString LastName and FirstName ------------->>'+queryString);
                try{
                    existingCon = Database.query(queryString);
                    rowFound = true;
                }catch(System.QueryException qe){
                    // Swallow the exception and create a default Contact for this Order
                }
                
                if(rowFound){
                    System.debug('---------->5002');
                    return existingCon.Id;
                }else{
                    System.debug('---------->5003');
                    Contact con = new Contact();
                    con.FirstName = oHelper.RequesterContact.FirstName;
                    con.LastName = oHelper.RequesterContact.LastName;
                    con.Contact_Status__c = 'Current';
                    con.Job_Function__c = 'Business';
                    con.AccountId = oHelper.Account;
                    
                    insert con;
                    return con.Id;
                }
            }
        }
        
        Contact contact = [SELECT Id FROM Contact WHERE LastName = 'Placeholder' AND FirstName = 'Event Requester' AND Account.Name = 'Citi'  Limit 1];
        return contact.Id;
    }
}