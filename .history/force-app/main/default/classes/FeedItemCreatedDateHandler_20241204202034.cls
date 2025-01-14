public class FeedItemCreatedDateHandler {
    public static void handleBeforeInsert(List<FeedItem> newFeedItems) {
        // Collect Case IDs for relevant feed items
        Set<Id> caseIds = new Set<Id>();
        List<FeedItem> feedItemsToUpdate = new List<FeedItem>();
        
        for(FeedItem feed : newFeedItems) {
            // Check if this is a TrackedChange feed item for a Case
            if(feed.Type == 'CreateRecordEvent' && 
               feed.ParentId != null && 
               String.valueOf(feed.ParentId).startsWith('500')) {
                caseIds.add(feed.ParentId);
                feedItemsToUpdate.add(feed);
            }
        }
        
        if(!feedItemsToUpdate.isEmpty()) {
            // Query Cases to get their EEOC_Incident_Date__c
            Map<Id, Case> casesMap = new Map<Id, Case>([
                SELECT Id, EEOC_Incident_Date__c 
                FROM Case 
                WHERE Id IN :caseIds
            ]);
            
            // Update CreatedDate for qualifying feed items
            for(FeedItem feed : feedItemsToUpdate) {
                Case relatedCase = casesMap.get(feed.ParentId);
                if(relatedCase != null && relatedCase.EEOC_Incident_Date__c != null) {
                    // Convert the Date to DateTime in the org's timezone
                    feed.CreatedDate = DateTime.newInstance(
                        relatedCase.EEOC_Incident_Date__c.year(),
                        relatedCase.EEOC_Incident_Date__c.month(),
                        relatedCase.EEOC_Incident_Date__c.day(),
                        8, 0, 0  // Setting to 8 AM in the org's timezone
                    );
                }
            }
        }
    }
}