@IsTest
private class FeedItemCreatedDateHandlerTest {
    @TestSetup
    static void setupFeedTracking() {
        // Enable feed tracking on Case object and specific fields
        List<Schema.SObjectField> fieldsToTrack = new List<Schema.SObjectField>{
            Case.Priority,
            Case.Status
        };
        
        Schema.SObjectType caseType = Schema.Case.getSObjectType();
        Schema.DescribeSObjectResult caseDescribe = caseType.getDescribe();
        
        if (!caseDescribe.isFeedEnabled()) {
            // Enable feed tracking for Case object
            insert new CustomObject__c(
                Name = 'Case',
                IsFeedEnabled__c = true
            );
            
            // Enable tracking for specific fields
            List<CustomField__c> fieldsToInsert = new List<CustomField__c>();
            for(Schema.SObjectField field : fieldsToTrack) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                fieldsToInsert.add(new CustomField__c(
                    Name = fieldDescribe.getName(),
                    Object__c = 'Case',
                    IsTracked__c = true
                ));
            }
            insert fieldsToInsert;
        }
    }
    
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
        
        // Create a manual FeedItem since we can't guarantee tracked changes in test context
        FeedItem testFeed = new FeedItem(
            ParentId = testCase.Id,
            Type = 'TrackedChange',
            Body = 'Status changed from New to In Progress'
        );
        
        Test.startTest();
        insert testFeed;
        Test.stopTest();
        
        // Query for the feed item
        List<FeedItem> feedItems = [
            SELECT Id, CreatedDate, Type 
            FROM FeedItem 
            WHERE Id = :testFeed.Id
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
            Name = 'Test Account'
        );
        insert testAccount;
        
        DateTime beforeInsert = DateTime.now();
        
        // Create a manual FeedItem
        FeedItem testFeed = new FeedItem(
            ParentId = testAccount.Id,
            Type = 'TextPost',  // Changed from TrackedChange to TextPost for direct insertion
            Body = 'Test post'
        );
        
        Test.startTest();
        insert testFeed;
        Test.stopTest();
        
        // Query for the feed item
        List<FeedItem> feedItems = [
            SELECT Id, CreatedDate, Type 
            FROM FeedItem 
            WHERE Id = :testFeed.Id
            LIMIT 1
        ];
        
        System.assertNotEquals(0, feedItems.size(), 'Feed item should have been created');
        System.assert(
            feedItems[0].CreatedDate >= beforeInsert,
            'Non-Case feed item CreatedDate should not be modified'
        );
    }
}