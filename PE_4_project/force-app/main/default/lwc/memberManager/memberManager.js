import { LightningElement, wire, track } from 'lwc';
import getMembers from '@salesforce/apex/LibraryController.getMembers';
import deleteMember from '@salesforce/apex/LibraryController.deleteMember';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Name', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'Email', fieldName: 'Email__c', type: 'email' },
    { label: 'Phone', fieldName: 'Phone__c', type: 'phone' },
    { label: 'Membership Date', fieldName: 'Membership_Date__c', type: 'date' },
    { label: 'Status', fieldName: 'Membership_Status__c', type: 'text' },
    { label: 'Books Issued', fieldName: 'Books_Issued__c', type: 'number' },
    {
        type: 'action',
        typeAttributes: {
            rowActions: [
                { label: 'Edit', name: 'edit' },
                { label: 'Delete', name: 'delete' }
            ]
        }
    }
];

export default class MemberManager extends LightningElement {
    @track members = [];
    @track filteredMembers = [];
    @track searchKey = '';
    @track showModal = false;
    @track editRecordId = null;
    @track modalTitle = 'Add New Member';

    columns = COLUMNS;
    wiredMembersResult;

    get hasMembers() {
        return this.filteredMembers && this.filteredMembers.length > 0;
    }

    get memberCount() {
        return this.filteredMembers ? this.filteredMembers.length : 0;
    }

    @wire(getMembers)
    wiredMembers(result) {
        this.wiredMembersResult = result;
        if (result.data) {
            this.members = [...result.data];
            this.applyFilter();
        } else if (result.error) {
            this.showToast('Error', 'Failed to load members', 'error');
        }
    }

    handleSearch(event) {
        this.searchKey = event.target.value;
        this.applyFilter();
    }

    applyFilter() {
        const key = (this.searchKey || '').toLowerCase();
        if (!key) {
            this.filteredMembers = [...this.members];
        } else {
            this.filteredMembers = this.members.filter(m =>
                (m.Name && m.Name.toLowerCase().includes(key)) ||
                (m.Email__c && m.Email__c.toLowerCase().includes(key))
            );
        }
    }

    openAddModal() {
        this.editRecordId = null;
        this.modalTitle = 'Add New Member';
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
        this.editRecordId = null;
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;

        switch (action.name) {
            case 'edit':
                this.editRecordId = row.Id;
                this.modalTitle = 'Edit Member';
                this.showModal = true;
                break;
            case 'delete':
                this.handleDelete(row.Id);
                break;
            default:
                break;
        }
    }

    handleDelete(memberId) {
        deleteMember({ memberId })
            .then(() => {
                this.showToast('Success', 'Member deleted successfully', 'success');
                return refreshApex(this.wiredMembersResult);
            })
            .catch(error => {
                this.showToast('Error', error.body?.message || 'Failed to delete member', 'error');
            });
    }

    handleSaveSuccess() {
        this.showToast('Success', 'Member saved successfully', 'success');
        this.closeModal();
        refreshApex(this.wiredMembersResult);
    }

    handleSaveError(event) {
        this.showToast('Error', event.detail?.message || 'Failed to save member', 'error');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
