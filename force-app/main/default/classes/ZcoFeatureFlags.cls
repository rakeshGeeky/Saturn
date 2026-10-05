public with sharing class ZcoFeatureFlags {
    public static Boolean isEnabled(String featureKey) {
        return isEnabled(featureKey, false);
    }

    public static Boolean isEnabled(String featureKey, Boolean defaultValue) {
        Zco_Feature_Flag__mdt flag = getFlag(featureKey);
        if (flag == null) {
            return defaultValue;
        }
        return flag.Feature__c == featureKey.trim() ? flag.Enabled__c : flag.Is_Enabled__c;
    }

    public static String getValue(String featureKey) {
        return getValue(featureKey, null);
    }

    public static String getValue(String featureKey, String defaultValue) {
        Zco_Feature_Flag__mdt flag = getFlag(featureKey);
        if (flag == null) {
            return defaultValue;
        }
        return String.isBlank(flag.Value__c) ? defaultValue : flag.Value__c;
    }

    private static Zco_Feature_Flag__mdt getFlag(String featureKey) {
        if (String.isBlank(featureKey)) {
            return null;
        }

        String normalizedKey = featureKey.trim();
        for (Zco_Feature_Flag__mdt flag : [
            SELECT Id, DeveloperName, Feature__c, Enabled__c, Key__c, Is_Enabled__c, Value__c
            FROM Zco_Feature_Flag__mdt
            WHERE Feature__c = :normalizedKey OR Key__c = :normalizedKey
            LIMIT 1
        ]) {
            return flag;
        }
        return null;
    }
}