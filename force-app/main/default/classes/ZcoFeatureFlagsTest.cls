@IsTest
private class ZcoFeatureFlagsTest {
    @IsTest
    static void testFlagLookupResolvesMetadata() {
        System.assertEquals(true, ZcoFeatureFlags.isEnabled('integration_logging_enabled'));
        System.assertEquals('true', ZcoFeatureFlags.getValue('integration_logging_enabled', 'false'));
        System.assertEquals(false, ZcoFeatureFlags.isEnabled('missing_flag', false));
    }
}