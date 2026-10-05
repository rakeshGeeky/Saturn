import { LightningElement, api, wire } from 'lwc';
import getAccountPatientCard from '@salesforce/apex/ZcoCareLoopController.getAccountPatientCard';

export default class ZcoCallScreenPop extends LightningElement {
    @api recordId;
    patientCard;
    error;

    @wire(getAccountPatientCard, { accountId: '$recordId' })
    wiredPatientCard({ data, error }) {
        if (data) {
            this.patientCard = data;
            this.error = undefined;
        } else if (error) {
            this.patientCard = undefined;
            this.error = error;
        } else {
            this.patientCard = undefined;
            this.error = undefined;
        }
    }

    get patientName() {
        return this.patientCard?.patientName || 'Patient';
    }

    get latestStatus() {
        return this.patientCard?.journeyStatus || 'No active journey';
    }

    get nextDue() {
        return this.patientCard?.nextDueDate || 'Not scheduled';
    }
}
