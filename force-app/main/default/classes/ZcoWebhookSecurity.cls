public with sharing class ZcoWebhookSecurity {
    public static Boolean verify(String rawBody, String suppliedSignature, String sharedSecret) {
        if (String.isBlank(rawBody) || String.isBlank(suppliedSignature) || String.isBlank(sharedSecret)) {
            return false;
        }

        String signature = suppliedSignature.trim();
        if (signature.startsWithIgnoreCase('sha256=')) {
            signature = signature.substringAfter('=');
        }

        String expectedSignature = EncodingUtil.convertToHex(
            Crypto.generateMac('HMACSHA256', Blob.valueOf(rawBody), Blob.valueOf(sharedSecret))
        );

        return String.equalsIgnoreCase(signature, expectedSignature);
    }

    public static Boolean verify(Map<String, String> headers, String rawBody, String sharedSecret, Integer maxAgeMinutes) {
        if (headers == null || String.isBlank(rawBody) || String.isBlank(sharedSecret)) {
            return false;
        }

        String signature = headers.get('x-zco-signature');
        String timestamp = headers.get('x-zco-timestamp');
        if (String.isBlank(signature) || String.isBlank(timestamp)) {
            return false;
        }

        try {
            Long epochSeconds = Long.valueOf(timestamp);
            Long ageInMinutes = (DateTime.now().getTime() / 1000 - epochSeconds) / 60;
            if (Math.abs(ageInMinutes) > (maxAgeMinutes == null ? 5 : maxAgeMinutes)) {
                return false;
            }
        } catch (Exception e) {
            return false;
        }

        return verify(rawBody, signature, sharedSecret);
    }
}
