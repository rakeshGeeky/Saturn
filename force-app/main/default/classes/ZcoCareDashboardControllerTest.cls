@IsTest
private class ZcoCareDashboardControllerTest {
    @IsTest
    static void testDashboardBuildsStatusCountsAndRows() {
        Account patient = new Account(Name = 'Dashboard Patient');
        List<Care_Journey__c> source = new List<Care_Journey__c>{
            new Care_Journey__c(
                Id = Id.valueOf(Care_Journey__c.SObjectType.getDescribe().getKeyPrefix() + '000000000001'),
                Patient__c = Id.valueOf(Account.SObjectType.getDescribe().getKeyPrefix() + '000000000001'),
                Patient__r = patient,
                Status__c = 'Due',
                Attempts__c = 2,
                Next_Due_Date__c = Date.today()
            ),
            new Care_Journey__c(
                Id = Id.valueOf(Care_Journey__c.SObjectType.getDescribe().getKeyPrefix() + '000000000002'),
                Status__c = 'Outreach sent'
            ),
            new Care_Journey__c(
                Id = Id.valueOf(Care_Journey__c.SObjectType.getDescribe().getKeyPrefix() + '000000000003'),
                Status__c = 'Snoozed'
            ),
            new Care_Journey__c(
                Id = Id.valueOf(Care_Journey__c.SObjectType.getDescribe().getKeyPrefix() + '000000000004'),
                Status__c = 'Lost to follow-up'
            ),
            null
        };

        ZcoCareDashboardController.DashboardData data =
            ZcoCareDashboardController.buildDashboard(source);
        System.assertEquals(4, data.total);
        System.assertEquals(1, data.due);
        System.assertEquals(1, data.outreachSent);
        System.assertEquals(1, data.snoozed);
        System.assertEquals(1, data.lostToFollowUp);
        System.assertEquals(4, data.journeys.size());
        System.assertEquals('Dashboard Patient', data.journeys[0].patientName);
        System.assertEquals(2, data.journeys[0].attempts);
        System.assertEquals(0, data.journeys[1].attempts);

        ZcoCareDashboardController.DashboardData emptyData =
            ZcoCareDashboardController.buildDashboard(null);
        System.assertEquals(0, emptyData.total);
        System.assertEquals(0, emptyData.journeys.size());
    }
}
