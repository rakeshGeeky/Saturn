@IsTest
private class ZcoWebhookSecurityTest {
    @IsTest
    static void testVerifySignatureAndTimestamp() {
        String body = '{"event":"created","status":"ok"}';
        String sharedSecret = 'super-secret';
        String signature = 'sha256=' + EncodingUtil.convertToHex(
            Crypto.generateMac('HMACSHA256', Blob.valueOf(body), Blob.valueOf(sharedSecret))
        );
        Map<String, String> headers = new Map<String, String>{
            'x-zco-signature' => signature,
            'x-zco-timestamp' => String.valueOf(DateTime.now().getTime() / 1000)
        };

        System.assertEquals(true, ZcoWebhookSecurity.verify(headers, body, sharedSecret, 5));
        System.assertEquals(false, ZcoWebhookSecurity.verify(headers, body + 'tamper', sharedSecret, 5));
    }
}
