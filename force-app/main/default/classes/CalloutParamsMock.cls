@isTest
public class CalloutParamsMock {
    public static void setupMockParams() {
        // Mock implementation to provide the required parameters for callouts
        CalloutData__c mockCalloutData = new CalloutData__c(
            AuthenticationURL__c = 'https://mock-auth-url',
            EndPointURL__c = 'https://mock-endpoint-url',
            UserName__c = 'mockUser',
            UserPassword__c = 'mockPassword',
            AccountId__c = 'mockAccountId'
        );
        insert mockCalloutData;
    }
}