public with sharing class ZcoCareLoopController {
    public class PatientCard {
        @AuraEnabled public Id accountId { get; set; }
        @AuraEnabled public String patientName { get; set; }
        @AuraEnabled public String mrn { get; set; }
        @AuraEnabled public Date lastConsultDate { get; set; }
        @AuraEnabled public Date nextDueDate { get; set; }
        @AuraEnabled public String journeyStatus { get; set; }
        @AuraEnabled public Integer openSafetyCases { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static PatientCard getAccountPatientCard(Id accountId) {
        if (accountId == null) {
            return null;
        }

        PatientCard card = new PatientCard();
        card.accountId = accountId;

        Account patient = [
            SELECT Id, Name, HIS_MRN__c
            FROM Account
            WHERE Id = :accountId
            WITH USER_MODE
            LIMIT 1
        ];

        card.patientName = patient.Name;
        card.mrn = patient.HIS_MRN__c;

        List<Care_Journey__c> journeys = [
            SELECT Id, Status__c, Next_Due_Date__c, Last_Consult_Date__c
            FROM Care_Journey__c
            WHERE Patient__c = :accountId
            ORDER BY Last_Consult_Date__c DESC NULLS LAST, LastModifiedDate DESC
            LIMIT 1
        ];

        if (!journeys.isEmpty()) {
            Care_Journey__c journey = journeys[0];
            card.nextDueDate = journey.Next_Due_Date__c;
            card.journeyStatus = journey.Status__c;
            card.lastConsultDate = journey.Last_Consult_Date__c;
        }

        card.openSafetyCases = [
            SELECT COUNT()
            FROM Case
            WHERE AccountId = :accountId AND Status != 'Closed'
            WITH USER_MODE
        ];

        return card;
    }

    @AuraEnabled(cacheable=true)
    public static PatientCard getCareJourneyCard(Id journeyId) {
        if (journeyId == null) {
            return null;
        }

        Care_Journey__c journey = [
            SELECT Id, Status__c, Next_Due_Date__c, Last_Consult_Date__c, Patient__c
            FROM Care_Journey__c
            WHERE Id = :journeyId
            WITH USER_MODE
            LIMIT 1
        ];

        if (journey == null) {
            return null;
        }

        Account patient = [
            SELECT Id, Name, HIS_MRN__c
            FROM Account
            WHERE Id = :journey.Patient__c
            WITH USER_MODE
            LIMIT 1
        ];

        PatientCard card = new PatientCard();
        card.accountId = patient.Id;
        card.patientName = patient.Name;
        card.mrn = patient.HIS_MRN__c;
        card.nextDueDate = journey.Next_Due_Date__c;
        card.journeyStatus = journey.Status__c;
        card.lastConsultDate = journey.Last_Consult_Date__c;
        card.openSafetyCases = [
            SELECT COUNT()
            FROM Case
            WHERE AccountId = :patient.Id AND Status != 'Closed'
            WITH USER_MODE
        ];

        return card;
    }
}
