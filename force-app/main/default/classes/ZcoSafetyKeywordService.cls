public with sharing class ZcoSafetyKeywordService {
    public static List<String> scanText(String text) {
        if (String.isBlank(text)) {
            return new List<String>();
        }
        return scanText(text, [
            SELECT Language__c, Pattern__c, Severity__c
            FROM Zco_Safety_Keyword__mdt
            WHERE Active__c = true
        ]);
    }

    @TestVisible
    private static List<String> scanText(String text, List<Zco_Safety_Keyword__mdt> keywords) {
        List<String> matches = new List<String>();
        if (String.isBlank(text) || keywords == null) {
            return matches;
        }
        for (Zco_Safety_Keyword__mdt keyword : keywords) {
            if (String.isBlank(keyword.Pattern__c)) {
                continue;
            }
            Pattern p = Pattern.compile('(?i)' + keyword.Pattern__c);
            if (p.matcher(text).find()) {
                matches.add(keyword.Pattern__c + '|' + keyword.Severity__c);
            }
        }
        return matches;
    }
}
