import { LightningElement, track } from 'lwc';

export default class LibraryApp extends LightningElement {
    @track activeTab = 'dashboard';

    handleTabChange(event) {
        this.activeTab = event.target.value;
    }
}
