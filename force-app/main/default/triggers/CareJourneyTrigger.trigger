trigger CareJourneyTrigger on Care_Journey__c (before update) {
    ZcoCareJourneyTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
}