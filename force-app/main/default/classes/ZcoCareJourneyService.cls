public with sharing class ZcoCareJourneyService {
    public static String transitionToState(String currentState, String requestedAction) {
        if (String.isBlank(currentState)) {
            if (requestedAction == 'Care plan active') {
                return requestedAction;
            }
            throw new IllegalArgumentException('A new care journey must start in Care plan active.');
        }
        Map<String, Set<String>> allowed = new Map<String, Set<String>>{
            'Care plan active' => new Set<String>{'Due', 'Completed'},
            'Due' => new Set<String>{'Outreach sent', 'Lost to follow-up', 'Completed'},
            'Outreach sent' => new Set<String>{'Scheduled', 'Snoozed', 'Due', 'Lost to follow-up'},
            'Scheduled' => new Set<String>{'Completed', 'Due'},
            'Snoozed' => new Set<String>{'Due', 'Lost to follow-up', 'Completed'},
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

    public static void validateTransitions(List<Care_Journey__c> journeys, Map<Id, Care_Journey__c> priorJourneys) {
        if (journeys == null || priorJourneys == null || FeatureManagement.checkPermission('Zco_Bypass_Journey_Rules')) {
            return;
        }

        for (Care_Journey__c journey : journeys) {
            Care_Journey__c prior = priorJourneys.get(journey.Id);
            if (prior == null || prior.Status__c == journey.Status__c) {
                continue;
            }

            try {
                if (String.isBlank(journey.Status__c)) {
                    throw new IllegalArgumentException('Care journey status cannot be cleared.');
                }
                transitionToState(prior.Status__c, journey.Status__c);
            } catch (IllegalArgumentException ex) {
                journey.Status__c.addError(ex.getMessage());
            }

            journey.State_Changed_At__c = Datetime.now();
        }
    }

    public static void startJourney(Care_Journey__c journey, Journey_Template__c template) {
        if (journey == null) {
            return;
        }
        journey.Status__c = 'Care plan active';
        journey.State_Changed_At__c = Datetime.now();
        journey.Cycle__c = (journey.Cycle__c == null ? 1 : journey.Cycle__c + 1);
        if (template != null && template.Interval_Days__c != null) {
            journey.Next_Due_Date__c = Date.today().addDays(Integer.valueOf(template.Interval_Days__c));
        }
    }
}
