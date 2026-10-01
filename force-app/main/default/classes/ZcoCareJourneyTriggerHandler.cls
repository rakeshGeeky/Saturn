public with sharing class ZcoCareJourneyTriggerHandler {
    public static void beforeUpdate(List<Care_Journey__c> journeys, Map<Id, Care_Journey__c> priorJourneys) {
        ZcoCareJourneyService.validateTransitions(journeys, priorJourneys);
    }
}
