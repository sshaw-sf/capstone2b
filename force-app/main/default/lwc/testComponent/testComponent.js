import { LightningElement, api } from 'lwc';

export default class TestComponent extends LightningElement {
    @api recordId; 

    testProperty = 'test';

    connectedCallback() {
        this.testFunction('testInput');
    }
    
    testFunction(input) {
        console.log(input); 
    }
}