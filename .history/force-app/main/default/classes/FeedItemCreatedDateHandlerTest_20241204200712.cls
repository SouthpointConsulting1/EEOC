@IsTest
private class FeedItemCreatedDateHandlerTest {
    @IsTest
    static void testFeedItemCreatedDateSync() {
        // Create test Case with EEOC date
        Date incidentDate = Date.today().addDays(-30);
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            EEOC_Incident_Date__c = incidentDate
        );
        insert testCase;
        
        // Create test FeedItem
        FeedItem testFeed = new FeedItem(
            ParentId = testCase.Id,
            Type = 'TrackedChange',
            Body = 'Test Feed'
        );
        
        Test.startTest();
        insert testFeed;
        Test.stopTest();
        
        // Verify results
        FeedItem verifyFeed = [SELECT Id, CreatedDate FROM FeedItem WHERE Id = :testFeed.Id];
        System.assertEquals(
            DateTime.newInstance(incidentDate, Time.newInstance(0, 0, 0, 0)),
            verifyFeed.CreatedDate.date(),
            'Feed item CreatedDate should match Case EEOC_Incident_Date__c'
        );
    }
    
    @IsTest
    static void testNonCaseFeedItem() {
        // Create test Account (different object type)
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create test FeedItem for Account
        FeedItem testFeed = new FeedItem(
            ParentId = testAccount.Id,
            Type = 'TrackedChange',
            Body = 'Test Feed'
        );
        
        DateTime beforeInsert = DateTime.now();
        Test.startTest();
        insert testFeed;
        Test.stopTest();
        
        // Verify results - CreatedDate should not be modified
        FeedItem verifyFeed = [SELECT Id, CreatedDate FROM FeedItem WHERE Id = :testFeed.Id];
        System.assert(
            verifyFeed.CreatedDate >= beforeInsert,
            'Non-Case feed item CreatedDate should not be modified'
        );
    }
}