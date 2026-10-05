@IsTest
private class ZcoBannedPhraseServiceTest {
    @IsTest
    static void scansConfiguredPatternsCaseInsensitively() {
        System.assertEquals(
            'cure(s|d)? diabetes',
            ZcoBannedPhraseService.scanBody('Our program CURES diabetes permanently.')
        );
        System.assertEquals(null, ZcoBannedPhraseService.scanBody('Talk to your care team.'));
        System.assertEquals(null, ZcoBannedPhraseService.scanBody(null));
    }
}
