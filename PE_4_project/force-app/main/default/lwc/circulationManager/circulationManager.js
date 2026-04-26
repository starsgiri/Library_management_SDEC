import { LightningElement, wire, track } from 'lwc';
import issueBook from '@salesforce/apex/LibraryController.issueBook';
import returnBook from '@salesforce/apex/LibraryController.returnBook';
import getActiveIssues from '@salesforce/apex/LibraryController.getActiveIssues';
import getBookIssues from '@salesforce/apex/LibraryController.getBookIssues';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const ACTIVE_COLUMNS = [
    { label: 'Issue #', fieldName: 'Name', type: 'text' },
    { label: 'Book Title', fieldName: 'bookName', type: 'text' },
    { label: 'ISBN', fieldName: 'bookISBN', type: 'text' },
    { label: 'Member', fieldName: 'memberName', type: 'text' },
    { label: 'Issue Date', fieldName: 'Issue_Date__c', type: 'date' },
    { label: 'Due Date', fieldName: 'Due_Date__c', type: 'date' },
    { label: 'Status', fieldName: 'Issue_Status__c', type: 'text' },
    {
        type: 'action',
        typeAttributes: {
            rowActions: [
                { label: 'Return Book', name: 'return' }
            ]
        }
    }
];

const HISTORY_COLUMNS = [
    { label: 'Issue #', fieldName: 'Name', type: 'text' },
    { label: 'Book Title', fieldName: 'bookName', type: 'text' },
    { label: 'Member', fieldName: 'memberName', type: 'text' },
    { label: 'Issue Date', fieldName: 'Issue_Date__c', type: 'date' },
    { label: 'Due Date', fieldName: 'Due_Date__c', type: 'date' },
    { label: 'Return Date', fieldName: 'Return_Date__c', type: 'date' },
    { label: 'Status', fieldName: 'Issue_Status__c', type: 'text' },
    {
        label: 'Fine', fieldName: 'Fine_Amount__c', type: 'currency',
        typeAttributes: { currencyCode: 'INR' }
    }
];

export default class CirculationManager extends LightningElement {
    @track selectedBookId = null;
    @track selectedMemberId = null;
    @track activeIssues = [];
    @track allIssues = [];

    activeColumns = ACTIVE_COLUMNS;
    historyColumns = HISTORY_COLUMNS;
    wiredActiveResult;
    wiredHistoryResult;

    get isIssueDisabled() {
        return !this.selectedBookId || !this.selectedMemberId;
    }

    get hasActiveIssues() {
        return this.activeIssues && this.activeIssues.length > 0;
    }

    get hasHistory() {
        return this.allIssues && this.allIssues.length > 0;
    }

    get activeCount() {
        return this.activeIssues ? this.activeIssues.length : 0;
    }

    get historyCount() {
        return this.allIssues ? this.allIssues.length : 0;
    }

    @wire(getActiveIssues)
    wiredActive(result) {
        this.wiredActiveResult = result;
        if (result.data) {
            this.activeIssues = result.data.map(i => this.flattenIssue(i));
        }
    }

    @wire(getBookIssues)
    wiredHistory(result) {
        this.wiredHistoryResult = result;
        if (result.data) {
            this.allIssues = result.data.map(i => this.flattenIssue(i));
        }
    }

    flattenIssue(issue) {
        return {
            ...issue,
            bookName: issue.Book__r ? issue.Book__r.Name : '',
            bookISBN: issue.Book__r ? issue.Book__r.ISBN__c : '',
            memberName: issue.Member__r ? issue.Member__r.Name : '',
            memberEmail: issue.Member__r ? issue.Member__r.Email__c : ''
        };
    }

    handleBookSelect(event) {
        this.selectedBookId = event.detail.recordId;
    }

    handleMemberSelect(event) {
        this.selectedMemberId = event.detail.recordId;
    }

    handleIssueBook() {
        if (!this.selectedBookId || !this.selectedMemberId) return;

        issueBook({ bookId: this.selectedBookId, memberId: this.selectedMemberId })
            .then(result => {
                this.showToast('Success', 'Book issued successfully! Due: ' +
                    new Date(result.Due_Date__c).toLocaleDateString(), 'success');
                this.selectedBookId = null;
                this.selectedMemberId = null;
                this.refreshData();
            })
            .catch(error => {
                this.showToast('Error', error.body?.message || 'Failed to issue book', 'error');
            });
    }

    handleReturnAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;

        if (action.name === 'return') {
            returnBook({ issueId: row.Id })
                .then(result => {
                    let msg = 'Book returned successfully!';
                    if (result.Fine_Amount__c > 0) {
                        msg += ' Fine: ₹' + result.Fine_Amount__c;
                    }
                    this.showToast('Success', msg, 'success');
                    this.refreshData();
                })
                .catch(error => {
                    this.showToast('Error', error.body?.message || 'Failed to return book', 'error');
                });
        }
    }

    refreshData() {
        refreshApex(this.wiredActiveResult);
        refreshApex(this.wiredHistoryResult);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
