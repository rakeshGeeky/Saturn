import { LightningElement, api, wire } from 'lwc';
import getSummary from '@salesforce/apex/ZcoPreConsultSummaryController.getSummary';

export default class ZcoPreConsultSummary extends LightningElement {
    @api recordId;
    summary;
    error;

    @wire(getSummary, { recordId: '$recordId' })
    wiredSummary({ data, error }) {
        if (data) {
            this.summary = data;
            this.error = undefined;
        } else if (error) {
            this.summary = undefined;
            this.error = error;
        } else {
            this.summary = undefined;
            this.error = undefined;
        }
    }

    get hasMedication() {
        return this.summary?.verifiedMedicationNames?.length > 0;
    }

    get hasObservations() {
        return this.summary?.recentObservationLabels?.length > 0;
    }
}