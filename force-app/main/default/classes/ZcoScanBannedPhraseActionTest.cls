@IsTest
private class ZcoScanBannedPhraseActionTest {
    @IsTest
    static void testScanBannedPhrase() {
        ZcoScanBannedPhraseAction.TextRequest hit = new ZcoScanBannedPhraseAction.TextRequest();
        hit.text = 'This is a GUARANTEED cure';
        ZcoScanBannedPhraseAction.TextRequest clean = new ZcoScanBannedPhraseAction.TextRequest();
        clean.text = 'Please schedule a follow-up.';

        List<ZcoScanBannedPhraseAction.BannedPhraseResult> results = ZcoScanBannedPhraseAction.scanBannedPhrase(
            new List<ZcoScanBannedPhraseAction.TextRequest>{ hit, clean }
        );
        System.assertEquals(2, results.size());
        System.assertEquals(true, results[0].hasHit);
        System.assertEquals(false, results[1].hasHit);
    }
}
