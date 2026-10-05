@IsTest
private class ZcoSendTemplateMessageActionTest {
    @IsTest
    static void testSendTemplateMessageInsertsWhatsAppMessage() {
        Account patient = new Account(Name = 'Template Patient');
        insert patient;

        ZcoSendTemplateMessageAction.SendTemplateRequest req = new ZcoSendTemplateMessageAction.SendTemplateRequest();
        req.patientId = patient.Id;
        req.templateKey = 'WELCOME';
        req.variablesJson = '{"name":"Patient"}';

        Test.startTest();
        ZcoSendTemplateMessageAction.sendTemplateMessage(new List<ZcoSendTemplateMessageAction.SendTemplateRequest>{ req });
        Test.stopTest();

        List<WhatsApp_Message__c> messages = [SELECT Id, Patient__c FROM WhatsApp_Message__c WHERE Patient__c = :patient.Id];
        System.assertEquals(1, messages.size());
    }
}
