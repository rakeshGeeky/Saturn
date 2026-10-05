public with sharing class ZcoJourneyDueBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Status__c, Next_Due_Date__c, Attempts__c, Snooze_Until__c,
                Last_Outreach_At__c, Journey_Template__r.Max_Attempts__c,
                Journey_Template__r.Attempt_Gap_Days__c, Journey_Template__r.LTFU_After_Days__c
            FROM Care_Journey__c
            WHERE Status__c IN ('Care plan active', 'Due', 'Outreach sent', 'Snoozed')
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Care_Journey__c> journeys) {
        if (journeys == null || journeys.isEmpty()) {
            return;
        }

        Set<Id> journeyIds = new Set<Id>();
        for (Care_Journey__c journey : journeys) {
            if (journey.Id != null) {
                journeyIds.add(journey.Id);
            }
        }
        Set<Id> journeysWithFutureAppointments = new Set<Id>();
        if (!journeyIds.isEmpty()) {
            for (Appointment__c appointment : [
                SELECT Care_Journey__c
                FROM Appointment__c
                WHERE Care_Journey__c IN :journeyIds
                    AND Status__c IN ('Scheduled', 'Confirmed')
                    AND Scheduled_Start__c > :System.now()
            ]) {
                journeysWithFutureAppointments.add(appointment.Care_Journey__c);
            }
        }

        List<Care_Journey__c> changedJourneys = evaluateJourneys(journeys, journeysWithFutureAppointments, Date.today());
        if (!changedJourneys.isEmpty()) {
            update changedJourneys;
        }
    }

    @TestVisible
    private static List<Care_Journey__c> evaluateJourneys(
        List<Care_Journey__c> journeys,
        Set<Id> journeysWithFutureAppointments,
        Date today
    ) {
        List<Care_Journey__c> changedJourneys = new List<Care_Journey__c>();
        if (journeys == null || journeysWithFutureAppointments == null || today == null) {
            return changedJourneys;
        }

        for (Care_Journey__c journey : journeys) {
            if (journey == null || journeysWithFutureAppointments.contains(journey.Id)) {
                continue;
            }

            String priorStatus = journey.Status__c;
            Integer attempts = journey.Attempts__c == null ? 0 : journey.Attempts__c.intValue();
            Integer maxAttempts = journey.Journey_Template__r == null ||
                journey.Journey_Template__r.Max_Attempts__c == null ||
                journey.Journey_Template__r.Max_Attempts__c < 1
                ? 3
                : journey.Journey_Template__r.Max_Attempts__c.intValue();
            Integer ltfuAfterDays = journey.Journey_Template__r == null ||
                journey.Journey_Template__r.LTFU_After_Days__c == null
                ? 0
                : journey.Journey_Template__r.LTFU_After_Days__c.intValue();

            Boolean exceededLtfuWindow = journey.Next_Due_Date__c != null &&
                ltfuAfterDays > 0 &&
                today > journey.Next_Due_Date__c.addDays(ltfuAfterDays);
            if (attempts >= maxAttempts || exceededLtfuWindow) {
                if (priorStatus != 'Lost to follow-up') {
                    journey.Status__c = 'Lost to follow-up';
                }
            } else if (priorStatus == 'Care plan active' &&
                journey.Next_Due_Date__c != null &&
                journey.Next_Due_Date__c <= today) {
                journey.Status__c = 'Due';
                journey.Attempts__c = 0;
            } else if (priorStatus == 'Snoozed' &&
                journey.Snooze_Until__c != null &&
                journey.Snooze_Until__c <= today) {
                journey.Status__c = 'Due';
            } else if (priorStatus == 'Outreach sent' &&
                journey.Last_Outreach_At__c != null &&
                journey.Journey_Template__r != null &&
                journey.Journey_Template__r.Attempt_Gap_Days__c != null &&
                journey.Journey_Template__r.Attempt_Gap_Days__c > 0 &&
                journey.Last_Outreach_At__c.date().addDays(
                    journey.Journey_Template__r.Attempt_Gap_Days__c.intValue()
                ) <= today) {
                journey.Status__c = 'Due';
            }

            if (journey.Status__c != priorStatus) {
                journey.State_Changed_At__c = Datetime.now();
                changedJourneys.add(journey);
            }
        }
        return changedJourneys;
    }

    public void finish(Database.BatchableContext bc) {
    }
}