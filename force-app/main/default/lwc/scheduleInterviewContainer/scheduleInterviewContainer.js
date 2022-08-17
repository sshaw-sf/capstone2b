import { LightningElement, api, wire } from 'lwc';
import { createRecord, getRecord } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import insertAssignedInterviewers from '@salesforce/apex/InterviewGenerator.insertAssignedInterviewers';
import getInterviewerUsername from '@salesforce/apex/InterviewGenerator.getInterviewerUsername';
import CANDIDATE_FIELD from '@salesforce/schema/Job_Application__c.Candidate__c';
import JOB_FIELD from '@salesforce/schema/Job_Application__c.Job_Posting__c';

export default class ScheduleInterviewContainer extends LightningElement {
    @api recordId; 
    stageOptions;
    stageId;
    interviewerOptions;
    selected;
    interviewerIds;
    users;
    interviewDate;

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [CANDIDATE_FIELD, JOB_FIELD]}) 
    application;

    @wire(getRelatedListRecords, {
        parentRecordId: '$application.data.fields.Job_Posting__c.value',
        relatedListId: 'Interview_Stages__r',
        fields: ['Interview_Stage__c.Name', 'Interview_Stage__c.Id']}) 
    relatedInterviewStages({error, data}) {
        if (data) {
            this.stageOptions = data.records.map(stage => {
                return{
                    label : stage.fields.Name.value,
                    value : stage.id
                }
            });
        } else if(error){
            this.handleError(error, 'Error retrieving interview stages');
        }
    }

    handleStageChange(event) {
        this.stageId = event.detail.value; 
    }

    @wire(getRelatedListRecords, {
        parentRecordId: '$stageId',
        relatedListId: 'Possible_Interviewers__r',
        fields: ['Possible_Interviewer__c.Interviewer__c', 'Possible_Interviewer__c.Name']}) 
    relatedPossibleInterviewers({error, data}) {
        if(data) {
            if(data.records) {
                let ids = data.records.map(interviewer => {
                    return interviewer.fields.Interviewer__c.value; 
                });

                getInterviewerUsername({userIds : ids}).then(u => {
                    this.users = u; 

                    let tempOptions = [];
                    this.users.forEach(u => {
                        tempOptions.push({ 
                            label: u.FirstName + ' ' + u.LastName,
                            value: u.Id
                        });
                    });

                    this.interviewerOptions = tempOptions; 
                }).catch(error => {
                    this.handleError(error,'Error retrieving user information');
                });
            }
        } else if(error){
            this.handleError(error,'Error retrieving possible interviewers');
        }
    }

    handleError(error, title) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: error.body.message,
                variant: 'error'
            })
        );
    }

    handleSelectedChange(event) {
        this.selected = event.detail.value;
    }

    handleDateChange(event) {
        this.interviewDate = event.detail.value;
    }

    createScheduledInterview() {
        if(this.isInputValid()) {
            let interviewFields = {'Job_Application__c' : this.recordId, 
                            'Contact__c' : this.application.data.fields.Candidate__c.value,
                            'Interview_Stage__c' : this.stageId,
                            'Interview_Date__c' : this.interviewDate};

            let interviewRecordInput = {'apiName': 'Interview__c', 'fields' : interviewFields};

            console.log('selected', this.selected);

            createRecord(interviewRecordInput).then(response => {
                console.log('interview id', response.id);
                console.log('call insert assigned', this.selected);
                insertAssignedInterviewers({interviewId: response.id, possibleInterviewers: this.selected})
                    .then(result => console.log('insert called', result))
                    .catch(error => {
                        this.handleError(error, 'Error creating assigned interviewers');
                    })

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Interview and Assigned Interviewers created',
                        variant: 'success'
                    })
                );

                this.clear();
                this.updateRecordView();
            }).catch(error => {
                this.handleError(error, 'Error creating interview record');
            })
        }
    }
        
    isInputValid() {
        let isValid = true; 
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputFields => {
            if(!inputFields.checkValidity()) {
                inputFields.reportValidity();
                isValid = false; 
            }
        });
        return isValid;
    }

    handleCancel(){
        this.clear();
    }

    clear() {
        this.template.querySelector('lightning-input').value = '';
        this.template.querySelector('lightning-dual-listbox').value = '';
        this.interviewerOptions=null;
        this.stageId=null;
    }

    updateRecordView(){
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 1000);
    }

}