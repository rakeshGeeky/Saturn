/**
 * Invocable Apex bridge so flows can resolve a patient Account from an inbound phone number
 * via the existing ZcoPatientMatchService.
 */
public with sharing class ZcoMatchPatientByPhoneAction {
    public class PhoneRequest {
        @InvocableVariable(required=true)
        public String phoneNumber;
    }

    public class PatientMatchResult {
        @InvocableVariable public Id patientId;
        @InvocableVariable public Boolean isMatched;
    }

    @InvocableMethod(label='Zco: Match Patient By Phone' category='Zime Care Orchestration')
    public static List<PatientMatchResult> matchPatientByPhone(List<PhoneRequest> requests) {
        List<PatientMatchResult> results = new List<PatientMatchResult>();
        for (PhoneRequest req : requests) {
            String matched = ZcoPatientMatchService.matchByPhone(req.phoneNumber);
            PatientMatchResult result = new PatientMatchResult();
            Boolean isAccountId = matched != null && matched != 'Unknown' && matched != 'New';
            result.isMatched = isAccountId;
            result.patientId = isAccountId ? Id.valueOf(matched) : null;
            results.add(result);
        }
        return results;
    }
}
