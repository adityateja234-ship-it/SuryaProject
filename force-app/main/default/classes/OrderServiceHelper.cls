// ************************************************************ //
// 
//  Developed by Wavelabs Technologies
//  Developer Name : Raju Cherukuri
//  Created on : 05/04/2021
//  Last Modified on : 05/11/2021
//  Description :
//  This is a helper class which converts JSON object to Apex object
//
//  JIRA:
//
// ************************************************************ //

public class OrderServiceHelper {

    public String Account {get;set;} 
    public String Contact {get;set;} 
    public String MeetingComplexity {get;set;} 
    public String Status {get;set;}  
    public String OrderEnteredDate {get;set;} 
    public String EventName {get;set;} 
    public String EventType {get;set;} 
    public String OrderCurrency {get;set;} 
    public String StartDate {get;set;}     
    public String EndDate {get;set;} 
    public String Description {get;set;} 
    public String EventNotes {get;set;}  
    public String TimeZone {get;set;} 
    public String Region {get;set;} 
    public String OrderId {get;set;} 
    public String OECentralURL {get;set;}
    public String EventId {get;set;} 
    public String ExternalEventId {get;set;} 
    
    public RequesterContact RequesterContact {get;set;} 
        
    public OrderServiceHelper(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'Account') {
                        Account = parser.getText();
                    } else if (text == 'Contact') {
                        Contact = parser.getText();
                    } else if (text == 'MeetingComplexity') {
                        MeetingComplexity = parser.getText();
                    } else if (text == 'Status') {
                        Status = parser.getText();
                    } else if (text == 'OrderEnteredDate') {
                        OrderEnteredDate = parser.getText();
                    } else if (text == 'EventName') {
                        EventName = parser.getText();
                    } else if (text == 'EventType') {
                        EventType = parser.getText();
                    } else if (text == 'OrderCurrency') {
                        OrderCurrency = parser.getText();
                    } else if (text == 'StartDate') {
                        StartDate = parser.getText();
                    } else if (text == 'EndDate') {
                        EndDate = parser.getText();
                    } else if (text == 'Description') {
                        Description = parser.getText();
                    } else if (text == 'EventNotes') {
                        EventNotes = parser.getText();
                    } else if (text == 'TimeZone') {
                        TimeZone = parser.getText();
                    } else if (text == 'Region') {
                        Region = parser.getText();
                    } else if (text == 'OrderId') {
                        OrderId = parser.getText();
                    } else if (text == 'OECentralURL') {
                        OECentralURL = parser.getText();
                    } else if (text == 'EventId') {
                        EventId = parser.getText();
                    } else if (text == 'ExternalEventId') {
                        ExternalEventId = parser.getText();
                    } else if (text == 'RequesterContact') {
                        RequesterContact = new RequesterContact(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'OrderServiceHelper consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class RequesterContact {
        public String FirstName {get;set;} 
        public String LastName {get;set;} 
        public String User {get;set;} 

        public RequesterContact(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'FirstName') {
                            FirstName = parser.getText();
                        } else if (text == 'LastName') {
                            LastName = parser.getText();
                        } else if (text == 'User') {
                            User = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'RequesterContact consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    public static OrderServiceHelper parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new OrderServiceHelper(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
    public void helper(){
    
         
         System.debug(' Helper------------->> Account = '+ Account
         +'-Contact = '+Contact
         +'-MeetingComplexity = '+MeetingComplexity
         +'-Status = '+Status
         +'-OrderEnteredDate ='+ OrderEnteredDate
         +'-EventName = '+EventName
         +'-EventType = '+ EventType
         +'-OrderCurrency = '+OrderCurrency
         +'-StartDate = '+StartDate
         +'-EndDate = '+EndDate
         +'-Description = '+Description
         +'-EventNotes = '+EventNotes
         +'-TimeZone = '+TimeZone
         +'-Region = '+Region
         +'-OrderId = '+OrderId);
    
    }

}