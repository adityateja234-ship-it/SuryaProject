/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Monday_com_ProductsTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Monday_com_ProductsTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Monday_com_Products__c());
    }
}