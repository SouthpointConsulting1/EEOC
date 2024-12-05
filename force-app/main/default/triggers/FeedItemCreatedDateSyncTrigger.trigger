trigger FeedItemCreatedDateSyncTrigger on FeedItem (before insert) {
    FeedItemCreatedDateHandler.handleBeforeInsert(Trigger.new);
}