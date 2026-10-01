import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import getDashboard from '@salesforce/apex/ZcoCareDashboardController.getDashboard';

const COLUMNS = [
    {
        label: 'Care journey',
        fieldName: 'journeyUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'name' }, target: '_self' }
    },
    {
        label: 'Patient',
        fieldName: 'patientUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'patientName' }, target: '_self' }
    },
    { label: 'Status', fieldName: 'status', type: 'text' },
    { label: 'Next due', fieldName: 'nextDueDate', type: 'date-local' },
    { label: 'Attempts', fieldName: 'attempts', type: 'number' },
    {
        label: 'Last outreach',
        fieldName: 'lastOutreachAt',
        type: 'date',
        typeAttributes: {
            year: 'numeric',
            month: 'short',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit'
        }
    }
];

const STATUS_OPTIONS = [
    { label: 'All open statuses', value: 'All' },
    { label: 'Care plan active', value: 'Care plan active' },
    { label: 'Due', value: 'Due' },
    { label: 'Outreach sent', value: 'Outreach sent' },
    { label: 'Scheduled', value: 'Scheduled' },
    { label: 'Snoozed', value: 'Snoozed' },
    { label: 'Lost to follow-up', value: 'Lost to follow-up' }
];

export default class ZcoCareWorkbench extends NavigationMixin(LightningElement) {
    columns = COLUMNS;
    statusOptions = STATUS_OPTIONS;
    statusFilter = 'All';
    dashboard;
    wiredDashboard;
    error;
    isRefreshing = false;

    @wire(getDashboard)
    wiredJourneys(result) {
        this.wiredDashboard = result;
        if (result.data) {
            this.dashboard = {
                ...result.data,
                journeys: result.data.journeys.map((journey) => ({
                    ...journey,
                    journeyUrl: `/lightning/r/Care_Journey__c/${journey.id}/view`,
                    patientUrl: journey.patientId
                        ? `/lightning/r/Account/${journey.patientId}/view`
                        : null
                }))
            };
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.dashboard = undefined;
        }
    }

    get isLoading() {
        return !this.dashboard && !this.error;
    }

    get hasData() {
        return Boolean(this.dashboard);
    }

    get isEmpty() {
        return this.hasData && this.dashboard.journeys.length === 0;
    }

    get visibleJourneys() {
        if (!this.dashboard) {
            return [];
        }
        if (this.statusFilter === 'All') {
            return this.dashboard.journeys;
        }
        return this.dashboard.journeys.filter((journey) => journey.status === this.statusFilter);
    }

    get hasJourneys() {
        return this.visibleJourneys.length > 0;
    }

    get resultLabel() {
        const count = this.visibleJourneys.length;
        return `${count} ${count === 1 ? 'journey' : 'journeys'}`;
    }

    get errorMessage() {
        return this.error?.body?.message || 'Care journeys could not be loaded. Refresh or contact your Salesforce administrator.';
    }

    handleStatusChange(event) {
        this.statusFilter = event.detail.value;
    }

    async handleRefresh() {
        if (!this.wiredDashboard || this.isRefreshing) {
            return;
        }
        this.isRefreshing = true;
        try {
            await refreshApex(this.wiredDashboard);
        } finally {
            this.isRefreshing = false;
        }
    }
}
