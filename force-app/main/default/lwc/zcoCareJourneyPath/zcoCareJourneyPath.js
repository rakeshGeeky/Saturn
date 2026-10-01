import { LightningElement, api, wire } from 'lwc';
import getCareJourneyCard from '@salesforce/apex/ZcoCareLoopController.getCareJourneyCard';

export default class ZcoCareJourneyPath extends LightningElement {
    @api recordId;
    journeyCard;
    error;

    @wire(getCareJourneyCard, { journeyId: '$recordId' })
    wiredJourneyCard({ data, error }) {
        if (data) {
            this.journeyCard = data;
            this.error = undefined;
        } else if (error) {
            this.journeyCard = undefined;
            this.error = error;
        }
    }

    get patientName() {
        return this.journeyCard?.patientName || 'Patient';
    }

    get statusText() {
        return this.journeyCard?.journeyStatus || 'No active journey';
    }
}
