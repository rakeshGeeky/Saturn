/**
 * Invocable Apex bridge so flows can scan free text for safety/crisis keywords via the
 * existing ZcoSafetyKeywordService.
 */
public with sharing class ZcoScanSafetyKeywordsAction {
    public class TextRequest {
        @InvocableVariable(required=true)
        public String text;
    }

    public class SafetyKeywordResult {
        @InvocableVariable public Boolean hasMatch;
        @InvocableVariable public String matchSummary;
    }

    @InvocableMethod(label='Zco: Scan Safety Keywords' category='Zime Care Orchestration')
    public static List<SafetyKeywordResult> scanSafetyKeywords(List<TextRequest> requests) {
        List<SafetyKeywordResult> results = new List<SafetyKeywordResult>();
        for (TextRequest req : requests) {
            List<String> matches = ZcoSafetyKeywordService.scanText(req.text);
            SafetyKeywordResult result = new SafetyKeywordResult();
            result.hasMatch = !matches.isEmpty();
            result.matchSummary = matches.isEmpty() ? null : String.join(matches, '; ');
            results.add(result);
        }
        return results;
    }
}
