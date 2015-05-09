//
//  AKAFetchFeed.m
//  rss
//
//  Created by akaimo on 2015/04/25.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKAFetchFeed.h"
#import "AKACoreData.h"

@implementation AKAFetchFeed

//-- カテゴリごとにfeedを収得(unread)
- (NSArray *)fechCategoryFeedUnread:(NSNumber *)unread {
    /* カテゴリを収得 */
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    NSMutableArray *feed = [NSMutableArray array];
    
    for (int i=0; i<records.count; i++) {
        @autoreleasepool {
            NSManagedObject *data = records[i];
            
            NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
            NSSortDescriptor* timestampSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
            request.sortDescriptors = @[timestampSortDescriptor];
            
            if (unread == nil) {
                /* すべてのfeed */
                request.predicate = [NSPredicate predicateWithFormat:@"category == %@", data];
//                NSLog(@"unread: %@", unread);
            } else {
                /* 未読or既読のみの */
                request.predicate = [NSPredicate predicateWithFormat:@"unread == %@ && category == %@",unread, data];
//                NSLog(@"unread: %@", unread);
            }
            NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
            [feed addObject:records];
//            for (NSManagedObject *datas in feed[i]) {
//                NSLog(@"%@: %@", [[datas valueForKey:@"category"] valueForKey:@"name"], [datas valueForKey:@"title"]);
//            }
        }
    }
    
    /* 空のカテゴリーを取り除く */
    for (int i=0; i<feed.count; i++) {
        if ([feed[i] count] == 0) {
//            NSLog(@"hoge: %d", i);
            [feed removeObjectAtIndex:i];
            i--;
        } else {
//            NSLog(@"count: %lu", (unsigned long)[feed[i] count]);
        }
    }
    
    /* uncategorizedを一番下に並び替え */
    if ([[[feed[0] valueForKey:@"category"] valueForKey:@"name"][0] isEqualToString:@"uncategorized"]) {
        for (int i=0; i<feed.count-1; i++) {
            [feed exchangeObjectAtIndex:i withObjectAtIndex:i+1];
        }
    }
    
    return feed;
}

//-- すべてのfeedを収得(unread)
- (NSArray *)fechAllFeedUnread:(NSNumber *)unread {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    NSSortDescriptor* timestampSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    request.sortDescriptors = @[timestampSortDescriptor];
    
    if (unread == nil) {
        /* すべてのfeedを収得 */
//        NSLog(@"unread: %@", unread);
    } else {
        /* 未読or既読のみ */
        request.predicate = [NSPredicate predicateWithFormat:@"unread == %@",unread];
//        NSLog(@"unread: %@", unread);
    }
    NSArray *records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
//    for (NSManagedObject *datas in records) {
//        NSLog(@"%@: %@", [[datas valueForKey:@"category"] valueForKey:@"name"], [datas valueForKey:@"title"]);
//    }
    return records;
}



//-- カテゴリごとにfeedを収得(saved)
- (NSArray *)fechCategoryFeedSaved:(NSNumber *)saved {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    NSMutableArray *feed = [NSMutableArray array];
    
    for (int i=0; i<records.count; i++) {
        @autoreleasepool {
            NSManagedObject *data = records[i];
            
            NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
            NSSortDescriptor* timestampSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
            request.sortDescriptors = @[timestampSortDescriptor];
            
            if (saved == nil) {
                /* すべてのfeed */
                request.predicate = [NSPredicate predicateWithFormat:@"category == %@", data];
            } else {
                /* 未読or既読のみの */
                request.predicate = [NSPredicate predicateWithFormat:@"saved == %@ && category == %@",saved, data];
                //                NSLog(@"unread: %@", unread);
            }
            NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
            [feed addObject:records];
        }
    }
    
    /* 空のカテゴリーを取り除く */
    for (int i=0; i<feed.count; i++) {
        if ([feed[i] count] == 0) {
            [feed removeObjectAtIndex:i];
            i--;
        } else {
        }
    }
    
    /* uncategorizedを一番下に並び替え */
    if ([[[feed[0] valueForKey:@"category"] valueForKey:@"name"][0] isEqualToString:@"uncategorized"]) {
        for (int i=0; i<feed.count-1; i++) {
            [feed exchangeObjectAtIndex:i withObjectAtIndex:i+1];
        }
    }
    
    return feed;
}

//-- すべてのfeedを収得(saved)
- (NSArray *)fechAllFeedSaved:(NSNumber *)saved {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    NSSortDescriptor* timestampSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    request.sortDescriptors = @[timestampSortDescriptor];
    
    if (saved == nil) {
        /* すべてのfeedを収得 */
    } else {
        /* 未読or既読のみ */
        request.predicate = [NSPredicate predicateWithFormat:@"saved == %@", saved];
    }
    NSArray *records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    return records;
}

@end
