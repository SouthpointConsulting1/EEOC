@IsTest
private class FeedItemCreatedDateHandlerTest {
    @IsTest
    static void testFeedItemCreatedDateSync() {
        // Create test Case with EEOC date
        Date incidentDate = Date.today().addDays(-30);
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            EEOC_Incident_Date__c = incidentDate,
            Priority = 'Low'
        );
        insert testCase;
        
        Test.startTest();
        // Update the case to trigger a tracked change feed item
        testCase.Priority = 'High';
        update testCase;
        Test.stopTest();
        
        // Query for the feed item that was automatically created
        List<FeedItem> feedItems = [
            SELECT Id, CreatedDate, Type 
            FROM FeedItem 
            WHERE ParentId = :testCase.Id 
            AND Type = 'TrackedChange'
            LIMIT 1
        ];
        
        System.assertNotEquals(0, feedItems.size(), 'Feed item should have been created');
        System.assertEquals(
            DateTime.newInstance(incidentDate, Time.newInstance(0, 0, 0, 0)),
            feedItems[0].CreatedDate.date(),
            'Feed item CreatedDate should match Case EEOC_Incident_Date__c'
        );
    }
    
    @IsTest
    static void testNonCaseFeedItem() {
        // Create test Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Industry = 'Technology'
        );
        insert testAccount;
        
        DateTime beforeUpdate = DateTime.now();
        
        Test.startTest();
        // Update account to generate feed item
        testAccount.Industry = 'Healthcare';
        update testAccount;
        Test.stopTest();
        
        // Query for the feed item that was automatically created
        List<FeedItem> feedItems = [
            SELECT Id, CreatedDate, Type 
            FROM FeedItem 
            WHERE ParentId = :testAccount.Id 
            AND Type = 'TrackedChange'
            LIMIT 1
        ];
        
        System.assertNotEquals(0, feedItems.size(), 'Feed item should have been created');
        System.assert(
            feedItems[0].CreatedDate >= beforeUpdate,
            'Non-Case feed item CreatedDate should not be modified'
        );
    }
}