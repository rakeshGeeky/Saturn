@IsTest
private class ZcoEvaluateIntakeEligibilityActionTest {
    @IsTest
    static void testEvaluateIntakeEligibility() {
        Account patient = new Account(Name = 'Eligibility Patient');
        insert patient;
        Patient_Intake__c intake = new Patient_Intake__c(Patient__c = patient.Id);
        insert intake;

        ZcoEvaluateIntakeEligibilityAction.EligibilityRequest req = new ZcoEvaluateIntakeEligibilityAction.EligibilityRequest();
        req.intakeId = intake.Id;
        List<ZcoEvaluateIntakeEligibilityAction.EligibilityResult> results = ZcoEvaluateIntakeEligibilityAction.evaluateIntakeEligibility(
            new List<ZcoEvaluateIntakeEligibilityAction.EligibilityRequest>{ req }
        );
        System.assertEquals(1, results.size());
    }
}
