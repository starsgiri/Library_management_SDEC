import { LightningElement, wire, track } from 'lwc';
import getBooks from '@salesforce/apex/LibraryController.getBooks';
import deleteBook from '@salesforce/apex/LibraryController.deleteBook';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Title', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'Author', fieldName: 'Author__c', type: 'text', sortable: true },
    { label: 'ISBN', fieldName: 'ISBN__c', type: 'text' },
    { label: 'Category', fieldName: 'categoryName', type: 'text' },
    { label: 'Publisher', fieldName: 'Publisher__c', type: 'text' },
    { label: 'Year', fieldName: 'Publication_Year__c', type: 'text' },
    { label: 'Total', fieldName: 'Total_Copies__c', type: 'number' },
    { label: 'Available', fieldName: 'Available_Copies__c', type: 'number' },
    { label: 'Status', fieldName: 'Status__c', type: 'text' },
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

export default class BookManager extends LightningElement {
    @track books = [];
    @track filteredBooks = [];
    @track searchKey = '';
    @track showModal = false;
    @track editRecordId = null;
    @track modalTitle = 'Add New Book';

    columns = COLUMNS;
    wiredBooksResult;

    get hasBooks() {
        return this.filteredBooks && this.filteredBooks.length > 0;
    }

    get bookCount() {
        return this.filteredBooks ? this.filteredBooks.length : 0;
    }

    @wire(getBooks)
    wiredBooks(result) {
        this.wiredBooksResult = result;
        if (result.data) {
            this.books = result.data.map(book => ({
                ...book,
                categoryName: book.Category__r ? book.Category__r.Name : ''
            }));
            this.applyFilter();
        } else if (result.error) {
            this.showToast('Error', 'Failed to load books', 'error');
        }
    }

    handleSearch(event) {
        this.searchKey = event.target.value;
        this.applyFilter();
    }

    applyFilter() {
        const key = (this.searchKey || '').toLowerCase();
        if (!key) {
            this.filteredBooks = [...this.books];
        } else {
            this.filteredBooks = this.books.filter(book =>
                (book.Name && book.Name.toLowerCase().includes(key)) ||
                (book.Author__c && book.Author__c.toLowerCase().includes(key)) ||
                (book.ISBN__c && book.ISBN__c.toLowerCase().includes(key))
            );
        }
    }

    openAddModal() {
        this.editRecordId = null;
        this.modalTitle = 'Add New Book';
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
                this.modalTitle = 'Edit Book';
                this.showModal = true;
                break;
            case 'delete':
                this.handleDelete(row.Id);
                break;
            default:
                break;
        }
    }

    handleDelete(bookId) {
        deleteBook({ bookId })
            .then(() => {
                this.showToast('Success', 'Book deleted successfully', 'success');
                return refreshApex(this.wiredBooksResult);
            })
            .catch(error => {
                this.showToast('Error', error.body?.message || 'Failed to delete book', 'error');
            });
    }

    handleSaveSuccess() {
        this.showToast('Success', 'Book saved successfully', 'success');
        this.closeModal();
        refreshApex(this.wiredBooksResult);
    }

    handleSaveError(event) {
        this.showToast('Error', event.detail?.message || 'Failed to save book', 'error');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
