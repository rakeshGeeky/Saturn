@IsTest
private class ZcoPreConsultSummaryControllerTest {
    @IsTest
    static void testSummaryReturnsData() {
        Account patient = new Account(Name = 'Summary Patient');
        insert patient;

        Care_Journey__c journey = new Care_Journey__c(
            Patient__c = patient.Id,
            Status__c = 'Care plan active',
            Next_Due_Date__c = Date.today().addDays(4)
        );
        insert journey;

        Medication_Statement__c medication = new Medication_Statement__c(
            Patient__c = patient.Id,
            Drug_Name__c = 'Metformin',
            Status__c = 'Current',
            Verified__c = true
        );
        insert medication;

        ZcoPreConsultSummaryController.SummaryData summary = ZcoPreConsultSummaryController.getSummary(patient.Id);
        System.assertEquals('Summary Patient', summary.patientName);
        System.assertEquals('Care plan active', summary.carePlanStatus);
        System.assert(summary.verifiedMedicationNames.contains('Metformin'));
    }
}
