/**
 * Invocable Apex bridge so flows can evaluate clinical observation thresholds via the
 * existing ZcoThresholdService.
 */
public with sharing class ZcoEvaluateObservationThresholdAction {
    public class ThresholdRequest {
        @InvocableVariable(required=true) public Id observationId;
    }

    public class ThresholdResult {
        @InvocableVariable public Boolean outsideThreshold;
        @InvocableVariable public String actionRequired;
        @InvocableVariable public String thresholdRule;
    }

    @InvocableMethod(label='Zco: Evaluate Observation Threshold' category='Zime Care Orchestration')
    public static List<ThresholdResult> evaluateObservationThreshold(List<ThresholdRequest> requests) {
        List<Id> observationIds = new List<Id>();
        for (ThresholdRequest r : requests) { observationIds.add(r.observationId); }
        Map<Id, Clinical_Observation__c> observations = new Map<Id, Clinical_Observation__c>([
            SELECT Id, Type__c, Value__c, Outside_Threshold__c, Threshold_Rule__c, Action_Required__c
            FROM Clinical_Observation__c
            WHERE Id IN :observationIds
        ]);
        List<ThresholdResult> results = new List<ThresholdResult>();
        List<Clinical_Observation__c> toUpdate = new List<Clinical_Observation__c>();
        for (Id obsId : observationIds) {
            Clinical_Observation__c obs = observations.get(obsId);
            ThresholdResult result = new ThresholdResult();
            if (obs != null) {
                ZcoThresholdService.evaluate(obs);
                if (obs.Outside_Threshold__c == true) {
                    toUpdate.add(obs);
                }
                result.outsideThreshold = obs.Outside_Threshold__c;
                result.actionRequired = obs.Action_Required__c;
                result.thresholdRule = obs.Threshold_Rule__c;
            } else {
                result.outsideThreshold = false;
            }
            results.add(result);
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
        return results;
    }
}
