import { LightningElement, api } from 'lwc';

export default class ApproveOrRejectTimesheetsTable extends LightningElement {
    @api timesheets;
    selectedTimesheets = [];

    columns = [
        { label: 'Name', fieldName: 'Name'},
        { label: 'Status', fieldName: 'Timesheet_Status__c' },
        { label: 'Times Rejected', fieldName: 'Rejected_Count__c'}
    ];

    handleRowSelection(event) {
        let selectedRows = event.detail.selectedRows;
        console.log(JSON.stringify(selectedRows));

        this.selectedTimesheets = selectedRows;
    }

    get isButtonDisabled(){
        return !this.selectedTimesheets.length;
    }

    rejectSelectedTimesheets(){
        console.log('firing event');
        let eventPayload = {
            timesheets: this.selectedTimesheets
        };

        const rejectTimesheetsEvent = new CustomEvent('rejecttimesheets', {
            detail: eventPayload
        });

        this.dispatchEvent(rejectTimesheetsEvent);
    }

    approveSelectedTimesheets(){
        let eventPayload = {
            timesheets: this.selectedTimesheets
        };

        const approveTimesheetsEvent = new CustomEvent('approvetimesheets', {
            detail: eventPayload
        });

        this.dispatchEvent(approveTimesheetsEvent);

    }

}