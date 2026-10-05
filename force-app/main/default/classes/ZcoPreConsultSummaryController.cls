public with sharing class ZcoPreConsultSummaryController {
    public class SummaryData {
        @AuraEnabled public Id patientId { get; set; }
        @AuraEnabled public String patientName { get; set; }
        @AuraEnabled public String carePlanStatus { get; set; }
        @AuraEnabled public String nextDueDate { get; set; }
        @AuraEnabled public List<String> verifiedMedicationNames { get; set; }
        @AuraEnabled public List<String> recentObservationLabels { get; set; }
        @AuraEnabled public List<String> eligibilityOutcomes { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static SummaryData getSummary(Id recordId) {
        if (recordId == null) {
            return null;
        }

        Id patientId;
        if (recordId.getSObjectType() == Account.SObjectType) {
            patientId = recordId;
        } else if (recordId.getSObjectType() == Patient_Intake__c.SObjectType) {
            List<Patient_Intake__c> intakes = [
                SELECT Patient__c
                FROM Patient_Intake__c
                WHERE Id = :recordId
                WITH USER_MODE
                LIMIT 1
            ];
            if (intakes.isEmpty()) {
                return null;
            }
            patientId = intakes[0].Patient__c;
        } else if (recordId.getSObjectType() == Appointment__c.SObjectType) {
            List<Appointment__c> appointments = [
                SELECT Patient__c
                FROM Appointment__c
                WHERE Id = :recordId
                WITH USER_MODE
                LIMIT 1
            ];
            if (appointments.isEmpty()) {
                return null;
            }
            patientId = appointments[0].Patient__c;
        } else {
            return null;
        }
        if (patientId == null) {
            return null;
        }

        Account patient = [
            SELECT Id, Name
            FROM Account
            WHERE Id = :patientId
            WITH USER_MODE
            LIMIT 1
        ];

        SummaryData data = new SummaryData();
        data.patientId = patient.Id;
        data.patientName = patient.Name;

        List<Care_Journey__c> journeys = [
            SELECT Id, Status__c, Next_Due_Date__c
            FROM Care_Journey__c
            WHERE Patient__c = :patientId
            WITH USER_MODE
            ORDER BY Last_Consult_Date__c DESC NULLS LAST, LastModifiedDate DESC
            LIMIT 1
        ];

        if (!journeys.isEmpty()) {
            data.carePlanStatus = journeys[0].Status__c;
            data.nextDueDate = journeys[0].Next_Due_Date__c == null ? 'Not scheduled' : String.valueOf(journeys[0].Next_Due_Date__c);
        }

        List<Medication_Statement__c> meds = [
            SELECT Id, Drug_Name__c
            FROM Medication_Statement__c
            WHERE Patient__c = :patientId AND Verified__c = true AND Status__c = 'Current'
            WITH USER_MODE
            ORDER BY LastModifiedDate DESC
            LIMIT 5
        ];
        data.verifiedMedicationNames = new List<String>();
        for (Medication_Statement__c med : meds) {
            data.verifiedMedicationNames.add(med.Drug_Name__c);
        }

        List<Clinical_Observation__c> obs = [
            SELECT Id, Type__c, Value__c, Unit__c, Recorded_Date__c
            FROM Clinical_Observation__c
            WHERE Patient__c = :patientId AND Verified__c = true
            WITH USER_MODE
            ORDER BY Recorded_Date__c DESC
            LIMIT 5
        ];
        data.recentObservationLabels = new List<String>();
        for (Clinical_Observation__c obsRow : obs) {
            data.recentObservationLabels.add(String.valueOf(obsRow.Type__c) + ': ' + String.valueOf(obsRow.Value__c) + ' ' + String.valueOf(obsRow.Unit__c));
        }

        data.eligibilityOutcomes = new List<String>();
        List<ZcoEligibilityService.RuleMatch> matches = ZcoEligibilityService.evaluateRecord(patient);
        for (ZcoEligibilityService.RuleMatch match : matches) {
            if (!String.isBlank(match.outcome)) {
                data.eligibilityOutcomes.add(match.outcome);
            }
        }

        return data;
    }
}