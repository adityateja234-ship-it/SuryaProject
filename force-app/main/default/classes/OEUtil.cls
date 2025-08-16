/*
** ____________________________________________________________________________________________
** Created By:    RAJU CHERUKURI Salesforce Architect (raju.cherukuri@openexc.com)
** Created Date:  17.05.2021
** Description : This is a Utility class helps Apex classes by defining a common functionality
** ____________________________________________________________________________________________
*/
public with sharing class OEUtil {

    public static Boolean isSandbox = null;
    
    public static Boolean runningInASandbox() {
        if (isSandbox == null) isSandbox = [SELECT Id,isSandbox FROM Organization LIMIT 1].isSandbox;
        return isSandbox;
    }
}