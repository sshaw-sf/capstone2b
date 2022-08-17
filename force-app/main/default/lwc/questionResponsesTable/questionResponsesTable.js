import { LightningElement, api, wire } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateQuestionResponses from '@salesforce/apex/QuestionResponseGenerator.updateQuestionResponses';

export default class QuestionResponsesTable extends LightningElement {
    @api recordId; 
    draftValues = [];
    questionResponses;

    columns = [
        { label: 'Name', fieldName: 'NameLink', type: 'url', 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
        { label: 'Question', fieldName: 'Question' },
        { label: 'Response', fieldName: 'Response__c', editable: true}
    ];

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'Question_Responses__r',
        fields: ['Question_Response__c.Name', 'Question_Response__c.Question__c', 'Question_Response__c.Response__c']}) 
    relatedQuestionResponses({error, data}) {
        if (data) {
            this.questionResponses = data.records.map(response => {
                return{
                    'Id' : response.id,
                    'NameLink' : '/'+ response.id,
                    'Name' : response.fields.Name.value,
                    'Question' : response.fields.Question__c.value, 
                    'Response__c': response.fields.Response__c.value
                }
            });
        } else if (error) {
            this.handleError(error, 'Error retrieving question responses');
        }
    }

    handleSave(event) {
        this.draftValues = event.detail.draftValues; 

        updateQuestionResponses({data: this.draftValues}).then(result => {

            const notifyChangeIds = this.draftValues.map(row => { return { "recordId": row.Id } });

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Question reponse updated',
                    variant: 'success'
                })
            );
            
            getRecordNotifyChange(notifyChangeIds); 

            this.draftValues = [];
            return refreshApex(this.relatedQuestionResponses.data.records);
        })
        .catch(error => {
            this.handleError(error, 'Error updating or refreshing records');
        });
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

}