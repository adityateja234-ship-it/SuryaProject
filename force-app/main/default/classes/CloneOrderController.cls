public class CloneOrderController {
@AuraEnabled
    public static Order getOrderDetails(String orderId){
        return [
            SELECT Id,RecordTypeId, ContractId, AccountId, Type, EffectiveDate, Status, CustomerAuthorizedById, BillingAddress, CompanyAuthorizedById, ShippingAddress, Description, Veracast_Conference_ID__c FROM Order WHERE Id =: orderId
            ];
        }
}