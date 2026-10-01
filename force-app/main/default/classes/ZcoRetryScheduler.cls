public with sharing class ZcoRetryScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new RetryQueueable());
    }

    public class RetryQueueable implements Queueable {
        public void execute(QueueableContext qc) {
            List<Integration_Log__c> failed = [
                SELECT Id, Status__c, Correlation_Id__c, Endpoint__c, Type__c
                FROM Integration_Log__c
                WHERE Status__c = 'Failed'
                ORDER BY CreatedDate ASC
                LIMIT 100
            ];

            if (failed.isEmpty()) {
                return;
            }

            for (Integration_Log__c logRecord : failed) {
                logRecord.Status__c = 'Retrying';
            }

            update failed;
        }
    }
}
