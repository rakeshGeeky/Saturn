public with sharing class ZcoPatientMatchService {
    public static String matchByPhone(String phoneNumber) {
        if (String.isBlank(phoneNumber)) {
            return 'Unknown';
        }

        String normalized = ZcoPhoneUtil.normalizeMobile(phoneNumber);
        List<Account> matches = [
            SELECT Id, Name
            FROM Account
            WHERE Normalized_Mobile__c = :normalized
            LIMIT 1
        ];

        if (matches.isEmpty()) {
            return 'New';
        }
        return matches[0].Id;
    }
}