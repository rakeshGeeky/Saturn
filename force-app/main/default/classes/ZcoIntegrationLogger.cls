public with sharing class ZcoIntegrationLogger {
    public static void log(String type, String endpoint, String correlationId, String status, String payload, String errorMessage) {
        if (String.isBlank(type)) {
            type = 'Apex';
        }
        if (String.isBlank(status)) {
            status = 'Success';
        }

        Integration_Log__c logRecord = new Integration_Log__c(
            Type__c = type,
            Endpoint__c = endpoint,
            Correlation_Id__c = correlationId,
            Status__c = status,
            Payload__c = redact(payload),
            Error_Message__c = redact(errorMessage)
        );

        insert logRecord;
    }

    public static void log(String type, String endpoint, String correlationId, String payload, String errorMessage) {
        log(type, endpoint, correlationId, 'Failed', payload, errorMessage);
    }

    public static String redact(String value) {
        if (String.isBlank(value)) {
            return value;
        }

        String masked = value;
        masked = masked.replaceAll('(?i)(\\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}\\b)', '[REDACTED_EMAIL]');
        masked = masked.replaceAll('(?i)(\\b(?:phone|mobile|cell|mrn|patient|token|secret|authorization|apiKey|password)\\b\\s*[:=]\\s*"?)([^"\\s,}]+)', '$1[REDACTED]');
        masked = masked.replaceAll('(?i)(\\+?\\d[\\d\\s().-]{8,}\\d)', '[REDACTED_PHONE]');
        return masked;
    }

    public static void purge(Integer retentionDays) {
        if (retentionDays == null || retentionDays < 1) {
            retentionDays = 30;
        }

        DateTime cutoff = DateTime.now().addDays(-retentionDays);
        List<Integration_Log__c> records = [
            SELECT Id
            FROM Integration_Log__c
            WHERE CreatedDate < :cutoff
            LIMIT 1000
        ];

        if (!records.isEmpty()) {
            delete records;
        }
    }
}