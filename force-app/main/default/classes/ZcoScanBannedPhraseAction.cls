/**
 * Invocable Apex bridge so flows can scan free text for banned marketing/clinical phrases
 * via the existing ZcoBannedPhraseService.
 */
public with sharing class ZcoScanBannedPhraseAction {
    public class TextRequest {
        @InvocableVariable(required=true)
        public String text;
    }

    public class BannedPhraseResult {
        @InvocableVariable public String hitPhrase;
        @InvocableVariable public Boolean hasHit;
    }

    @InvocableMethod(label='Zco: Scan Banned Phrase' category='Zime Care Orchestration')
    public static List<BannedPhraseResult> scanBannedPhrase(List<TextRequest> requests) {
        List<BannedPhraseResult> results = new List<BannedPhraseResult>();
        for (TextRequest req : requests) {
            String hit = ZcoBannedPhraseService.scanBody(req.text);
            BannedPhraseResult result = new BannedPhraseResult();
            result.hitPhrase = hit;
            result.hasHit = String.isNotBlank(hit);
            results.add(result);
        }
        return results;
    }
}
