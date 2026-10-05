/**
 * Invocable Apex bridge so flows can evaluate patient intake eligibility via the existing
 * ZcoEligibilityService.
 */
public with sharing class ZcoEvaluateIntakeEligibilityAction {
    public class EligibilityRequest {
        @InvocableVariable(required=true) public Id intakeId;
    }

    public class EligibilityResult {
        @InvocableVariable public String outcome;
        @InvocableVariable public String guardrailId;
        @InvocableVariable public String holdingTemplateKey;
    }

    @InvocableMethod(label='Zco: Evaluate Intake Eligibility' category='Zime Care Orchestration')
    public static List<EligibilityResult> evaluateIntakeEligibility(List<EligibilityRequest> requests) {
        List<Id> intakeIds = new List<Id>();
        for (EligibilityRequest r : requests) { intakeIds.add(r.intakeId); }
        Map<Id, Patient_Intake__c> intakes = new Map<Id, Patient_Intake__c>([
            SELECT Id, Diabetes_Type__c, HbA1c_Band__c, Urgency__c, Years_Band__c
            FROM Patient_Intake__c
            WHERE Id IN :intakeIds
        ]);
        List<EligibilityResult> results = new List<EligibilityResult>();
        for (Id intakeId : intakeIds) {
            EligibilityResult result = new EligibilityResult();
            Patient_Intake__c intake = intakes.get(intakeId);
            if (intake != null) {
                List<ZcoEligibilityService.RuleMatch> matches = ZcoEligibilityService.evaluateRecord(intake);
                if (!matches.isEmpty()) {
                    result.outcome = matches[0].outcome;
                    result.guardrailId = matches[0].guardrailId;
                    result.holdingTemplateKey = matches[0].holdingTemplateKey;
                }
            }
            results.add(result);
        }
        return results;
    }
}
