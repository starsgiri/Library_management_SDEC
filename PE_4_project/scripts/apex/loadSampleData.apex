/**
 * ─────────────────────────────────────────────────────────────
 * Sample Data Loader for Library Management System
 * Run this script after deployment to populate the org with
 * sample data for testing.
 *
 * Execute via: sf apex run --file scripts/apex/loadSampleData.apex
 * ─────────────────────────────────────────────────────────────
 */

// ─── 1. Create Book Categories ───
List<Book_Category__c> categories = new List<Book_Category__c>{
    new Book_Category__c(Name = 'Fiction', Description__c = 'Novels, short stories, and literary fiction'),
    new Book_Category__c(Name = 'Science & Technology', Description__c = 'Scientific research, technology, and computing'),
    new Book_Category__c(Name = 'History', Description__c = 'Historical accounts and biographies'),
    new Book_Category__c(Name = 'Self-Help', Description__c = 'Personal development and motivational books'),
    new Book_Category__c(Name = 'Programming', Description__c = 'Software development and coding guides'),
    new Book_Category__c(Name = 'Philosophy', Description__c = 'Philosophical works and critical thinking')
};
insert categories;

Map<String, Id> catMap = new Map<String, Id>();
for (Book_Category__c c : categories) {
    catMap.put(c.Name, c.Id);
}

System.debug('✅ Created ' + categories.size() + ' categories');

// ─── 2. Create Books ───
List<Book__c> books = new List<Book__c>{
    new Book__c(Name='The Great Gatsby', Author__c='F. Scott Fitzgerald', ISBN__c='978-0743273565',
                Publisher__c='Scribner', Publication_Year__c='1925', Total_Copies__c=3,
                Available_Copies__c=3, Status__c='Available', Category__c=catMap.get('Fiction')),
    new Book__c(Name='To Kill a Mockingbird', Author__c='Harper Lee', ISBN__c='978-0060935467',
                Publisher__c='HarperCollins', Publication_Year__c='1960', Total_Copies__c=4,
                Available_Copies__c=4, Status__c='Available', Category__c=catMap.get('Fiction')),
    new Book__c(Name='1984', Author__c='George Orwell', ISBN__c='978-0451524935',
                Publisher__c='Signet Classic', Publication_Year__c='1949', Total_Copies__c=5,
                Available_Copies__c=5, Status__c='Available', Category__c=catMap.get('Fiction')),
    new Book__c(Name='A Brief History of Time', Author__c='Stephen Hawking', ISBN__c='978-0553380163',
                Publisher__c='Bantam', Publication_Year__c='1988', Total_Copies__c=2,
                Available_Copies__c=2, Status__c='Available', Category__c=catMap.get('Science & Technology')),
    new Book__c(Name='Sapiens', Author__c='Yuval Noah Harari', ISBN__c='978-0062316097',
                Publisher__c='Harper', Publication_Year__c='2015', Total_Copies__c=3,
                Available_Copies__c=3, Status__c='Available', Category__c=catMap.get('History')),
    new Book__c(Name='Atomic Habits', Author__c='James Clear', ISBN__c='978-0735211292',
                Publisher__c='Avery', Publication_Year__c='2018', Total_Copies__c=4,
                Available_Copies__c=4, Status__c='Available', Category__c=catMap.get('Self-Help')),
    new Book__c(Name='Clean Code', Author__c='Robert C. Martin', ISBN__c='978-0132350884',
                Publisher__c='Prentice Hall', Publication_Year__c='2008', Total_Copies__c=2,
                Available_Copies__c=2, Status__c='Available', Category__c=catMap.get('Programming')),
    new Book__c(Name='Head First Java', Author__c='Kathy Sierra', ISBN__c='978-0596009205',
                Publisher__c='O\'Reilly', Publication_Year__c='2005', Total_Copies__c=3,
                Available_Copies__c=3, Status__c='Available', Category__c=catMap.get('Programming')),
    new Book__c(Name='Meditations', Author__c='Marcus Aurelius', ISBN__c='978-0140449334',
                Publisher__c='Penguin Classics', Publication_Year__c='0180', Total_Copies__c=2,
                Available_Copies__c=2, Status__c='Available', Category__c=catMap.get('Philosophy')),
    new Book__c(Name='The Alchemist', Author__c='Paulo Coelho', ISBN__c='978-0062315007',
                Publisher__c='HarperOne', Publication_Year__c='1988', Total_Copies__c=5,
                Available_Copies__c=5, Status__c='Available', Category__c=catMap.get('Fiction'))
};
insert books;

System.debug('✅ Created ' + books.size() + ' books');

// ─── 3. Create Library Members ───
List<Library_Member__c> members = new List<Library_Member__c>{
    new Library_Member__c(Name='Aarav Sharma', Email__c='aarav.sharma@example.com', Phone__c='9876543210',
                          Membership_Date__c=Date.today().addMonths(-6), Membership_Status__c='Active',
                          Address__c='12, MG Road, Bangalore', Books_Issued__c=0),
    new Library_Member__c(Name='Priya Patel', Email__c='priya.patel@example.com', Phone__c='9123456789',
                          Membership_Date__c=Date.today().addMonths(-3), Membership_Status__c='Active',
                          Address__c='45, Nehru Place, Delhi', Books_Issued__c=0),
    new Library_Member__c(Name='Rohan Gupta', Email__c='rohan.gupta@example.com', Phone__c='9988776655',
                          Membership_Date__c=Date.today().addMonths(-12), Membership_Status__c='Active',
                          Address__c='78, Park Street, Kolkata', Books_Issued__c=0),
    new Library_Member__c(Name='Sneha Reddy', Email__c='sneha.reddy@example.com', Phone__c='9554433221',
                          Membership_Date__c=Date.today().addMonths(-1), Membership_Status__c='Active',
                          Address__c='23, Banjara Hills, Hyderabad', Books_Issued__c=0),
    new Library_Member__c(Name='Vikram Singh', Email__c='vikram.singh@example.com', Phone__c='9001122334',
                          Membership_Date__c=Date.today().addMonths(-8), Membership_Status__c='Inactive',
                          Address__c='56, Civil Lines, Jaipur', Books_Issued__c=0)
};
insert members;

System.debug('✅ Created ' + members.size() + ' members');
System.debug('🎉 Sample data loaded successfully!');
