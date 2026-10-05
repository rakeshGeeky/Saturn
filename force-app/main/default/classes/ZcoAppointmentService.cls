public with sharing class ZcoAppointmentService {
    public static String determineAppointmentState(Appointment__c appointment) {
        if (appointment == null) {
            return null;
        }
        if (appointment.Check_In_At__c != null) {
            return 'Completed';
        }
        return String.isBlank(appointment.Status__c) ? 'Scheduled' : appointment.Status__c;
    }

    public static void syncCareJourney(Appointment__c appointment) {
        Care_Journey__c journeyUpdate = buildJourneyUpdate(appointment);
        if (journeyUpdate != null) {
            update journeyUpdate;
        }
    }

    @TestVisible
    private static Care_Journey__c buildJourneyUpdate(Appointment__c appointment) {
        if (appointment == null || appointment.Care_Journey__c == null) {
            return null;
        }
        String appointmentState = determineAppointmentState(appointment);
        if (appointmentState == 'Completed') {
            return new Care_Journey__c(
                Id = appointment.Care_Journey__c,
                Status__c = 'Completed',
                Closed_Reason__c = 'Completed'
            );
        }
        if (appointmentState == 'Scheduled' || appointmentState == 'Confirmed') {
            return new Care_Journey__c(
                Id = appointment.Care_Journey__c,
                Status__c = 'Outreach sent'
            );
        }
        return null;
    }
}