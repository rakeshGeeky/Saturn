@IsTest
private class ZcoAccountLtvServiceTest {
    @IsTest
    static void recalculatesWonOpportunityValue() {
        Account patient = new Account(Name = 'Lifetime Value Patient');
        insert patient;

        Opportunity wonOpportunity = new Opportunity(
            Name = 'Completed Program',
            AccountId = patient.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 1000
        );
        insert wonOpportunity;

        Account updatedPatient = [SELECT LTV__c FROM Account WHERE Id = :patient.Id];
        System.assertEquals(1000, updatedPatient.LTV__c);

        wonOpportunity.Amount = 1250;
        update wonOpportunity;
        updatedPatient = [SELECT LTV__c FROM Account WHERE Id = :patient.Id];
        System.assertEquals(1250, updatedPatient.LTV__c);

        delete wonOpportunity;
        updatedPatient = [SELECT LTV__c FROM Account WHERE Id = :patient.Id];
        System.assertEquals(0, updatedPatient.LTV__c);
    }
}