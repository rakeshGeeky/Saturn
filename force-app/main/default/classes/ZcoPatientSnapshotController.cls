public with sharing class ZcoPatientSnapshotController {
    public class SnapshotData {
        @AuraEnabled public List<ObservationRow> observations { get; set; }
        @AuraEnabled public List<MedicationRow> medications { get; set; }
    }

    public class ObservationRow {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public Decimal value { get; set; }
        @AuraEnabled public String unit { get; set; }
        @AuraEnabled public Date recordedDate { get; set; }
        @AuraEnabled public String source { get; set; }
        @AuraEnabled public Boolean outsideThreshold { get; set; }
    }

    public class MedicationRow {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String drugName { get; set; }
        @AuraEnabled public String dosage { get; set; }
        @AuraEnabled public String frequency { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static SnapshotData getSnapshot(Id accountId) {
        if (accountId == null) {
            throw new AuraHandledException('Open a patient account to view the clinical snapshot.');
        }

        List<Clinical_Observation__c> observations = [
            SELECT Id, Type__c, Value__c, Unit__c, Recorded_Date__c, Source__c, Outside_Threshold__c
            FROM Clinical_Observation__c
            WHERE Patient__c = :accountId AND Verified__c = true
            WITH USER_MODE
            ORDER BY Recorded_Date__c DESC
            LIMIT 10
        ];
        List<Medication_Statement__c> medications = [
            SELECT Id, Drug_Name__c, Dosage__c, Frequency__c
            FROM Medication_Statement__c
            WHERE Patient__c = :accountId AND Status__c = 'Current' AND Verified__c = true
            WITH USER_MODE
            ORDER BY LastModifiedDate DESC
            LIMIT 10
        ];
        return buildSnapshot(observations, medications);
    }

    @TestVisible
    private static SnapshotData buildSnapshot(
        List<Clinical_Observation__c> observations,
        List<Medication_Statement__c> medications
    ) {
        SnapshotData data = new SnapshotData();
        data.observations = new List<ObservationRow>();
        data.medications = new List<MedicationRow>();

        if (observations != null) {
            for (Clinical_Observation__c observation : observations) {
                if (observation == null) {
                    continue;
                }
                ObservationRow row = new ObservationRow();
                row.id = observation.Id;
                row.type = observation.Type__c;
                row.value = observation.Value__c;
                row.unit = observation.Unit__c;
                row.recordedDate = observation.Recorded_Date__c;
                row.source = observation.Source__c;
                row.outsideThreshold = observation.Outside_Threshold__c;
                data.observations.add(row);
            }
        }

        if (medications != null) {
            for (Medication_Statement__c medication : medications) {
                if (medication == null) {
                    continue;
                }
                MedicationRow row = new MedicationRow();
                row.id = medication.Id;
                row.drugName = medication.Drug_Name__c;
                row.dosage = medication.Dosage__c;
                row.frequency = medication.Frequency__c;
                data.medications.add(row);
            }
        }
        return data;
    }
}
