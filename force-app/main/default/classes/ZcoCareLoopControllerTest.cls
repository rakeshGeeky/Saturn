@IsTest
private class ZcoCareLoopControllerTest {
    @IsTest
    static void testGetAccountPatientCard() {
        Account patient = new Account(Name = 'Patient One', HIS_MRN__c = 'MRN-1001');
        insert patient;

        Care_Journey__c journey = new Care_Journey__c(
            Patient__c = patient.Id,
            Status__c = 'Care plan active',
            Next_Due_Date__c = Date.today().addDays(3),
            Last_Consult_Date__c = Date.today().addDays(-2)
        );
        insert journey;

        ZcoCareLoopController.PatientCard card = ZcoCareLoopController.getAccountPatientCard(patient.Id);
        System.assertEquals(patient.Id, card.accountId);
        System.assertEquals('Patient One', card.patientName);
        System.assertEquals('MRN-1001', card.mrn);
        System.assertEquals('Care plan active', card.journeyStatus);

        ZcoCareLoopController.PatientCard accountContextCard =
            ZcoCareLoopController.getCareJourneyCard(patient.Id);
        System.assertEquals(patient.Id, accountContextCard.accountId);
        System.assertEquals('Care plan active', accountContextCard.journeyStatus);

        ZcoCareLoopController.PatientCard journeyContextCard =
            ZcoCareLoopController.getCareJourneyCard(journey.Id);
        System.assertEquals(patient.Id, journeyContextCard.accountId);
        System.assertEquals('Care plan active', journeyContextCard.journeyStatus);
    }
}
