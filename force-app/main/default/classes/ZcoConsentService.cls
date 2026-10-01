public with sharing class ZcoConsentService {
    public static void captureConsent(Id patientId, String mobileNumber, String noticeVersion, String purpose, String consentStatus) {
        if (patientId == null || String.isBlank(mobileNumber)) {
            return;
        }

        Account patient = [SELECT Id, PersonContactId FROM Account WHERE Id = :patientId LIMIT 1];
        if (patient == null) {
            return;
        }

        if (patient.PersonContactId == null) {
            return;
        }

        if (String.isBlank(noticeVersion)) {
            throw new IllegalArgumentException('Consent notice version is required.');
        }

        ContactPointPhone phone = new ContactPointPhone(
            ParentId = patient.PersonContactId,
            PhoneType = 'Mobile',
            TelephoneNumber = mobileNumber,
            IsPrimary = true
        );
        insert phone;

        ContactPointTypeConsent consent = new ContactPointTypeConsent(
            Name = purpose,
            PartyId = patient.PersonContactId,
            ConsentStatus = consentStatus,
            DataUsePurpose = purpose,
            Purpose = purpose,
            CaptureSource = 'Workbook implementation'
        );
        insert consent;

        AuthorizationFormConsent auth = new AuthorizationFormConsent(
            Name = noticeVersion,
            AuthorizationFormText = noticeVersion,
            ConsentGiverId = patient.PersonContactId,
            Status = 'Consent Granted'
        );
        insert auth;
    }
}
