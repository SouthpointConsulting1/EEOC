@IsTest
private class FeedItemCreatedDateHandlerTest {
    @IsTest
    static void testTriggerLogic() {
        // Create test Case
        Date incidentDate = Date.today().addDays(-30);
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            EEOC_Incident_Date__c = incidentDate
        );
        insert testCase;
        
        // Create a test FeedItem that mimics a TrackedChange
        FeedItem mockFeed = new FeedItem(
            ParentId = testCase.Id,
            Type = 'TrackedChange',  // This won't actually insert, but we can test the trigger logic
            Body = 'Test feed item'
        );
        
        // Execute the trigger logic directly
        Test.startTest();
        FeedItemCreatedDateHandler.handleBeforeInsert(new List<FeedItem>{mockFeed});
        Test.stopTest();
        
        // Verify the feed item's CreatedDate was set correctly
        System.assertEquals(
            DateTime.newInstance(incidentDate, Time.newInstance(0, 0, 0, 0)),
            mockFeed.CreatedDate,
            'Feed item CreatedDate should have been set to Case EEOC_Incident_Date__c'
        );
    }
    
    @IsTest
    static void testNonCaseLogic() {
        // Create test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        DateTime originalDate = DateTime.now();
        
        // Create a test FeedItem for the Account
        FeedItem mockFeed = new FeedItem(
            ParentId = testAccount.Id,
            Type = 'TrackedChange',
            Body = 'Test feed item',
            CreatedDate = originalDate
        );
        
        // Execute the trigger logic directly
        Test.startTest();
        FeedItemCreatedDateHandler.handleBeforeInsert(new List<FeedItem>{mockFeed});
        Test.stopTest();
        
        // Verify the feed item's CreatedDate was not changed
        System.assertEquals(
            originalDate,
            mockFeed.CreatedDate,
            'Non-Case feed item CreatedDate should not have been modified'
        );
    }
}