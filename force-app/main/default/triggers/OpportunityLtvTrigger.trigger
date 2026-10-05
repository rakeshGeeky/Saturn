trigger OpportunityLtvTrigger on Opportunity (after insert, after update, after delete, after undelete) {
    Set<Id> affectedAccountIds = new Set<Id>();

    if (Trigger.isDelete) {
        for (Opportunity opportunityRecord : Trigger.old) {
            if (opportunityRecord.AccountId != null) {
                affectedAccountIds.add(opportunityRecord.AccountId);
            }
        }
    } else {
        for (Opportunity opportunityRecord : Trigger.new) {
            if (opportunityRecord.AccountId != null) {
                affectedAccountIds.add(opportunityRecord.AccountId);
            }
        }
        if (Trigger.isUpdate) {
            for (Opportunity oldRecord : Trigger.old) {
                if (oldRecord.AccountId != null) {
                    affectedAccountIds.add(oldRecord.AccountId);
                }
            }
        }
    }

    ZcoAccountLtvService.recalculate(affectedAccountIds);
}
