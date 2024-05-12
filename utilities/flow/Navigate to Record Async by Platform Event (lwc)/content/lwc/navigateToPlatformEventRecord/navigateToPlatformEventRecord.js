import { LightningElement, api } from 'lwc';
import { subscribe, unsubscribe } from 'lightning/empApi';
import { NavigationMixin } from 'lightning/navigation';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';

export default class NavigateToPlatformEventRecord extends NavigationMixin(LightningElement) {
    @api validationId;
    @api channelName;
    @api terminateFlow;

    subscription = {};

    connectedCallback(){
        const messageCallback = (response) => {
            if (response.data.payload.ValidationId__c === this.validationId){
                unsubscribe(this.subscription, (response) => {
                    this.subscription = {};
                });
                if (this.terminateFlow === true){
                    const terminateEvent = new FlowNavigationFinishEvent();
                    this.dispatchEvent(terminateEvent);
                }
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: response.data.payload.NavigateToRecord__c,
                        actionName: 'view',
                    },
                });
            }
        };

        subscribe('/event/' + this.channelName, -1, messageCallback).then((response) => {
            this.subscription = response;
        });
    }
}