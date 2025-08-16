@isTest(SeeAllData=true)
public class RHX_TEST_Monday_com_Products {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Monday_com_Products__c ORDER BY LastModifiedDate DESC LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Monday_com_Products__c()
            );
        }
    	

       rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}