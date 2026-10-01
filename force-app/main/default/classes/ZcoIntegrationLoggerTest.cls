@IsTest
private class ZcoIntegrationLoggerTest {
    @IsTest
    static void testLogRedactsSensitiveValues() {
        Test.startTest();
        ZcoIntegrationLogger.log(
            'HTTP',
            'https://example.com/webhook',
            'corr-123',
            'Success',
            '{"phone":"+91 98765 43210","email":"patient@example.com","token":"abc123"}',
            null
        );
        Test.stopTest();

        List<Integration_Log__c> logs = [
            SELECT Id, Payload__c, Error_Message__c
            FROM Integration_Log__c
            WHERE Correlation_Id__c = 'corr-123'
        ];

        System.assertEquals(1, logs.size());
        System.assert(logs[0].Payload__c.contains('[REDACTED_PHONE]'));
        System.assert(logs[0].Payload__c.contains('[REDACTED_EMAIL]'));
        System.assert(logs[0].Payload__c.contains('[REDACTED]'));
    }
}
