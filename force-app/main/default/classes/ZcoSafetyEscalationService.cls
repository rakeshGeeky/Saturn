public with sharing class ZcoSafetyEscalationService {
    public static Case createEscalation(String subject, Id patientId, String summary, Id ownerId) {
        Case escalation = buildEscalation(subject, patientId, summary, ownerId);
        if (escalation != null) {
            insert escalation;
        }
        return escalation;
    }

    public static Case escalateWhenRisk(String subject, Id patientId, String summary) {
        return createEscalation(subject, patientId, summary, null);
    }

    @TestVisible
    private static Case buildEscalation(String subject, Id patientId, String summary, Id ownerId) {
        if (String.isBlank(subject) || String.isBlank(summary)) {
            return null;
        }
        Case escalation = new Case(
            Subject = subject,
            Status = 'New',
            Origin = 'Workflow',
            Priority = 'High',
            Description = summary,
            Safety_Escalation__c = true
        );
        if (patientId != null) {
            escalation.AccountId = patientId;
        }
        if (ownerId != null) {
            escalation.OwnerId = ownerId;
        }
        return escalation;
    }
}