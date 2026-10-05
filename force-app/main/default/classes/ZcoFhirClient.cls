public with sharing class ZcoFhirClient {
    public static Map<String, Object> fetchPatient(String mrn) {
        Map<String, Object> result = new Map<String, Object>();
        result.put('patientId', mrn);
        result.put('status', 'history unavailable');
        return result;
    }
}