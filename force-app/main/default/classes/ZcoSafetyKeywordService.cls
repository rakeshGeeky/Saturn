public with sharing class ZcoSafetyKeywordService {
    public static List<String> scanText(String text) {
        List<String> matches = new List<String>();
        if (String.isBlank(text)) {
            return matches;
        }

        List<Zco_Safety_Keyword__mdt> keywords = [
            SELECT Language__c, Pattern__c, Severity__c
            FROM Zco_Safety_Keyword__mdt
            WHERE Active__c = true
        ];

        for (Zco_Safety_Keyword__mdt keyword : keywords) {
            if (String.isBlank(keyword.Pattern__c)) {
                continue;
            }
            Pattern p = Pattern.compile(keyword.Pattern__c, Pattern.CASE_INSENSITIVE);
            Matcher m = p.matcher(text);
            if (m.find()) {
                matches.add(keyword.Pattern__c + '|' + keyword.Severity__c);
            }
        }
        return matches;
    }
}
