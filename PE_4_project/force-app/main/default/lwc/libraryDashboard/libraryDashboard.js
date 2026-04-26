import { LightningElement, wire, track } from 'lwc';
import getDashboardStats from '@salesforce/apex/LibraryController.getDashboardStats';
import getRecentActivity from '@salesforce/apex/LibraryController.getRecentActivity';
import { refreshApex } from '@salesforce/apex';

const ACTIVITY_COLUMNS = [
    { label: 'Issue #', fieldName: 'Name', type: 'text' },
    { label: 'Book', fieldName: 'bookName', type: 'text' },
    { label: 'Member', fieldName: 'memberName', type: 'text' },
    { label: 'Issue Date', fieldName: 'Issue_Date__c', type: 'date' },
    { label: 'Due Date', fieldName: 'Due_Date__c', type: 'date' },
    { label: 'Return Date', fieldName: 'Return_Date__c', type: 'date' },
    {
        label: 'Status', fieldName: 'Issue_Status__c', type: 'text',
        cellAttributes: {
            class: { fieldName: 'statusClass' }
        }
    },
    {
        label: 'Fine', fieldName: 'Fine_Amount__c', type: 'currency',
        typeAttributes: { currencyCode: 'INR' }
    }
];

export default class LibraryDashboard extends LightningElement {
    @track totalBooks = 0;
    @track totalMembers = 0;
    @track activeMembers = 0;
    @track booksIssued = 0;
    @track overdueBooks = 0;
    @track totalCategories = 0;
    @track availableCopies = 0;
    @track totalFineCollected = 0;
    @track recentActivity = [];

    activityColumns = ACTIVITY_COLUMNS;
    wiredStatsResult;
    wiredActivityResult;

    get hasRecentActivity() {
        return this.recentActivity && this.recentActivity.length > 0;
    }

    @wire(getDashboardStats)
    wiredStats(result) {
        this.wiredStatsResult = result;
        if (result.data) {
            this.totalBooks = result.data.totalBooks || 0;
            this.totalMembers = result.data.totalMembers || 0;
            this.activeMembers = result.data.activeMembers || 0;
            this.booksIssued = result.data.booksIssued || 0;
            this.overdueBooks = result.data.overdueBooks || 0;
            this.totalCategories = result.data.totalCategories || 0;
            this.availableCopies = result.data.availableCopies || 0;
            this.totalFineCollected = result.data.totalFineCollected || 0;
        }
    }

    @wire(getRecentActivity)
    wiredActivity(result) {
        this.wiredActivityResult = result;
        if (result.data) {
            this.recentActivity = result.data.map(item => ({
                ...item,
                bookName: item.Book__r ? item.Book__r.Name : '',
                memberName: item.Member__r ? item.Member__r.Name : '',
                statusClass: item.Issue_Status__c === 'Overdue' ? 'slds-text-color_error' :
                             item.Issue_Status__c === 'Returned' ? 'slds-text-color_success' : ''
            }));
        }
    }

    refreshData() {
        refreshApex(this.wiredStatsResult);
        refreshApex(this.wiredActivityResult);
    }
}
