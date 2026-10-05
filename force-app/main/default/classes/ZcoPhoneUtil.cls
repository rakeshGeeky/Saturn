public with sharing class ZcoPhoneUtil {
    public static String normalizeMobile(String rawValue) {
        if (String.isBlank(rawValue)) {
            return null;
        }
        String digits = rawValue.replaceAll('[^0-9]', '');
        if (String.isBlank(digits)) {
            return null;
        }
        if (digits.startsWith('91') && digits.length() == 12) {
            return '+' + digits;
        }
        if (digits.length() == 10) {
            return '+91' + digits;
        }
        if (digits.length() == 12 && digits.startsWith('0')) {
            return '+' + digits.substring(1);
        }
        return '+' + digits;
    }
}