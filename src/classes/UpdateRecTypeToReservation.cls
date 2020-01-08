public class UpdateRecTypeToReservation {
    @AuraEnabled
    public static void updateRecordType(Id recordId) {
        Id resRTId = Schema.SObjectType.Reservation__c.getRecordTypeInfosByName().get('Reservation').getRecordTypeId();
        Reservation__c cs = new Reservation__c();
        cs.Id = recordId;
        cs.RecordTypeId = resRTId;
        try {
            update cs;
        }
        catch (Exception e) {
            throw new AuraHandledException('Something went wrong: '+ e.getMessage());    
        }
    }
}