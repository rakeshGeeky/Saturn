public with sharing class ZcoCareJourneyService {
    public static String transitionToState(String currentState, String requestedAction) {
        if (String.isBlank(currentState)) {
            return 'Care plan active';
        }
        Map<String, Set<String>> allowed = new Map<String, Set<String>>{
            'Care plan active' => new Set<String>{'Due', 'Completed'},
            'Due' => new Set<String>{'Outreach sent', 'Lost to follow-up', 'Completed'},
            'Outreach sent' => new Set<String>{'Scheduled', 'Snoozed', 'Due', 'Lost to follow-up'},
            'Snoozed' => new Set<String>{'Due', 'Completed'},
            'Lost to follow-up' => new Set<String>{'Completed'}
        };
        if (requestedAction == null) {
            return currentState;
        }
        if (allowed.containsKey(currentState) && allowed.get(currentState).contains(requestedAction)) {
            return requestedAction;
        }
        throw new IllegalArgumentException('Invalid transition from ' + currentState + ' to ' + requestedAction);
    }

    public static void startJourney(Care_Journey__c journey, Journey_Template__c template) {
        if (journey == null) {
            return;
        }
        journey.Status__c = 'Care plan active';
        journey.Cycle__c = (journey.Cycle__c == null ? 1 : journey.Cycle__c + 1);
        if (template != null && template.Interval_Days__c != null) {
            journey.Next_Due_Date__c = Date.today().addDays(Integer.valueOf(template.Interval_Days__c));
        }
    }
}
