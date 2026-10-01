public with sharing class ZcoJourneyDueBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Status__c, Next_Due_Date__c, Attempts__c, Snooze_Until__c
            FROM Care_Journey__c
            WHERE Status__c IN ('Care plan active', 'Due', 'Outreach sent', 'Snoozed')
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Care_Journey__c> journeys) {
        for (Care_Journey__c journey : journeys) {
            if (journey.Next_Due_Date__c != null && journey.Next_Due_Date__c <= Date.today()) {
                journey.Status__c = 'Due';
            }
        }
        update journeys;
    }

    public void finish(Database.BatchableContext bc) {
    }
}
