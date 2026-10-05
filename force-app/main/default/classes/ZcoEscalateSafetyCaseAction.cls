/**
 * Invocable Apex bridge so flows can escalate a safety concern into a Case via the existing
 * ZcoSafetyEscalationService.
 */
public with sharing class ZcoEscalateSafetyCaseAction {
    public class EscalationRequest {
        @InvocableVariable(required=true) public String subject;
        @InvocableVariable public Id patientId;
        @InvocableVariable(required=true) public String summary;
        @InvocableVariable public Id ownerId;
    }

    public class EscalationResult {
        @InvocableVariable public Id caseId;
    }

    @InvocableMethod(label='Zco: Escalate Safety Case' category='Zime Care Orchestration')
    public static List<EscalationResult> escalateSafetyCase(List<EscalationRequest> requests) {
        List<EscalationResult> results = new List<EscalationResult>();
        for (EscalationRequest req : requests) {
            Case escalation = ZcoSafetyEscalationService.createEscalation(req.subject, req.patientId, req.summary, req.ownerId);
            EscalationResult result = new EscalationResult();
            result.caseId = escalation != null ? escalation.Id : null;
            results.add(result);
        }
        return results;
    }
}
