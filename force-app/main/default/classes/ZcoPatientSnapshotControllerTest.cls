@IsTest
private class ZcoPatientSnapshotControllerTest {
    @IsTest
    static void testSnapshotMapsClinicalRows() {
        Clinical_Observation__c observation = new Clinical_Observation__c(
            Type__c = 'HbA1c',
            Value__c = 7.2,
            Unit__c = '%',
            Recorded_Date__c = Date.today(),
            Source__c = 'Lab API',
            Outside_Threshold__c = false
        );
        Medication_Statement__c medication = new Medication_Statement__c(
            Drug_Name__c = 'Medication A',
            Dosage__c = '500 mg',
            Frequency__c = 'Twice daily'
        );

        ZcoPatientSnapshotController.SnapshotData data = ZcoPatientSnapshotController.buildSnapshot(
            new List<Clinical_Observation__c>{observation, null},
            new List<Medication_Statement__c>{medication, null}
        );
        System.assertEquals(1, data.observations.size());
        System.assertEquals('HbA1c', data.observations[0].type);
        System.assertEquals(7.2, data.observations[0].value);
        System.assertEquals('%', data.observations[0].unit);
        System.assertEquals(false, data.observations[0].outsideThreshold);
        System.assertEquals(1, data.medications.size());
        System.assertEquals('Medication A', data.medications[0].drugName);
        System.assertEquals('Twice daily', data.medications[0].frequency);

        ZcoPatientSnapshotController.SnapshotData emptyData =
            ZcoPatientSnapshotController.buildSnapshot(null, null);
        System.assertEquals(0, emptyData.observations.size());
        System.assertEquals(0, emptyData.medications.size());
    }
}