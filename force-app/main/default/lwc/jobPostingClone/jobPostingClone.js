import { LightningElement } from 'lwc';

export default class JobPostingClone extends LightningElement {
    modalShown = false; 
    secondModalShown = false;
    nextShown = true;

    toggleModal() {
        this.modalShown = !this.modalShown;
    }

    toggleCreateStage() {
        this.secondModalShown = !this.secondModalShown;
        this.modalShown = false;
    }

}