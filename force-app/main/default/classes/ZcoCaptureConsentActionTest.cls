@IsTest
private class ZcoCaptureConsentActionTest {
    @IsTest
    static void testCaptureConsentFailureIsCaught() {
        ZcoCaptureConsentAction.ConsentRequest req = new ZcoCaptureConsentAction.ConsentRequest();
        req.patientId = null;
        req.mobileNumber = '9999999999';
        req.noticeVersion = 'V1';
        req.purpose = 'Care coordination';
        req.consentStatus = 'Granted';

        List<ZcoCaptureConsentAction.ConsentResult> results = ZcoCaptureConsentAction.captureConsent(
            new List<ZcoCaptureConsentAction.ConsentRequest>{ req }
        );
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].isSuccess);
        System.assertNotEquals(null, results[0].errorMessage);
    }
}
