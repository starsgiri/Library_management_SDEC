/**
 * ─────────────────────────────────────────────────────────────
 * LibraryControllerTest.cls
 * Test class for LibraryController – covers all CRUD and
 * business logic methods with ≥ 85% code coverage.
 * ─────────────────────────────────────────────────────────────
 */
@isTest
private class LibraryControllerTest {

    @TestSetup
    static void setupTestData() {
        // Create categories
        Book_Category__c fiction = new Book_Category__c(
            Name = 'Fiction',
            Description__c = 'Fiction books'
        );
        Book_Category__c science = new Book_Category__c(
            Name = 'Science',
            Description__c = 'Science books'
        );
        insert new List<Book_Category__c>{ fiction, science };

        // Create books
        Book__c book1 = new Book__c(
            Name = 'The Great Gatsby',
            Author__c = 'F. Scott Fitzgerald',
            ISBN__c = '978-0743273565',
            Publisher__c = 'Scribner',
            Publication_Year__c = '1925',
            Total_Copies__c = 3,
            Available_Copies__c = 3,
            Status__c = 'Available',
            Category__c = fiction.Id
        );
        Book__c book2 = new Book__c(
            Name = 'A Brief History of Time',
            Author__c = 'Stephen Hawking',
            ISBN__c = '978-0553380163',
            Publisher__c = 'Bantam',
            Publication_Year__c = '1988',
            Total_Copies__c = 1,
            Available_Copies__c = 1,
            Status__c = 'Available',
            Category__c = science.Id
        );
        insert new List<Book__c>{ book1, book2 };

        // Create members
        Library_Member__c member1 = new Library_Member__c(
            Name = 'John Doe',
            Email__c = 'john.doe@example.com',
            Phone__c = '1234567890',
            Membership_Date__c = Date.today(),
            Membership_Status__c = 'Active',
            Address__c = '123 Main St',
            Books_Issued__c = 0
        );
        Library_Member__c member2 = new Library_Member__c(
            Name = 'Jane Smith',
            Email__c = 'jane.smith@example.com',
            Phone__c = '0987654321',
            Membership_Date__c = Date.today(),
            Membership_Status__c = 'Inactive',
            Address__c = '456 Oak Ave',
            Books_Issued__c = 0
        );
        insert new List<Library_Member__c>{ member1, member2 };
    }

    // ───── Dashboard Tests ─────

    @isTest
    static void testGetDashboardStats() {
        Test.startTest();
        Map<String, Object> stats = LibraryController.getDashboardStats();
        Test.stopTest();

        System.assertNotEquals(null, stats, 'Stats should not be null');
        System.assertEquals(2, (Integer) stats.get('totalBooks'), 'Should have 2 books');
        System.assertEquals(2, (Integer) stats.get('totalMembers'), 'Should have 2 members');
        System.assertEquals(1, (Integer) stats.get('activeMembers'), 'Should have 1 active member');
        System.assertEquals(2, (Integer) stats.get('totalCategories'), 'Should have 2 categories');
    }

    // ───── Category Tests ─────

    @isTest
    static void testGetCategories() {
        Test.startTest();
        List<Book_Category__c> cats = LibraryController.getCategories();
        Test.stopTest();
        System.assertEquals(2, cats.size(), 'Should return 2 categories');
    }

    @isTest
    static void testSaveCategory() {
        String json = '{"Name":"History","Description__c":"History books"}';
        Test.startTest();
        Book_Category__c cat = LibraryController.saveCategory(json);
        Test.stopTest();
        System.assertNotEquals(null, cat.Id, 'Category should be saved');
        System.assertEquals('History', cat.Name);
    }

    @isTest
    static void testDeleteCategory() {
        Book_Category__c cat = [SELECT Id FROM Book_Category__c WHERE Name = 'Science' LIMIT 1];
        // Remove books from category first
        List<Book__c> books = [SELECT Id, Category__c FROM Book__c WHERE Category__c = :cat.Id];
        for (Book__c b : books) { b.Category__c = null; }
        update books;

        Test.startTest();
        LibraryController.deleteCategory(cat.Id);
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Book_Category__c WHERE Id = :cat.Id]);
    }

    // ───── Book Tests ─────

    @isTest
    static void testGetBooks() {
        Test.startTest();
        List<Book__c> books = LibraryController.getBooks();
        Test.stopTest();
        System.assertEquals(2, books.size(), 'Should return 2 books');
    }

    @isTest
    static void testSearchBooks() {
        Test.startTest();
        List<Book__c> results = LibraryController.searchBooks('Gatsby');
        Test.stopTest();
        System.assertEquals(1, results.size(), 'Should find 1 book');
        System.assertEquals('The Great Gatsby', results[0].Name);
    }

    @isTest
    static void testSaveBook() {
        Book_Category__c cat = [SELECT Id FROM Book_Category__c WHERE Name = 'Fiction' LIMIT 1];
        String json = '{"Name":"1984","Author__c":"George Orwell","ISBN__c":"978-0451524935",' +
            '"Total_Copies__c":2,"Available_Copies__c":2,"Status__c":"Available","Category__c":"' + cat.Id + '"}';

        Test.startTest();
        Book__c book = LibraryController.saveBook(json);
        Test.stopTest();
        System.assertNotEquals(null, book.Id, 'Book should be saved');
    }

    @isTest
    static void testDeleteBook() {
        Book__c book = [SELECT Id FROM Book__c WHERE Name = 'A Brief History of Time' LIMIT 1];
        Test.startTest();
        LibraryController.deleteBook(book.Id);
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Book__c WHERE Id = :book.Id]);
    }

    // ───── Member Tests ─────

    @isTest
    static void testGetMembers() {
        Test.startTest();
        List<Library_Member__c> members = LibraryController.getMembers();
        Test.stopTest();
        System.assertEquals(2, members.size(), 'Should return 2 members');
    }

    @isTest
    static void testSearchMembers() {
        Test.startTest();
        List<Library_Member__c> results = LibraryController.searchMembers('John');
        Test.stopTest();
        System.assertEquals(1, results.size(), 'Should find 1 member');
    }

    @isTest
    static void testSaveMember() {
        String json = '{"Name":"Alice Johnson","Email__c":"alice@example.com",' +
            '"Membership_Date__c":"' + String.valueOf(Date.today()) + '","Membership_Status__c":"Active","Books_Issued__c":0}';

        Test.startTest();
        Library_Member__c member = LibraryController.saveMember(json);
        Test.stopTest();
        System.assertNotEquals(null, member.Id, 'Member should be saved');
    }

    @isTest
    static void testDeleteMember() {
        Library_Member__c member = [SELECT Id FROM Library_Member__c WHERE Name = 'Jane Smith' LIMIT 1];
        Test.startTest();
        LibraryController.deleteMember(member.Id);
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Library_Member__c WHERE Id = :member.Id]);
    }

    // ───── Circulation Tests ─────

    @isTest
    static void testIssueBook() {
        Book__c book = [SELECT Id FROM Book__c WHERE Name = 'The Great Gatsby' LIMIT 1];
        Library_Member__c member = [SELECT Id FROM Library_Member__c WHERE Name = 'John Doe' LIMIT 1];

        Test.startTest();
        Book_Issue__c issue = LibraryController.issueBook(book.Id, member.Id);
        Test.stopTest();

        System.assertNotEquals(null, issue.Id, 'Issue record should be created');
        System.assertEquals('Issued', issue.Issue_Status__c);

        // Verify book copies decreased
        Book__c updatedBook = [SELECT Available_Copies__c FROM Book__c WHERE Id = :book.Id];
        System.assertEquals(2, updatedBook.Available_Copies__c);

        // Verify member count increased
        Library_Member__c updatedMember = [SELECT Books_Issued__c FROM Library_Member__c WHERE Id = :member.Id];
        System.assertEquals(1, updatedMember.Books_Issued__c);
    }

    @isTest
    static void testIssueBookNoAvailableCopies() {
        Book__c book = [SELECT Id FROM Book__c WHERE Name = 'A Brief History of Time' LIMIT 1];
        book.Available_Copies__c = 0;
        update book;

        Library_Member__c member = [SELECT Id FROM Library_Member__c WHERE Name = 'John Doe' LIMIT 1];
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            LibraryController.issueBook(book.Id, member.Id);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'Expected AuraHandledException when no copies are available');
    }

    @isTest
    static void testIssueBookInactiveMember() {
        Book__c book = [SELECT Id FROM Book__c WHERE Name = 'The Great Gatsby' LIMIT 1];
        Library_Member__c member = [SELECT Id FROM Library_Member__c WHERE Name = 'Jane Smith' LIMIT 1];
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            LibraryController.issueBook(book.Id, member.Id);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'Expected AuraHandledException for inactive member');
    }

    @isTest
    static void testReturnBook() {
        // First issue a book
        Book__c book = [SELECT Id FROM Book__c WHERE Name = 'The Great Gatsby' LIMIT 1];
        Library_Member__c member = [SELECT Id FROM Library_Member__c WHERE Name = 'John Doe' LIMIT 1];
        Book_Issue__c issue = LibraryController.issueBook(book.Id, member.Id);

        Test.startTest();
        Book_Issue__c returnedIssue = LibraryController.returnBook(issue.Id);
        Test.stopTest();

        System.assertEquals('Returned', returnedIssue.Issue_Status__c);
        System.assertEquals(Date.today(), returnedIssue.Return_Date__c);

        // Verify book copies restored
        Book__c updatedBook = [SELECT Available_Copies__c FROM Book__c WHERE Id = :book.Id];
        System.assertEquals(3, updatedBook.Available_Copies__c);
    }

    @isTest
    static void testReturnBookAlreadyReturned() {
        Book__c book = [SELECT Id FROM Book__c WHERE Name = 'The Great Gatsby' LIMIT 1];
        Library_Member__c member = [SELECT Id FROM Library_Member__c WHERE Name = 'John Doe' LIMIT 1];
        Book_Issue__c issue = LibraryController.issueBook(book.Id, member.Id);
        LibraryController.returnBook(issue.Id);
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            LibraryController.returnBook(issue.Id);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'Expected AuraHandledException when returning an already returned issue');
    }

    @isTest
    static void testSyncOverdueIssues() {
        Book__c book = [SELECT Id FROM Book__c WHERE Name = 'The Great Gatsby' LIMIT 1];
        Library_Member__c member = [SELECT Id FROM Library_Member__c WHERE Name = 'John Doe' LIMIT 1];
        Book_Issue__c issue = LibraryController.issueBook(book.Id, member.Id);

        issue.Due_Date__c = Date.today().addDays(-1);
        update issue;

        Test.startTest();
        Integer updatedCount = LibraryController.syncOverdueIssues();
        Test.stopTest();

        Book_Issue__c updatedIssue = [SELECT Issue_Status__c FROM Book_Issue__c WHERE Id = :issue.Id];
        System.assertEquals(1, updatedCount, 'One record should be marked overdue');
        System.assertEquals('Overdue', updatedIssue.Issue_Status__c, 'Issue should move to Overdue');
    }

    @isTest
    static void testRenewBookSuccess() {
        Book__c book = [SELECT Id FROM Book__c WHERE Name = 'The Great Gatsby' LIMIT 1];
        Library_Member__c member = [SELECT Id FROM Library_Member__c WHERE Name = 'John Doe' LIMIT 1];
        Book_Issue__c issue = LibraryController.issueBook(book.Id, member.Id);
        Date oldDueDate = issue.Due_Date__c;

        Test.startTest();
        Book_Issue__c renewed = LibraryController.renewBook(issue.Id);
        Test.stopTest();

        System.assertEquals(oldDueDate.addDays(7), renewed.Due_Date__c, 'Due date should be extended by 7 days');
        System.assertEquals(1, renewed.Renewal_Count__c, 'Renewal count should increment');
    }

    @isTest
    static void testRenewBookMaxLimit() {
        Book__c book = [SELECT Id FROM Book__c WHERE Name = 'The Great Gatsby' LIMIT 1];
        Library_Member__c member = [SELECT Id FROM Library_Member__c WHERE Name = 'John Doe' LIMIT 1];
        Book_Issue__c issue = LibraryController.issueBook(book.Id, member.Id);

        issue.Renewal_Count__c = 2;
        update issue;
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            LibraryController.renewBook(issue.Id);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'Expected AuraHandledException when renewal limit is reached');
    }

    @isTest
    static void testRenewBookWrongStatus() {
        Book__c book = [SELECT Id FROM Book__c WHERE Name = 'The Great Gatsby' LIMIT 1];
        Library_Member__c member = [SELECT Id FROM Library_Member__c WHERE Name = 'John Doe' LIMIT 1];
        Book_Issue__c issue = LibraryController.issueBook(book.Id, member.Id);
        LibraryController.returnBook(issue.Id);
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            LibraryController.renewBook(issue.Id);
            System.assert(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        System.assert(exceptionThrown, 'Expected AuraHandledException when renewing non-issued records');
    }

    @isTest
    static void testGetBookIssues() {
        Book__c book = [SELECT Id FROM Book__c WHERE Name = 'The Great Gatsby' LIMIT 1];
        Library_Member__c member = [SELECT Id FROM Library_Member__c WHERE Name = 'John Doe' LIMIT 1];
        LibraryController.issueBook(book.Id, member.Id);

        Test.startTest();
        List<Book_Issue__c> issues = LibraryController.getBookIssues();
        Test.stopTest();
        System.assertEquals(1, issues.size(), 'Should return 1 issue');
    }

    @isTest
    static void testGetActiveIssues() {
        Book__c book = [SELECT Id FROM Book__c WHERE Name = 'The Great Gatsby' LIMIT 1];
        Library_Member__c member = [SELECT Id FROM Library_Member__c WHERE Name = 'John Doe' LIMIT 1];
        LibraryController.issueBook(book.Id, member.Id);

        Test.startTest();
        List<Book_Issue__c> activeIssues = LibraryController.getActiveIssues();
        Test.stopTest();
        System.assertEquals(1, activeIssues.size(), 'Should return 1 active issue');
    }

    @isTest
    static void testGetRecentActivity() {
        Test.startTest();
        List<Book_Issue__c> activity = LibraryController.getRecentActivity();
        Test.stopTest();
        System.assertNotEquals(null, activity, 'Activity should not be null');
    }
}
