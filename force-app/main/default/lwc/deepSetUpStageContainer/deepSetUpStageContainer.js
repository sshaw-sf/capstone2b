import { LightningElement, api } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from "lightning/actions";
import getInterviewers from '@salesforce/apex/InterviewStageGenerator.getInterviewers';
import getQuestions from '@salesforce/apex/InterviewStageGenerator.getQuestions';
import insertInterviewQuestions from '@salesforce/apex/InterviewStageGenerator.insertInterviewQuestions';
import insertPossibleInterviewers from '@salesforce/apex/InterviewStageGenerator.insertPossibleInterviewers';

export default class DeepSetUpStageContainer extends LightningElement {
    @api recordId;
    stageName; 
    stageId;
    numInterviewers=1;
    interviewerOptions;
    questionOptions
    interviewersSelected = [];
    questionsSelected = [];
    filteredUserOptions= [];
    filteredQuestionOptions= [];

    mapUserNameToId = new Map();
    mapQuestionToNameToId = new Map();

    connectedCallback() {
        getInterviewers().then(profiles => {
            let interviewers = [];

            profiles.forEach(profile => {
                profile.Users.forEach(user => {
                    interviewers.push({ 
                        label : user.FirstName + ' ' + user.LastName,
                        value : user.Id
                    });
                    this.mapUserNameToId.set(user.Id, user.FirstName + ' ' + user.LastName);
                })
            })
            this.interviewerOptions = interviewers;
            this.filterUsers();
        });

        getQuestions().then(questions => {
            let questionBank = [];
            questions.forEach(question => {
                questionBank.push({
                    label: question.Name,
                    value : question.Id
                });
                this.mapQuestionToNameToId.set(question.Id, question.Name);
            })

            this.questionOptions = questionBank;
            this.filterQuestions();
        })
    }

    handleStageNameChange(event){
        this.stageName = event.detail.value;
    }

    handleNumInterviewersChange(event){
        this.numInterviewers = event.detail.value;
    }

    handleInterviewersSelected(event){
        this.interviewersSelected = [...event.detail.value];
    }

    handleQuestionsSelected(event){
        this.questionsSelected = [...event.detail.value]; 
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

    deepCreateStage(){
        if(this.isInputValid()) {
            let stageFields = {'Name' : this.stageName,
                                'Job_Posting__c' : this.recordId,
                                'Number_Of_Interviewers__c' : this.numInterviewers};

            let stageRecordInput = {'apiName' : 'Interview_Stage__c', 'fields' : stageFields};

            createRecord(stageRecordInput).then(response => {
                this.stageId = response.id;

                insertPossibleInterviewers({stageId : this.stageId, possibleInterviewers : this.interviewersSelected})
                    .catch(error => {
                        this.handleError(error, 'Error inserting possible interviewers');
                    });

                insertInterviewQuestions({stageId : this.stageId, questions: this.questionsSelected})
                    .catch(error => {
                        this.handleError(error, 'Error inserting interview questions');
                    });

                this.dispatchEvent(new CloseActionScreenEvent());

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Interview stage and logistics created',
                        variant: 'success'
                    })
                );

                this.updateRecordView()
            }).catch(error => {
                this.handleError(error, 'Error creating deep stage set up');
            });
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

    updateRecordView(){
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 1000);
    }

    filter(event, selectedValues, mapToGetIds, options) {
        let filter = event? 
          new RegExp(event.detail.value, 'ig'):
          { test: function() { return true }}

        const selected = [];
        selectedValues.forEach(value => {
            selected.push(mapToGetIds.get(value));
        });
        let filteredOptions = options.filter(option => (filter.test(option.label) || selected.includes(option.label)));
        return filteredOptions;
    }

    filterUsers(event) {
        let filteredOptions = this.filter(event, this.interviewersSelected, this.mapUserNameToId, this.interviewerOptions);
        this.filteredUserOptions = filteredOptions;
    }

    filterQuestions(event) {
        let filteredOptions = this.filter(event, this.questionsSelected, this.mapQuestionToNameToId, this.questionOptions);
        this.filteredQuestionOptions = filteredOptions;
    }

}