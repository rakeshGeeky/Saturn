public with sharing class ZcoBannedPhraseService {
    public static String scanBody(String body) {
        if (String.isBlank(body)) {
            return null;
        }

        List<String> banned = new List<String>{
            'cure diabetes',
            'guaranteed',
            'instant fix',
            'miracle'
        };

        for (String phrase : banned) {
            if (body.toLowerCase().contains(phrase)) {
                return phrase;
            }
        }
        return null;
    }
}