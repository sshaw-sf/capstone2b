import { LightningElement } from 'lwc';

export default class MyLightningElement extends LightningElement {
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