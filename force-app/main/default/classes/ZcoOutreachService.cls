public with sharing class ZcoOutreachService {
    public static Boolean isOutreachAllowed(Account patient) {
        if (patient == null) {
            return false;
        }

        if (patient.Outreach_Suppressed__c == true) {
            return false;
        }

        if (String.isBlank(patient.Patient_Status__c)) {
            return true;
        }

        Set<String> blockedStatuses = new Set<String>{
            'Inactive',
            'Deceased',
            'Opted Out',
            'Do Not Contact'
        };
        return !blockedStatuses.contains(patient.Patient_Status__c);
    }

    public static List<Care_Journey__c> queueOutgoingOutreach(List<Care_Journey__c> journeys) {
        if (journeys == null || journeys.isEmpty()) {
            return new List<Care_Journey__c>();
        }

        for (Care_Journey__c journey : journeys) {
            if (journey == null) {
                continue;
            }
            journey.Status__c = 'Outreach sent';
            journey.Last_Outreach_At__c = Datetime.now();
            if (journey.Next_Due_Date__c == null) {
                journey.Next_Due_Date__c = Date.today().addDays(7);
            }
        }
        return journeys;
    }
}
