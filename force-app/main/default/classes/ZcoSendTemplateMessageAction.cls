/**
 * Invocable Apex bridge so flows can send a WhatsApp template message via the existing
 * ZcoMessagingService.
 */
public with sharing class ZcoSendTemplateMessageAction {
    public class SendTemplateRequest {
        @InvocableVariable(required=true) public Id patientId;
        @InvocableVariable(required=true) public String templateKey;
        @InvocableVariable public String variablesJson;
    }

    @InvocableMethod(label='Zco: Send Template Message' category='Zime Care Orchestration')
    public static void sendTemplateMessage(List<SendTemplateRequest> requests) {
        for (SendTemplateRequest req : requests) {
            Map<String, String> variables = new Map<String, String>();
            if (String.isNotBlank(req.variablesJson)) {
                try {
                    Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(req.variablesJson);
                    for (String key : parsed.keySet()) {
                        variables.put(key, String.valueOf(parsed.get(key)));
                    }
                } catch (Exception ex) {
                    variables = new Map<String, String>();
                }
            }
            ZcoMessagingService.sendTemplate(req.patientId, req.templateKey, variables);
        }
    }
}
