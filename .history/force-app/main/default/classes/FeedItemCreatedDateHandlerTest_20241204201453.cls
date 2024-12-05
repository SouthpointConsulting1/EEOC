@IsTest
private class FeedItemCreatedDateHandlerTest {
    @IsTest
    static void testTriggerLogic() {
        // Create test Case
        // Using Date.newInstance to avoid any timezone issues
        Date incidentDate = Date.newInstance(2024, 11, 4);  // Fixed date for consistent testing
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            EEOC_Incident_Date__c = incidentDate
        );
        insert testCase;
        
        // Create a test FeedItem that mimics a TrackedChange
        FeedItem mockFeed = new FeedItem(
            ParentId = testCase.Id,
            Type = 'TrackedChange',
            Body = 'Test feed item'
        );
        
        // Execute the trigger logic directly
        Test.startTest();
        FeedItemCreatedDateHandler.handleBeforeInsert(new List<FeedItem>{mockFeed});
        Test.stopTest();
        
        // Create expected DateTime with the same fixed time (8 AM)
        DateTime expectedDateTime = DateTime.newInstance(2024, 11, 4, 8, 0, 0);
        
        // Verify the feed item's CreatedDate was set correctly
        System.assertEquals(
            expectedDateTime,
            mockFeed.CreatedDate,
            'Feed item CreatedDate should have been set to Case EEOC_Incident_Date__c with correct time'
        );
    }
    
    @IsTest
    static void testNonCaseLogic() {
        // Create test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Use the same DateTime creation pattern for consistency
        DateTime originalDate = DateTime.newInstance(2024, 11, 4, 8, 0, 0);
        
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