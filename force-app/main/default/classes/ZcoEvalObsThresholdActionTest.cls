@IsTest
private class ZcoEvalObsThresholdActionTest {
    @IsTest
    static void testEvaluateObservationThreshold() {
        Id fakeId = Id.valueOf(Clinical_Observation__c.SObjectType.getDescribe().getKeyPrefix() + '000000000001');

        ZcoEvaluateObservationThresholdAction.ThresholdRequest req = new ZcoEvaluateObservationThresholdAction.ThresholdRequest();
        req.observationId = fakeId;
        List<ZcoEvaluateObservationThresholdAction.ThresholdResult> results = ZcoEvaluateObservationThresholdAction.evaluateObservationThreshold(
            new List<ZcoEvaluateObservationThresholdAction.ThresholdRequest>{ req }
        );
        System.assertEquals(1, results.size());
    }
}
