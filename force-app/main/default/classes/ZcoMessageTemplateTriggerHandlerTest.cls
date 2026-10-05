@IsTest
private class ZcoMessageTemplateTriggerHandlerTest {
    @IsTest
    static void bodyChangeInvalidatesApproval() {
        System.runAs(createAdminUser()) {
        Message_Template__c template = new Message_Template__c(
            Name = 'Body Change Test',
            Template_Key__c = 'BODY_CHANGE_TEST',
            Category__c = 'Utility',
            Channel__c = 'WhatsApp',
            Language__c = 'English',
            Meta_Category__c = 'Utility',
            Template_Body__c = 'Initial content',
            Active__c = true,
            Medical_Approved__c = true,
            Legal_Approved__c = true
        );
        insert template;

        template.Template_Body__c = 'Updated content';
        update template;

        template = [
            SELECT Active__c, Medical_Approved__c, Legal_Approved__c, Approved_On__c
            FROM Message_Template__c
            WHERE Id = :template.Id
        ];
        System.assertEquals(false, template.Active__c);
        System.assertEquals(false, template.Medical_Approved__c);
        System.assertEquals(false, template.Legal_Approved__c);
        System.assertEquals(null, template.Approved_On__c);
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
            Email = 'zco-template-test-' + uniqueId + '@example.invalid',
            EmailEncodingKey = 'UTF-8',
            LastName = 'ZCO Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = administrator.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'zco-template-test-' + uniqueId + '@example.invalid'
        );
        insert userRecord;
        PermissionSet corePermissions = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'PS_Zco_Core'
            LIMIT 1
        ];
        insert new PermissionSetAssignment(
            AssigneeId = userRecord.Id,
            PermissionSetId = corePermissions.Id
        );
        return userRecord;
    }
}
