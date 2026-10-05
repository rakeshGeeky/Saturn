trigger MessageTemplateTrigger on Message_Template__c (before update) {
    ZcoMessageTemplateTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
}