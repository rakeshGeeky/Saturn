@IsTest
private class ZcoScanSafetyKeywordsActionTest {
    @IsTest
    static void testScanSafetyKeywords() {
        ZcoScanSafetyKeywordsAction.TextRequest clean = new ZcoScanSafetyKeywordsAction.TextRequest();
        clean.text = 'Please schedule a follow-up.';

        List<ZcoScanSafetyKeywordsAction.SafetyKeywordResult> keywordResults = ZcoScanSafetyKeywordsAction.scanSafetyKeywords(
            new List<ZcoScanSafetyKeywordsAction.TextRequest>{ clean }
        );
        System.assertEquals(1, keywordResults.size());
        System.assertEquals(false, keywordResults[0].hasMatch);
    }
}
