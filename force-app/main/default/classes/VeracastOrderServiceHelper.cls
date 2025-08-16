// ************************************************************ //
// 
//  Developed by Wavelabs Technologies
//  Developer Name : Raju Cherukuri
//  Created on : 04/12/2021
//  Last Modified on : 04/12/2021
//  Description :
//  This is a helper class which converts JSON object to Apex object
//
//  JIRA:
//
// ************************************************************ //

public class VeracastOrderServiceHelper {

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
    public String VeracastConferenceID {get;set;} 
    public String VeracastEventID {get;set;}
    public RequesterContact RequesterContact {get;set;}  
    public List<RequesterContact> ProjectManager {get;set;} 
    public VeracastOrderServiceHelper(JSONParser parser) {
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
                    } else if (text == 'VeracastConferenceID') {
                        VeracastConferenceID = parser.getText();
                    } else if (text == 'VeracastEventID') {
                        VeracastEventID = parser.getText();
                    } else if (text == 'RequesterContact') {
                        RequesterContact = new RequesterContact(parser);
                    } else if (text == 'ProjectManager') {
                        ProjectManager = arrayOfRequesterContact(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'VeracastOrderServiceHelper consuming unrecognized property: '+text);
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
    /*
    public class ProjectManagers {
        public String FirstName {get;set;} 
        public String LastName {get;set;} 
        public String User {get;set;} 

        public ProjectManagers(JSONParser parser) {
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
                            System.debug(LoggingLevel.WARN, 'ProjectManager consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    } */
    public static VeracastOrderServiceHelper parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new VeracastOrderServiceHelper(parser);
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
    
    private static List<RequesterContact> arrayOfRequesterContact(System.JSONParser p) {
        List<RequesterContact> res = new List<RequesterContact>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new RequesterContact(p));
        }
        return res;
    }
    
    /*
    private static List<ProjectManagers> arrayOfProjectManagers(System.JSONParser p) {
        List<ProjectManagers> prs = new List<ProjectManagers>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            prs.add(new ProjectManagers(p));
        }
        return prs;
    }*/

}