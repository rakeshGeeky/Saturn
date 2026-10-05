public with sharing class ZcoEligibilityService {
    public class RuleMatch {
        @AuraEnabled public String outcome { get; set; }
        @AuraEnabled public String guardrailId { get; set; }
        @AuraEnabled public String holdingTemplateKey { get; set; }
    }

    public static List<RuleMatch> evaluateRecord(SObject record) {
        if (record == null) {
            return new List<RuleMatch>();
        }

        List<RuleMatch> matches = new List<RuleMatch>();
        for (Zco_Eligibility_Rule__mdt rule : [
            SELECT Active__c, Field_API__c, Operator__c, Value__c, Outcome__c, Guardrail_Id__c, Holding_Template_Key__c
            FROM Zco_Eligibility_Rule__mdt
            WHERE Active__c = true
        ]) {
            if (String.isBlank(rule.Field_API__c) || String.isBlank(rule.Operator__c)) {
                continue;
            }

            Object actualValue = record.get(rule.Field_API__c);
            if (!matchesOperator(actualValue, rule.Operator__c, rule.Value__c)) {
                continue;
            }

            RuleMatch match = new RuleMatch();
            match.outcome = rule.Outcome__c;
            match.guardrailId = rule.Guardrail_Id__c;
            match.holdingTemplateKey = rule.Holding_Template_Key__c;
            matches.add(match);
        }
        return matches;
    }

    private static Boolean matchesOperator(Object actualValue, String operatorName, String expectedValue) {
        if (String.isBlank(operatorName)) {
            return false;
        }

        String comparison = String.valueOf(actualValue == null ? '' : actualValue).trim();
        String expected = String.isBlank(expectedValue) ? '' : expectedValue.trim();

        switch on operatorName.toLowerCase() {
            when 'equals' {
                return comparison.equalsIgnoreCase(expected);
            }
            when 'contains' {
                return comparison.containsIgnoreCase(expected);
            }
            when 'not_equals', 'notequals' {
                return !comparison.equalsIgnoreCase(expected);
            }
            when 'is_blank', 'blank' {
                return String.isBlank(comparison);
            }
            when 'not_blank', 'notblank' {
                return !String.isBlank(comparison);
            }
            when 'greater_than', 'gt' {
                return Decimal.valueOf(comparison) > Decimal.valueOf(expected);
            }
            when 'less_than', 'lt' {
                return Decimal.valueOf(comparison) < Decimal.valueOf(expected);
            }
            when else {
                return comparison.equalsIgnoreCase(expected);
            }
        }
    }
}