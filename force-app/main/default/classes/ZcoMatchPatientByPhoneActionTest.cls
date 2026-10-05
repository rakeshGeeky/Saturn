@IsTest
private class ZcoMatchPatientByPhoneActionTest {
    @IsTest
    static void testMatchPatientByPhoneNoMatch() {
        ZcoMatchPatientByPhoneAction.PhoneRequest req = new ZcoMatchPatientByPhoneAction.PhoneRequest();
        req.phoneNumber = '9999999999';
        List<ZcoMatchPatientByPhoneAction.PatientMatchResult> results = ZcoMatchPatientByPhoneAction.matchPatientByPhone(
            new List<ZcoMatchPatientByPhoneAction.PhoneRequest>{ req }
        );
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].isMatched);
    }
}
