@IsTest
private class ZcoEscalateSafetyCaseActionTest {
    @IsTest
    static void testEscalateSafetyCaseCreatesCase() {
        ZcoEscalateSafetyCaseAction.EscalationRequest req = new ZcoEscalateSafetyCaseAction.EscalationRequest();
        req.subject = 'Safety concern';
        req.summary = 'Patient reported severe symptoms';

        Test.startTest();
        List<ZcoEscalateSafetyCaseAction.EscalationResult> results = ZcoEscalateSafetyCaseAction.escalateSafetyCase(
            new List<ZcoEscalateSafetyCaseAction.EscalationRequest>{ req }
        );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertNotEquals(null, results[0].caseId);
    }
}
