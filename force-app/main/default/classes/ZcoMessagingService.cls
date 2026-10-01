public with sharing class ZcoMessagingService {
    public static void sendTemplate(Id patientId, String templateKey, Map<String, String> variables) {
        if (patientId == null || String.isBlank(templateKey)) {
            return;
        }

        WhatsApp_Message__c msg = new WhatsApp_Message__c(
            Patient__c = patientId,
            Direction__c = 'Outbound',
            Status__c = 'Queued',
            Message_Body__c = templateKey + ' ' + JSON.serialize(variables)
        );
        insert msg;
    }
}
