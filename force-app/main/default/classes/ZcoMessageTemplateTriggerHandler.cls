public with sharing class ZcoMessageTemplateTriggerHandler {
    public static void beforeUpdate(
        List<Message_Template__c> newTemplates,
        Map<Id, Message_Template__c> oldTemplates
    ) {
        for (Message_Template__c template : newTemplates) {
            Message_Template__c oldTemplate = oldTemplates.get(template.Id);
            if (template.Template_Body__c != oldTemplate.Template_Body__c) {
                template.Active__c = false;
                template.Medical_Approved__c = false;
                template.Legal_Approved__c = false;
                template.Approved_On__c = null;
            }
        }
    }
}
