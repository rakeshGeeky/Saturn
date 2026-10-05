/**
 * Invocable Apex bridge so flows can capture consent records via the existing
 * ZcoConsentService.
 */
public with sharing class ZcoCaptureConsentAction {
    public class ConsentRequest {
        @InvocableVariable(required=true) public Id patientId;
        @InvocableVariable(required=true) public String mobileNumber;
        @InvocableVariable(required=true) public String noticeVersion;
        @InvocableVariable(required=true) public String purpose;
        @InvocableVariable(required=true) public String consentStatus;
    }

    public class ConsentResult {
        @InvocableVariable public Boolean isSuccess;
        @InvocableVariable public String errorMessage;
    }

    @InvocableMethod(label='Zco: Capture Consent' category='Zime Care Orchestration')
    public static List<ConsentResult> captureConsent(List<ConsentRequest> requests) {
        List<ConsentResult> results = new List<ConsentResult>();
        for (ConsentRequest req : requests) {
            ConsentResult result = new ConsentResult();
            try {
                ZcoConsentService.captureConsent(req.patientId, req.mobileNumber, req.noticeVersion, req.purpose, req.consentStatus);
                result.isSuccess = true;
            } catch (Exception ex) {
                result.isSuccess = false;
                result.errorMessage = ex.getMessage();
            }
            results.add(result);
        }
        return results;
    }
}
