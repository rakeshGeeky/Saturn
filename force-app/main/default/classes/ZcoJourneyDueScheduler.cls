public with sharing class ZcoJourneyDueScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        if (!Test.isRunningTest()) {
            Database.executeBatch(new ZcoJourneyDueBatch(), 200);
        }
    }
}
