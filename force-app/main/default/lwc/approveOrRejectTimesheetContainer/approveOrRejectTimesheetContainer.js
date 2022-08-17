import { LightningElement, api, wire } from 'lwc';
import getRelatedTimesheets from '@salesforce/apex/TimesheetApprovalController.getRelatedTimesheets';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import rejectTimesheets from '@salesforce/apex/TimesheetApprovalController.rejectTimesheets';
import approveTimesheets from '@salesforce/apex/TimesheetApprovalController.approveTimesheets';
import { refreshApex } from '@salesforce/apex';


export default class ApproveOrRejectTimesheetContainer extends LightningElement {
    @api recordId;
    timesheets;
    timesheetsResult; 
    
    @wire(getRelatedTimesheets, { projectId: '$recordId' })
    wiredTimesheets(response) {
        this.timesheetsResult = response; 
        if(response.data) {
            this.timesheets = response.data;
            this.error = undefined;
        } else if(response.error){
            this.error = response.error; 
            this.timesheets = undefined; 
        }
    }
    timesheets;
    modalShown = false;

    connectedCallback() {
        // getRelatedTimesheets( {projectId: this.recordId} )
        //     .then(timesheets => {
        //         console.log(timesheets);
        //         this.timesheets = timesheets;
        //     })
        //     .catch(error => {
        //         console.warn(error);
        //     });
    }

    toggleModal() {
        this.modalShown = !this.modalShown;
    }

    handleSuccess(event){
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success!',
            message: 'Timecard ' + event.detail.id + ' created successfully!',
            variant: {label: 'success', value: 'success'}
        }));
    }

    handleRejectTimesheets(event){
        let timesheetsToBeRejected = event.detail.timesheets;

        console.log('timesheets to be rejected', JSON.parse(JSON.stringify(timesheetsToBeRejected)));

        rejectTimesheets({ timesheets: timesheetsToBeRejected})
            .then(apexResponse => {
                console.log('reject successful');
                return refreshApex(this.timesheetsResult);
            }).catch(error => {
                console.warn(error);
            })
    }

    handleApproveTimesheets(event){
        let timesheetsToBeApproved = event.detail.timesheets;

        approveTimesheets({ timesheets: timesheetsToBeApproved})
            .then(response => {
                console.log('timecards approved successfully');
                return refreshApex(this.timesheetsResult);
            }).catch(error => {
                console.warn(error);
            })
    }


}