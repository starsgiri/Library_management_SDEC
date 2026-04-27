/**
 * ─────────────────────────────────────────────────────────────
 * LibraryController.cls
 * Main Apex controller for the Library Management System LWC.
 * Provides @AuraEnabled methods for CRUD operations on Books,
 * Members, Book Issues, and Dashboard statistics.
 * ─────────────────────────────────────────────────────────────
 */
public with sharing class LibraryController {

    // ───────────────────────── DASHBOARD ─────────────────────────

    /**
     * Returns aggregate dashboard statistics for the library.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new Map<String, Object>();

        stats.put('totalBooks', [SELECT COUNT() FROM Book__c]);
        stats.put('totalMembers', [SELECT COUNT() FROM Library_Member__c]);
        stats.put('activeMembers', [SELECT COUNT() FROM Library_Member__c WHERE Membership_Status__c = 'Active']);
        stats.put('booksIssued', [SELECT COUNT() FROM Book_Issue__c WHERE Issue_Status__c = 'Issued']);
        stats.put('overdueBooks', [SELECT COUNT() FROM Book_Issue__c WHERE Issue_Status__c = 'Overdue']);
        stats.put('totalCategories', [SELECT COUNT() FROM Book_Category__c]);

        // Total available copies
        AggregateResult[] availAgg = [SELECT SUM(Available_Copies__c) avail FROM Book__c];
        stats.put('availableCopies', availAgg[0].get('avail') != null ? availAgg[0].get('avail') : 0);

        // Total fine collected
        AggregateResult[] fineAgg = [SELECT SUM(Fine_Amount__c) fine FROM Book_Issue__c WHERE Issue_Status__c = 'Returned'];
        stats.put('totalFineCollected', fineAgg[0].get('fine') != null ? fineAgg[0].get('fine') : 0);

        return stats;
    }

    // ───────────────────────── CATEGORIES ─────────────────────────

    /**
     * Returns all book categories.
     */
    @AuraEnabled(cacheable=true)
    public static List<Book_Category__c> getCategories() {
        return [SELECT Id, Name, Description__c FROM Book_Category__c ORDER BY Name ASC];
    }

    /**
     * Creates or updates a book category.
     */
    @AuraEnabled
    public static Book_Category__c saveCategory(String categoryJson) {
        Book_Category__c cat = (Book_Category__c) JSON.deserialize(categoryJson, Book_Category__c.class);
        upsert cat;
        return cat;
    }

    /**
     * Deletes a book category by Id.
     */
    @AuraEnabled
    public static void deleteCategory(Id categoryId) {
        delete [SELECT Id FROM Book_Category__c WHERE Id = :categoryId];
    }

    // ───────────────────────── BOOKS ─────────────────────────

    /**
     * Returns all books with related category information.
     */
    @AuraEnabled(cacheable=true)
    public static List<Book__c> getBooks() {
        return [
            SELECT Id, Name, Author__c, ISBN__c, Publisher__c, Publication_Year__c,
                   Total_Copies__c, Available_Copies__c, Status__c,
                   Category__c, Category__r.Name
            FROM Book__c
            ORDER BY Name ASC
        ];
    }

    /**
     * Searches books by title, author, or ISBN.
     */
    @AuraEnabled(cacheable=true)
    public static List<Book__c> searchBooks(String searchKey) {
        String key = '%' + String.escapeSingleQuotes(searchKey) + '%';
        return [
            SELECT Id, Name, Author__c, ISBN__c, Publisher__c, Publication_Year__c,
                   Total_Copies__c, Available_Copies__c, Status__c,
                   Category__c, Category__r.Name
            FROM Book__c
            WHERE Name LIKE :key OR Author__c LIKE :key OR ISBN__c LIKE :key
            ORDER BY Name ASC
            LIMIT 100
        ];
    }

    /**
     * Creates or updates a book record.
     */
    @AuraEnabled
    public static Book__c saveBook(String bookJson) {
        Book__c book = (Book__c) JSON.deserialize(bookJson, Book__c.class);
        upsert book;
        return book;
    }

    /**
     * Deletes a book by Id.
     */
    @AuraEnabled
    public static void deleteBook(Id bookId) {
        delete [SELECT Id FROM Book__c WHERE Id = :bookId];
    }

    // ───────────────────────── MEMBERS ─────────────────────────

    /**
     * Returns all library members.
     */
    @AuraEnabled(cacheable=true)
    public static List<Library_Member__c> getMembers() {
        return [
            SELECT Id, Name, Email__c, Phone__c, Membership_Date__c,
                   Membership_Status__c, Address__c, Books_Issued__c
            FROM Library_Member__c
            ORDER BY Name ASC
        ];
    }

    /**
     * Searches members by name or email.
     */
    @AuraEnabled(cacheable=true)
    public static List<Library_Member__c> searchMembers(String searchKey) {
        String key = '%' + String.escapeSingleQuotes(searchKey) + '%';
        return [
            SELECT Id, Name, Email__c, Phone__c, Membership_Date__c,
                   Membership_Status__c, Address__c, Books_Issued__c
            FROM Library_Member__c
            WHERE Name LIKE :key OR Email__c LIKE :key
            ORDER BY Name ASC
            LIMIT 100
        ];
    }

    /**
     * Creates or updates a library member.
     */
    @AuraEnabled
    public static Library_Member__c saveMember(String memberJson) {
        Library_Member__c member = (Library_Member__c) JSON.deserialize(memberJson, Library_Member__c.class);
        upsert member;
        return member;
    }

    /**
     * Deletes a member by Id.
     */
    @AuraEnabled
    public static void deleteMember(Id memberId) {
        delete [SELECT Id FROM Library_Member__c WHERE Id = :memberId];
    }

    // ───────────────────────── BOOK ISSUES (CIRCULATION) ─────────────────────────

    /**
     * Returns all book issues with related Book and Member data.
     */
    @AuraEnabled(cacheable=true)
    public static List<Book_Issue__c> getBookIssues() {
        return [
            SELECT Id, Name, Book__c, Book__r.Name, Book__r.ISBN__c,
                   Member__c, Member__r.Name, Member__r.Email__c,
                   Issue_Date__c, Due_Date__c, Return_Date__c,
                   Issue_Status__c, Fine_Amount__c, Renewal_Count__c
            FROM Book_Issue__c
            ORDER BY Issue_Date__c DESC
            LIMIT 200
        ];
    }

    /**
     * Returns only active (Issued/Overdue) book issues.
     */
    @AuraEnabled(cacheable=true)
    public static List<Book_Issue__c> getActiveIssues() {
        return [
            SELECT Id, Name, Book__c, Book__r.Name, Book__r.ISBN__c,
                   Member__c, Member__r.Name, Member__r.Email__c,
                   Issue_Date__c, Due_Date__c, Return_Date__c,
                   Issue_Status__c, Fine_Amount__c, Renewal_Count__c
            FROM Book_Issue__c
            WHERE Issue_Status__c IN ('Issued', 'Overdue')
            ORDER BY Due_Date__c ASC
        ];
    }

    /**
     * Syncs issue status for overdue records.
     */
    @AuraEnabled
    public static Integer syncOverdueIssues() {
        List<Book_Issue__c> overdueIssues = [
            SELECT Id, Issue_Status__c, Due_Date__c
            FROM Book_Issue__c
            WHERE Issue_Status__c = 'Issued' AND Due_Date__c < :Date.today()
            FOR UPDATE
        ];

        for (Book_Issue__c issue : overdueIssues) {
            issue.Issue_Status__c = 'Overdue';
        }

        if (!overdueIssues.isEmpty()) {
            update overdueIssues;
        }

        return overdueIssues.size();
    }

    /**
     * Renews an issued book by extending due date by 7 days.
     * Allows maximum 2 renewals.
     */
    @AuraEnabled
    public static Book_Issue__c renewBook(Id issueId) {
        Book_Issue__c issue = [
            SELECT Id, Due_Date__c, Issue_Status__c, Renewal_Count__c
            FROM Book_Issue__c
            WHERE Id = :issueId
            FOR UPDATE
        ];

        if (issue.Issue_Status__c != 'Issued') {
            throw new AuraHandledException('Only issued books can be renewed.');
        }

        Integer renewalCount = issue.Renewal_Count__c == null ? 0 : issue.Renewal_Count__c.intValue();
        if (renewalCount >= 2) {
            throw new AuraHandledException('Maximum renewal limit reached (2).');
        }

        issue.Due_Date__c = issue.Due_Date__c.addDays(7);
        issue.Renewal_Count__c = renewalCount + 1;
        update issue;

        return issue;
    }

    /**
     * Issues a book to a member.
     * - Validates book availability
     * - Validates member status
     * - Decrements available copies
     * - Sets due date to 14 days from today
     */
    @AuraEnabled
    public static Book_Issue__c issueBook(Id bookId, Id memberId) {
        // Validate book availability
        Book__c book = [
            SELECT Id, Name, Available_Copies__c, Total_Copies__c, Status__c
            FROM Book__c WHERE Id = :bookId FOR UPDATE
        ];

        if (book.Available_Copies__c <= 0) {
            throw new AuraHandledException('This book has no available copies for issue.');
        }

        // Validate member status
        Library_Member__c member = [
            SELECT Id, Name, Membership_Status__c, Books_Issued__c
            FROM Library_Member__c WHERE Id = :memberId
        ];

        if (member.Membership_Status__c != 'Active') {
            throw new AuraHandledException('Member "' + member.Name + '" does not have an active membership.');
        }

        if (member.Books_Issued__c >= 5) {
            throw new AuraHandledException('Member "' + member.Name + '" has already reached the maximum limit of 5 books.');
        }

        // Check for duplicate active issue
        List<Book_Issue__c> existingIssues = [
            SELECT Id FROM Book_Issue__c
            WHERE Book__c = :bookId AND Member__c = :memberId AND Issue_Status__c = 'Issued'
        ];

        if (!existingIssues.isEmpty()) {
            throw new AuraHandledException('This book is already issued to this member.');
        }

        // Create the issue record
        Book_Issue__c issue = new Book_Issue__c();
        issue.Book__c = bookId;
        issue.Member__c = memberId;
        issue.Issue_Date__c = Date.today();
        issue.Due_Date__c = Date.today().addDays(14);
        issue.Issue_Status__c = 'Issued';
        issue.Fine_Amount__c = 0;
        issue.Renewal_Count__c = 0;
        insert issue;

        // Update book available copies
        book.Available_Copies__c = book.Available_Copies__c - 1;
        if (book.Available_Copies__c == 0) {
            book.Status__c = 'Checked Out';
        }
        update book;

        // Update member books issued count
        member.Books_Issued__c = member.Books_Issued__c + 1;
        update member;

        return issue;
    }

    /**
     * Returns a book.
     * - Calculates fine if overdue (Rs. 5 per day)
     * - Increments available copies
     * - Updates member books issued count
     */
    @AuraEnabled
    public static Book_Issue__c returnBook(Id issueId) {
        Book_Issue__c issue = [
            SELECT Id, Book__c, Member__c, Issue_Date__c, Due_Date__c,
                   Return_Date__c, Issue_Status__c, Fine_Amount__c
            FROM Book_Issue__c WHERE Id = :issueId FOR UPDATE
        ];

        if (issue.Issue_Status__c == 'Returned') {
            throw new AuraHandledException('This book has already been returned.');
        }

        // Set return date and calculate fine
        issue.Return_Date__c = Date.today();
        issue.Issue_Status__c = 'Returned';

        if (Date.today() > issue.Due_Date__c) {
            Integer daysLate = issue.Due_Date__c.daysBetween(Date.today());
            issue.Fine_Amount__c = daysLate * 5; // Rs. 5 per day
        }

        update issue;

        // Update book available copies
        Book__c book = [SELECT Id, Available_Copies__c, Status__c FROM Book__c WHERE Id = :issue.Book__c FOR UPDATE];
        book.Available_Copies__c = book.Available_Copies__c + 1;
        book.Status__c = 'Available';
        update book;

        // Update member books issued count
        Library_Member__c member = [SELECT Id, Books_Issued__c FROM Library_Member__c WHERE Id = :issue.Member__c];
        member.Books_Issued__c = Math.max(0, member.Books_Issued__c - 1);
        update member;

        return issue;
    }

    /**
     * Returns recent activity for the dashboard – last 10 issue transactions.
     */
    @AuraEnabled(cacheable=true)
    public static List<Book_Issue__c> getRecentActivity() {
        return [
            SELECT Id, Name, Book__r.Name, Member__r.Name,
                   Issue_Date__c, Due_Date__c, Return_Date__c,
                   Issue_Status__c, Fine_Amount__c
            FROM Book_Issue__c
            ORDER BY CreatedDate DESC
            LIMIT 10
        ];
    }
}
