public with sharing class ZcoMessagingService {
    public static void sendTemplate(Id patientId, String templateKey, Map<String, String> variables) {
        WhatsApp_Message__c message = buildMessage(patientId, templateKey, variables);
        if (message != null) {
            insert message;
        }
    }

    @TestVisible
    private static WhatsApp_Message__c buildMessage(Id patientId, String templateKey, Map<String, String> variables) {
        if (patientId == null || String.isBlank(templateKey)) {
            return null;
        }
        return new WhatsApp_Message__c(
            Patient__c = patientId,
            Direction__c = 'Outbound',
            Status__c = 'Queued',
            Message_Body__c = templateKey + ' ' + JSON.serialize(variables)
        );
    }
}
