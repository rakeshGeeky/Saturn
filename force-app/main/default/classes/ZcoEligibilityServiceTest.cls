@IsTest
private class ZcoEligibilityServiceTest {
    @IsTest
    static void testEvaluateRecordMatchesRule() {
        Account patient = new Account(Name = 'Diabetes Patient');
        patient.put('Diabetes_Type__c', 'Type 1');
        insert patient;

        List<ZcoEligibilityService.RuleMatch> matches = ZcoEligibilityService.evaluateRecord(patient);
        System.assertEquals(1, matches.size());
        System.assertEquals('Doctor review', matches[0].outcome);
        System.assertEquals('G1', matches[0].guardrailId);
    }
}