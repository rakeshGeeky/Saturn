public with sharing class ZcoAppointmentService {
    public static String determineAppointmentState(Appointment__c appointment) {
        if (appointment == null) {
            return 'Pending';
        }

        if (appointment.Check_In_At__c != null) {
            return 'Completed';
        }

        if (appointment.Scheduled_Start__c != null && appointment.Scheduled_Start__c <= Datetime.now()) {
            return 'In Progress';
        }

        return String.isBlank(appointment.Status__c) ? 'Scheduled' : appointment.Status__c;
    }

    public static void syncCareJourney(Appointment__c appointment) {
        if (appointment == null || appointment.Care_Journey__c == null) {
            return;
        }

        String nextState = determineAppointmentState(appointment);
        Care_Journey__c journey = new Care_Journey__c(Id = appointment.Care_Journey__c);

        if (nextState == 'Completed') {
            journey.Status__c = 'Completed';
        } else if (nextState == 'In Progress') {
            journey.Status__c = 'Scheduled';
        } else if (String.isBlank(appointment.Status__c) || appointment.Status__c == 'Scheduled') {
            journey.Status__c = 'Outreach sent';
        }

        update journey;
    }
}
