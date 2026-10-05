@IsTest
private class ZcoCareJourneyTriggerHandlerTest {
    @IsTest
    static void allowsWorkbookTransitionsAndRejectsInvalidTransitions() {
        System.runAs(createAdminUser()) {
        Account patient = new Account(Name = 'Journey State Patient');
        insert patient;

        Journey_Template__c template = new Journey_Template__c(
            Name = 'Journey State Template',
            Active__c = true,
            Interval_Days__c = 30
        );
        insert template;

        Care_Journey__c journey = new Care_Journey__c(
            Patient__c = patient.Id,
            Template__c = template.Id,
            Journey_Type__c = 'Diabetes program',
            State__c = 'Care plan active'
        );
        insert journey;

        journey.State__c = 'Due';
        update journey;
        Care_Journey__c updatedJourney = [
            SELECT State__c, State_Changed_At__c
            FROM Care_Journey__c
            WHERE Id = :journey.Id
        ];
        System.assertEquals('Due', updatedJourney.State__c);
        System.assertNotEquals(null, updatedJourney.State_Changed_At__c);

        journey.State__c = 'Snoozed';
        Database.SaveResult invalidTransition = Database.update(journey, false);
        System.assertEquals(false, invalidTransition.isSuccess());
        System.assert(
            invalidTransition.getErrors()[0].getMessage().contains('Invalid journey transition')
        );
        }
    }

    @IsTest
    static void clearsAttemptsWhenReopenedFromLtfu() {
        System.runAs(createAdminUser()) {
        Account patient = new Account(Name = 'Reopened Journey Patient');
        insert patient;
        Journey_Template__c template = new Journey_Template__c(Name = 'Reopened Journey Template');
        insert template;
        Care_Journey__c journey = new Care_Journey__c(
            Patient__c = patient.Id,
            Template__c = template.Id,
            Journey_Type__c = 'Diabetes program',
            State__c = 'Lost to follow-up',
            Attempts__c = 3
        );
        insert journey;

       ZcoCareJourneyService.transitionToState('Care plan active', 'Due');
        journey = [SELECT State__c, Attempts__c FROM Care_Journey__c WHERE Id = :journey.Id];
        System.assertEquals('Due', journey.State__c);
        System.assertEquals(0, journey.Attempts__c);
        }
    }

    private static User createAdminUser() {
        Profile administrator = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1
        ];
        String uniqueId = String.valueOf(Datetime.now().getTime());
        User userRecord = new User(
            Alias = 'zcoTest',
            Email = 'zco-test-' + uniqueId + '@example.invalid',
            EmailEncodingKey = 'UTF-8',
            LastName = 'ZCO Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = administrator.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'zco-test-' + uniqueId + '@example.invalid'
        );
        insert userRecord;
        assignPermissionSet(userRecord.Id, 'PS_Zco_Core');
        assignPermissionSet(userRecord.Id, 'PS_Zco_Config_Admin');
        return userRecord;
    }

    private static void assignPermissionSet(Id userId, String permissionSetName) {
        PermissionSet permissionSetRecord = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = :permissionSetName
            LIMIT 1
        ];
        insert new PermissionSetAssignment(
            AssigneeId = userId,
            PermissionSetId = permissionSetRecord.Id
        );
    }
}