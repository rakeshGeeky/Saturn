public with sharing class ZcoThresholdService {
    public static void evaluate(Clinical_Observation__c obs) {
        if (obs == null || String.isBlank(obs.Type__c)) {
            return;
        }

        List<Zco_Clinical_Threshold__mdt> thresholds = [
            SELECT Observation_Type__c, Unit__c, Low__c, High__c, Action__c, Guardrail_Id__c
            FROM Zco_Clinical_Threshold__mdt
            WHERE Active__c = true
        ];

        for (Zco_Clinical_Threshold__mdt threshold : thresholds) {
            if (threshold.Observation_Type__c != obs.Type__c) {
                continue;
            }

            Decimal value = obs.Value__c;
            if (value == null) {
                continue;
            }

            if (threshold.Low__c != null && value < threshold.Low__c) {
                obs.Outside_Threshold__c = true;
                obs.Threshold_Rule__c = threshold.Guardrail_Id__c;
                obs.Action_Required__c = threshold.Action__c;
                return;
            }

            if (threshold.High__c != null && value > threshold.High__c) {
                obs.Outside_Threshold__c = true;
                obs.Threshold_Rule__c = threshold.Guardrail_Id__c;
                obs.Action_Required__c = threshold.Action__c;
                return;
            }
        }
    }
}
