public with sharing class ZcoThresholdService {
    public static void evaluate(Clinical_Observation__c obs) {
        if (obs == null || String.isBlank(obs.Type__c)) {
            return;
        }
        evaluate(obs, [
            SELECT Observation_Type__c, Unit__c, Low__c, High__c, Action__c, Guardrail_Id__c
            FROM Zco_Clinical_Threshold__mdt
            WHERE Active__c = true
        ]);
    }

    @TestVisible
    private static void evaluate(Clinical_Observation__c obs, List<Zco_Clinical_Threshold__mdt> thresholds) {
        if (obs == null || String.isBlank(obs.Type__c) || thresholds == null) {
            return;
        }
        for (Zco_Clinical_Threshold__mdt threshold : thresholds) {
            if (threshold.Observation_Type__c != obs.Type__c || obs.Value__c == null) {
                continue;
            }
            if (threshold.Low__c != null && obs.Value__c < threshold.Low__c) {
                setThresholdAction(obs, threshold);
                return;
            }
            if (threshold.High__c != null && obs.Value__c > threshold.High__c) {
                setThresholdAction(obs, threshold);
                return;
            }
        }
    }

    private static void setThresholdAction(Clinical_Observation__c obs, Zco_Clinical_Threshold__mdt threshold) {
        obs.Outside_Threshold__c = true;
        obs.Threshold_Rule__c = threshold.Guardrail_Id__c;
        obs.Action_Required__c = threshold.Action__c;
    }
}
