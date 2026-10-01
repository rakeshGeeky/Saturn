@IsTest
private class ZcoWorkbookServicesTest {
    private static Id getTestAccountId() {
        return Id.valueOf('001000000000001');
    }

    private static Id getTestJourneyId() {
        return Id.valueOf(Care_Journey__c.SObjectType.getDescribe().getKeyPrefix() + '000000000001');
    }

    @IsTest
    static void testPhoneAndTextUtilities() {
        System.assertEquals(null, ZcoPhoneUtil.normalizeMobile(null));
        System.assertEquals(null, ZcoPhoneUtil.normalizeMobile('letters only'));
        System.assertEquals('+911234567890', ZcoPhoneUtil.normalizeMobile('12345 67890'));
        System.assertEquals('+919876543210', ZcoPhoneUtil.normalizeMobile('919876543210'));
        System.assertEquals('+12345678901', ZcoPhoneUtil.normalizeMobile('012345678901'));
        System.assertEquals('+1234567', ZcoPhoneUtil.normalizeMobile('123-4567'));

        System.assertEquals(null, ZcoBannedPhraseService.scanBody(''));
        System.assertEquals('cure diabetes', ZcoBannedPhraseService.scanBody('A CURE DIABETES claim'));
        System.assertEquals('guaranteed', ZcoBannedPhraseService.scanBody('Guaranteed results'));
        System.assertEquals(null, ZcoBannedPhraseService.scanBody('Please schedule a follow-up.'));

        Map<String, Object> response = ZcoFhirClient.fetchPatient('MRN-123');
        System.assertEquals('MRN-123', response.get('patientId'));
        System.assertEquals('history unavailable', response.get('status'));
    }

    @IsTest
    static void testJourneyStateAndInitialization() {
        System.assertEquals('Care plan active', ZcoCareJourneyService.transitionToState(null, 'Care plan active'));
        System.assertEquals('Care plan active', ZcoCareJourneyService.transitionToState('Care plan active', null));
        System.assertEquals('Outreach sent', ZcoCareJourneyService.transitionToState('Due', 'Outreach sent'));
        System.assertEquals('Scheduled', ZcoCareJourneyService.transitionToState('Outreach sent', 'Scheduled'));
        System.assertEquals('Due', ZcoCareJourneyService.transitionToState('Snoozed', 'Due'));
        System.assertEquals('Lost to follow-up', ZcoCareJourneyService.transitionToState('Outreach sent', 'Lost to follow-up'));

        Boolean invalidTransitionThrown = false;
        try {
            ZcoCareJourneyService.transitionToState('Completed', 'Due');
        } catch (IllegalArgumentException ex) {
            invalidTransitionThrown = true;
        }
        System.assert(invalidTransitionThrown);

        Boolean invalidInitialStateThrown = false;
        try {
            ZcoCareJourneyService.transitionToState(null, 'Due');
        } catch (IllegalArgumentException ex) {
            invalidInitialStateThrown = true;
        }
        System.assert(invalidInitialStateThrown);

        Journey_Template__c template = new Journey_Template__c(Interval_Days__c = 14);
        Care_Journey__c journey = new Care_Journey__c();
        ZcoCareJourneyService.startJourney(journey, template);
        System.assertEquals('Care plan active', journey.Status__c);
        System.assertNotEquals(null, journey.State_Changed_At__c);
        System.assertEquals(1, journey.Cycle__c);
        System.assertEquals(Date.today().addDays(14), journey.Next_Due_Date__c);
        journey.Cycle__c = 2;
        ZcoCareJourneyService.startJourney(journey, null);
        System.assertEquals(3, journey.Cycle__c);
        ZcoCareJourneyService.startJourney(null, template);
    }

    @IsTest
    static void testJourneyTransitionHandlerStampsChanges() {
        Id journeyId = getTestJourneyId();
        Care_Journey__c prior = new Care_Journey__c(Id = journeyId, Status__c = 'Care plan active');
        Care_Journey__c updatedJourney = new Care_Journey__c(Id = journeyId, Status__c = 'Due');
        ZcoCareJourneyTriggerHandler.beforeUpdate(
            new List<Care_Journey__c>{updatedJourney},
            new Map<Id, Care_Journey__c>{journeyId => prior}
        );
        System.assertNotEquals(null, updatedJourney.State_Changed_At__c);
        ZcoCareJourneyTriggerHandler.beforeUpdate(null, null);

        Account firstPatient = new Account(Name = 'Journey Trigger Patient One');
        Account secondPatient = new Account(Name = 'Journey Trigger Patient Two');
        insert new List<Account>{firstPatient, secondPatient};
        Journey_Template__c persistedTemplate = new Journey_Template__c(Name = 'Trigger Test Template');
        insert persistedTemplate;
        Care_Journey__c persistedJourney = new Care_Journey__c(
            Patient__c = firstPatient.Id,
            Journey_Template__c = persistedTemplate.Id
        );
        insert persistedJourney;
        persistedJourney.Patient__c = secondPatient.Id;
        update persistedJourney;
    }

    @IsTest
    static void testOutreachEligibilityAndQueueing() {
        System.assertEquals(false, ZcoOutreachService.isOutreachAllowed(null));
        Account patient = new Account(Outreach_Suppressed__c = true);
        System.assertEquals(false, ZcoOutreachService.isOutreachAllowed(patient));
        patient.Outreach_Suppressed__c = false;
        patient.Patient_Status__c = 'Paused';
        System.assertEquals(false, ZcoOutreachService.isOutreachAllowed(patient));
        patient.Patient_Status__c = 'Active';
        System.assertEquals(true, ZcoOutreachService.isOutreachAllowed(patient));

        System.assertEquals(0, ZcoOutreachService.queueOutgoingOutreach(null).size());
        System.assertEquals(0, ZcoOutreachService.queueOutgoingOutreach(new List<Care_Journey__c>()).size());
        Care_Journey__c journey = new Care_Journey__c();
        journey.Next_Due_Date__c = Date.today().addDays(5);
        List<Care_Journey__c> queued = ZcoOutreachService.queueOutgoingOutreach(new List<Care_Journey__c>{journey, null});
        System.assertEquals('Outreach sent', queued[0].Status__c);
        System.assertNotEquals(null, queued[0].Last_Outreach_At__c);
        System.assertEquals(Date.today().addDays(5), queued[0].Next_Due_Date__c);
    }

    @IsTest
    static void testMetadataDrivenRules() {
        System.assertEquals(0, ZcoSafetyKeywordService.scanText(null).size());
        List<Zco_Safety_Keyword__mdt> keywords = new List<Zco_Safety_Keyword__mdt>{
            new Zco_Safety_Keyword__mdt(Pattern__c = 'urgent', Severity__c = 'High'),
            new Zco_Safety_Keyword__mdt(Pattern__c = '', Severity__c = 'Low')
        };
        System.assertEquals(1, ZcoSafetyKeywordService.scanText('URGENT symptoms', keywords).size());
        System.assertEquals(0, ZcoSafetyKeywordService.scanText('routine check-in', keywords).size());
        ZcoSafetyKeywordService.scanText('I have a severe symptom');

        ZcoThresholdService.evaluate(null);
        ZcoThresholdService.evaluate(new Clinical_Observation__c());
        List<Zco_Clinical_Threshold__mdt> thresholds = new List<Zco_Clinical_Threshold__mdt>{
            new Zco_Clinical_Threshold__mdt(Observation_Type__c = 'Glucose', Low__c = 54, High__c = 250, Action__c = 'Safety case', Guardrail_Id__c = 'G14')
        };
        Clinical_Observation__c low = new Clinical_Observation__c(Type__c = 'Glucose', Value__c = 40);
        ZcoThresholdService.evaluate(low, thresholds);
        System.assertEquals(true, low.Outside_Threshold__c);
        System.assertEquals('G14', low.Threshold_Rule__c);
        System.assertEquals('Safety case', low.Action_Required__c);

        Clinical_Observation__c high = new Clinical_Observation__c(Type__c = 'Glucose', Value__c = 300);
        ZcoThresholdService.evaluate(high, thresholds);
        System.assertEquals(true, high.Outside_Threshold__c);
        Clinical_Observation__c inRange = new Clinical_Observation__c(Type__c = 'Glucose', Value__c = 100);
        ZcoThresholdService.evaluate(inRange, thresholds);
        System.assertEquals(false, inRange.Outside_Threshold__c);
        ZcoThresholdService.evaluate(new Clinical_Observation__c(Type__c = 'Other', Value__c = 1), thresholds);
        ZcoThresholdService.evaluate(new Clinical_Observation__c(Type__c = 'Glucose'), thresholds);
        ZcoThresholdService.evaluate(low, null);
    }

    @IsTest
    static void testMessageMatchingAndBatchHelpers() {
        System.assertEquals('Unknown', ZcoPatientMatchService.matchByPhone(null));
        System.assertEquals('Unknown', ZcoPatientMatchService.matchByPhone('  '));

        System.assertEquals(null, ZcoMessagingService.buildMessage(null, 'Welcome', null));
        System.assertEquals(null, ZcoMessagingService.buildMessage(getTestAccountId(), '', null));
        WhatsApp_Message__c message = ZcoMessagingService.buildMessage(
            getTestAccountId(), 'Welcome', new Map<String, String>{'name' => 'Test'}
        );
        System.assertEquals('Outbound', message.Direction__c);
        System.assertEquals('Queued', message.Status__c);
        System.assert(message.Message_Body__c.contains('Welcome'));
        ZcoMessagingService.sendTemplate(null, 'Welcome', null);

        Date today = Date.today();
        Journey_Template__c template = new Journey_Template__c(
            Max_Attempts__c = 3,
            Attempt_Gap_Days__c = 2,
            LTFU_After_Days__c = 30
        );
        Care_Journey__c due = new Care_Journey__c(
            Id = getTestJourneyId(),
            Status__c = 'Care plan active',
            Next_Due_Date__c = today,
            Journey_Template__r = template
        );
        Care_Journey__c future = new Care_Journey__c(
            Id = Id.valueOf(Care_Journey__c.SObjectType.getDescribe().getKeyPrefix() + '000000000002'),
            Status__c = 'Care plan active',
            Next_Due_Date__c = today.addDays(1),
            Journey_Template__r = template
        );
        Care_Journey__c snoozed = new Care_Journey__c(
            Id = Id.valueOf(Care_Journey__c.SObjectType.getDescribe().getKeyPrefix() + '000000000003'),
            Status__c = 'Snoozed',
            Snooze_Until__c = today,
            Journey_Template__r = template
        );
        Care_Journey__c retry = new Care_Journey__c(
            Id = Id.valueOf(Care_Journey__c.SObjectType.getDescribe().getKeyPrefix() + '000000000004'),
            Status__c = 'Outreach sent',
            Attempts__c = 1,
            Last_Outreach_At__c = Datetime.now().addDays(-3),
            Journey_Template__r = template
        );
        Care_Journey__c maxed = new Care_Journey__c(
            Id = Id.valueOf(Care_Journey__c.SObjectType.getDescribe().getKeyPrefix() + '000000000005'),
            Status__c = 'Due',
            Attempts__c = 3,
            Journey_Template__r = template
        );
        Care_Journey__c noDate = new Care_Journey__c(Status__c = 'Outreach sent');
        List<Care_Journey__c> changed = ZcoJourneyDueBatch.evaluateJourneys(
            new List<Care_Journey__c>{due, future, snoozed, retry, maxed, noDate, null},
            new Set<Id>{future.Id},
            today
        );
        System.assertEquals('Due', due.Status__c);
        System.assertEquals('Care plan active', future.Status__c);
        System.assertEquals('Due', snoozed.Status__c);
        System.assertEquals('Due', retry.Status__c);
        System.assertEquals('Lost to follow-up', maxed.Status__c);
        System.assertEquals('Outreach sent', noDate.Status__c);
        System.assertEquals(4, changed.size());
        System.assertNotEquals(null, due.State_Changed_At__c);
        ZcoJourneyDueBatch.evaluateJourneys(null, new Set<Id>(), today);
        ZcoJourneyDueBatch batch = new ZcoJourneyDueBatch();
        batch.execute(null, new List<Care_Journey__c>());
        batch.finish(null);
    }

    @IsTest
    static void testJourneyBatchCanBeScheduled() {
        Test.startTest();
        String jobId = System.schedule(
            'Zco journey due test',
            '0 0 2 * * ?',
            new ZcoJourneyDueScheduler()
        );
        Test.stopTest();
        System.assertNotEquals(null, jobId);
    }

    @IsTest
    static void testAppointmentMapping() {
        System.assertEquals(null, ZcoAppointmentService.determineAppointmentState(null));
        System.assertEquals('Scheduled', ZcoAppointmentService.determineAppointmentState(new Appointment__c()));
        System.assertEquals('Completed', ZcoAppointmentService.determineAppointmentState(
            new Appointment__c(Check_In_At__c = Datetime.now())
        ));
        System.assertEquals('Cancelled', ZcoAppointmentService.determineAppointmentState(
            new Appointment__c(Status__c = 'Cancelled')
        ));

        System.assertEquals(null, ZcoAppointmentService.buildJourneyUpdate(null));
        System.assertEquals(null, ZcoAppointmentService.buildJourneyUpdate(new Appointment__c(Status__c = 'Scheduled')));
        Id journeyId = getTestJourneyId();
        Care_Journey__c scheduled = ZcoAppointmentService.buildJourneyUpdate(
            new Appointment__c(Care_Journey__c = journeyId, Status__c = 'Scheduled')
        );
        System.assertEquals('Outreach sent', scheduled.Status__c);
        System.assertEquals(null, ZcoAppointmentService.buildJourneyUpdate(
            new Appointment__c(Care_Journey__c = journeyId, Status__c = 'Cancelled')
        ));
        Care_Journey__c completed = ZcoAppointmentService.buildJourneyUpdate(
            new Appointment__c(Care_Journey__c = journeyId, Status__c = 'Completed')
        );
        System.assertEquals('Completed', completed.Status__c);
        System.assertEquals('Completed', completed.Closed_Reason__c);
        ZcoAppointmentService.syncCareJourney(null);
        ZcoAppointmentService.syncCareJourney(new Appointment__c());
    }

    @IsTest
    static void testSafetyAndConsentBuilders() {
        System.assertEquals(null, ZcoSafetyEscalationService.buildEscalation('', null, 'details', null));
        Case escalation = ZcoSafetyEscalationService.buildEscalation('Safety follow-up', getTestAccountId(), 'Risk needs review', UserInfo.getUserId());
        System.assertEquals(true, escalation.Safety_Escalation__c);
        System.assertEquals('New', escalation.Status);
        System.assertEquals('Workflow', escalation.Origin);
        System.assertEquals('High', escalation.Priority);
        System.assertEquals(UserInfo.getUserId(), escalation.OwnerId);
        System.assertEquals(null, ZcoSafetyEscalationService.buildEscalation('No summary', null, '', null));
        System.assertEquals(null, ZcoSafetyEscalationService.createEscalation('', null, 'details', null));

        System.assertEquals('OptIn', ZcoConsentService.normalizeConsentStatus('Consent Granted'));
        System.assertEquals('OptOut', ZcoConsentService.normalizeConsentStatus('Withdrawn'));
        System.assertEquals('Seen', ZcoConsentService.normalizeConsentStatus('Seen'));
        System.assertEquals('Signed', ZcoConsentService.formStatus('OptIn'));
        System.assertEquals('Rejected', ZcoConsentService.formStatus('OptOut'));
        System.assertEquals('Seen', ZcoConsentService.formStatus('OptInPending'));

        Id contactId = UserInfo.getUserId();
        ContactPointPhone phone = ZcoConsentService.buildPhone(contactId, '+911234567890', null);
        System.assertEquals('Mobile', phone.PhoneType);
        System.assertEquals(true, phone.IsPersonalPhone);
        System.assertEquals(false, phone.IsBusinessPhone);
        ContactPointTypeConsent typeConsent = ZcoConsentService.buildTypeConsent(contactId, contactId, 'Messaging', 'Notice-1', 'OptIn');
        System.assertEquals('OptIn', typeConsent.PrivacyConsentStatus);
        System.assert(typeConsent.CaptureSource.contains('Notice-1'));
        AuthorizationFormConsent formConsent = ZcoConsentService.buildAuthorizationFormConsent(contactId, contactId, 'Notice-1', 'OptIn');
        System.assertEquals('Signed', formConsent.Status);
        System.assertEquals('Notice-1', formConsent.Name);

        Boolean missingPatientThrown = false;
        try {
            ZcoConsentService.captureConsent(null, '1234567890', 'Notice-1', 'Messaging', 'OptIn');
        } catch (IllegalArgumentException ex) {
            missingPatientThrown = true;
        }
        System.assert(missingPatientThrown);
        Boolean invalidStatusThrown = false;
        try {
            ZcoConsentService.captureConsent(getTestAccountId(), '1234567890', 'Notice-1', 'Messaging', 'Unknown');
        } catch (IllegalArgumentException ex) {
            invalidStatusThrown = true;
        }
        System.assert(invalidStatusThrown);
        Boolean missingContactThrown = false;
        try {
            ZcoConsentService.captureConsent(getTestAccountId(), '1234567890', 'Notice-1', 'Messaging', 'OptIn');
        } catch (IllegalArgumentException ex) {
            missingContactThrown = true;
        }
        System.assert(missingContactThrown);
    }
}
