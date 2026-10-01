public with sharing class ZcoCareDashboardController {
    public class DashboardData {
        @AuraEnabled public Integer total { get; set; }
        @AuraEnabled public Integer due { get; set; }
        @AuraEnabled public Integer outreachSent { get; set; }
        @AuraEnabled public Integer snoozed { get; set; }
        @AuraEnabled public Integer lostToFollowUp { get; set; }
        @AuraEnabled public List<JourneyRow> journeys { get; set; }
    }

    public class JourneyRow {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public Id patientId { get; set; }
        @AuraEnabled public String patientName { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public Date nextDueDate { get; set; }
        @AuraEnabled public Integer attempts { get; set; }
        @AuraEnabled public Datetime lastOutreachAt { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static DashboardData getDashboard() {
        List<Care_Journey__c> records = [
            SELECT Id, Name, Patient__c, Patient__r.Name, Status__c, Next_Due_Date__c,
                Attempts__c, Last_Outreach_At__c
            FROM Care_Journey__c
            WHERE Status__c != 'Completed'
            WITH USER_MODE
            ORDER BY Next_Due_Date__c ASC NULLS LAST, Last_Outreach_At__c ASC NULLS FIRST
            LIMIT 200
        ];
        return buildDashboard(records);
    }

    @TestVisible
    private static DashboardData buildDashboard(List<Care_Journey__c> records) {
        DashboardData data = new DashboardData();
        data.total = 0;
        data.due = 0;
        data.outreachSent = 0;
        data.snoozed = 0;
        data.lostToFollowUp = 0;
        data.journeys = new List<JourneyRow>();

        if (records == null) {
            return data;
        }

        for (Care_Journey__c journey : records) {
            if (journey == null) {
                continue;
            }
            data.total++;
            if (journey.Status__c == 'Due') {
                data.due++;
            } else if (journey.Status__c == 'Outreach sent') {
                data.outreachSent++;
            } else if (journey.Status__c == 'Snoozed') {
                data.snoozed++;
            } else if (journey.Status__c == 'Lost to follow-up') {
                data.lostToFollowUp++;
            }

            JourneyRow row = new JourneyRow();
            row.id = journey.Id;
            row.name = journey.Name;
            row.patientId = journey.Patient__c;
            row.patientName = journey.Patient__r == null ? null : journey.Patient__r.Name;
            row.status = journey.Status__c;
            row.nextDueDate = journey.Next_Due_Date__c;
            row.attempts = journey.Attempts__c == null ? 0 : journey.Attempts__c.intValue();
            row.lastOutreachAt = journey.Last_Outreach_At__c;
            data.journeys.add(row);
        }
        return data;
    }
}
