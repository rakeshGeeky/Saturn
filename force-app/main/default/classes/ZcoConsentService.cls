public with sharing class ZcoConsentService {
    public static void captureConsent(Id patientId, String mobileNumber, String noticeVersion, String purpose, String consentStatus) {
        if (patientId == null) {
            throw new IllegalArgumentException('Patient account is required.');
        }
        if (String.isBlank(mobileNumber) || String.isBlank(noticeVersion) || String.isBlank(purpose)) {
            throw new IllegalArgumentException('Mobile number, notice version, and purpose are required.');
        }

        String privacyStatus = normalizeConsentStatus(consentStatus);
        List<Contact> contacts = [
            SELECT Id
            FROM Contact
            WHERE AccountId = :patientId
            LIMIT 2
        ];
        if (contacts.size() != 1) {
            throw new IllegalArgumentException('The patient account must have exactly one associated contact to capture consent.');
        }

        List<DataUsePurpose> purposes = [
            SELECT Id
            FROM DataUsePurpose
            WHERE Name = :purpose
            LIMIT 2
        ];
        if (purposes.size() != 1) {
            throw new IllegalArgumentException('A unique Data Use Purpose named "' + purpose + '" must exist before consent can be captured.');
        }

        List<AuthorizationFormText> formTexts = [
            SELECT Id
            FROM AuthorizationFormText
            WHERE Name = :noticeVersion
            LIMIT 2
        ];
        if (formTexts.size() != 1) {
            throw new IllegalArgumentException('A unique Authorization Form Text named "' + noticeVersion + '" must exist before consent can be captured.');
        }

        Id contactId = contacts[0].Id;
        List<ContactPointPhone> phones = [
            SELECT Id
            FROM ContactPointPhone
            WHERE ParentId = :contactId AND TelephoneNumber = :mobileNumber
            LIMIT 1
        ];
        ContactPointPhone phone = buildPhone(contactId, mobileNumber, phones.isEmpty() ? null : phones[0].Id);
        if (phones.isEmpty()) {
            insert phone;
        } else {
            update phone;
        }

        insert buildTypeConsent(contactId, purposes[0].Id, purpose, noticeVersion, privacyStatus);
        insert buildAuthorizationFormConsent(contactId, formTexts[0].Id, noticeVersion, privacyStatus);
    }


    @TestVisible
    private static ContactPointPhone buildPhone(Id contactId, String mobileNumber, Id existingPhoneId) {
        ContactPointPhone phone = existingPhoneId == null
            ? new ContactPointPhone(ParentId = contactId, TelephoneNumber = mobileNumber)
            : new ContactPointPhone(Id = existingPhoneId);
        phone.PhoneType = 'Mobile';
        phone.TelephoneNumber = mobileNumber;
        phone.IsPersonalPhone = true;
        phone.IsBusinessPhone = false;
        return phone;
    }

    @TestVisible
    private static ContactPointTypeConsent buildTypeConsent(Id contactId, Id purposeId, String purpose, String noticeVersion, String privacyStatus) {
        return new ContactPointTypeConsent(
            Name = purpose,
            PartyId = contactId,
            DataUsePurposeId = purposeId,
            PrivacyConsentStatus = privacyStatus,
            CaptureContactPointType = 'Phone',
            CaptureDate = Datetime.now(),
            CaptureSource = 'Workbook implementation; notice ' + noticeVersion
        );
    }

    @TestVisible
    private static AuthorizationFormConsent buildAuthorizationFormConsent(Id contactId, Id formTextId, String noticeVersion, String privacyStatus) {
        return new AuthorizationFormConsent(
            Name = noticeVersion,
            ConsentGiverId = contactId,
            AuthorizationFormTextId = formTextId,
            ConsentCapturedSourceType = 'Phone',
            ConsentCapturedSource = 'Workbook implementation',
            ConsentCapturedDateTime = Datetime.now(),
            Status = formStatus(privacyStatus)
        );
    }

    @TestVisible
    private static String formStatus(String privacyStatus) {
        return privacyStatus == 'OptIn' ? 'Signed' : (privacyStatus == 'OptOut' ? 'Rejected' : 'Seen');
    }

    @TestVisible
    private static String normalizeConsentStatus(String consentStatus) {
        if (String.isBlank(consentStatus)) {
            throw new IllegalArgumentException('Consent status is required.');
        }
        if (consentStatus == 'Granted' || consentStatus == 'Consent Granted') {
            return 'OptIn';
        }
        if (consentStatus == 'Withdrawn' || consentStatus == 'Revoked' || consentStatus == 'Consent Withdrawn') {
            return 'OptOut';
        }
        Set<String> supportedStatuses = new Set<String>{'NotSeen', 'Seen', 'OptIn', 'OptOut', 'OptInPending', 'OptOutPending'};
        if (!supportedStatuses.contains(consentStatus)) {
            throw new IllegalArgumentException('Unsupported consent status: ' + consentStatus);
        }
        return consentStatus;
    }
}
