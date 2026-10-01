import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getSnapshot from '@salesforce/apex/ZcoPatientSnapshotController.getSnapshot';

export default class ZcoPatientSnapshot extends LightningElement {
    @api recordId;

    snapshot;
    error;
    wiredSnapshot;
    isRefreshing = false;

    @wire(getSnapshot, { accountId: '$recordId' })
    wiredPatientSnapshot(result) {
        this.wiredSnapshot = result;
        if (result.data) {
            this.snapshot = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.snapshot = undefined;
        }
    }

    get isLoading() {
        return Boolean(this.recordId) && !this.snapshot && !this.error;
    }

    get hasObservations() {
        return Boolean(this.snapshot?.observations?.length);
    }

    get hasMedications() {
        return Boolean(this.snapshot?.medications?.length);
    }

    get errorMessage() {
        return this.error?.body?.message || 'Verified clinical data is unavailable. Check clinical permission-set access.';
    }

    async handleRefresh() {
        if (!this.wiredSnapshot || this.isRefreshing) {
            return;
        }
        this.isRefreshing = true;
        try {
            await refreshApex(this.wiredSnapshot);
        } catch (error) {
            this.error = error;
            this.snapshot = undefined;
        } finally {
            this.isRefreshing = false;
        }
    }
}
