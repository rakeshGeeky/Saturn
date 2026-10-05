public without sharing class ZcoAccountLtvService {
    public static void recalculate(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return;
        }

        Map<Id, Decimal> lifetimeValues = new Map<Id, Decimal>();
        for (AggregateResult result : [
            SELECT AccountId accountId, SUM(Amount) lifetimeValue
            FROM Opportunity
            WHERE AccountId IN :accountIds AND IsWon = true
            GROUP BY AccountId
        ]) {
            lifetimeValues.put((Id)result.get('accountId'), (Decimal)result.get('lifetimeValue'));
        }

        List<Account> accountsToUpdate = new List<Account>();
        for (Id accountId : accountIds) {
            accountsToUpdate.add(new Account(
                Id = accountId,
                LTV__c = lifetimeValues.containsKey(accountId) ? lifetimeValues.get(accountId) : 0
            ));
        }
        update accountsToUpdate;
    }
}