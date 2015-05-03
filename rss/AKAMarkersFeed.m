//
//  AKAMarkersFeed.m
//  rss
//
//  Created by akaimo on 2015/05/02.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKAMarkersFeed.h"
#import "AppDelegate.h"
#import "AKACoreData.h"

@implementation AKAMarkersFeed

//-- 初期化時にアカウント情報を収得
- (id)init {
    self = [super init];
    if (self != nil) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _account = delegate.account;
    }
    return self;
}


//-- DBの既読・未読を更新する
- (void)changeUnreadWithID:(NSString *)feedID unread:(NSNumber *)unread {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"id == %@",feedID];
    NSArray *records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    for (NSMutableData *data in records) {
        [data setValue:unread forKey:@"unread"];
        [[AKACoreData sharedCoreData] saveContext];
        NSLog(@"更新完了");
    }
}

//-- itemsのfeedを既読にする
- (void)markAsRead:(NSArray *)items {
    /* feedlyにPOSTする */
    NSURL *url = [NSURL URLWithString:MARKERS];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"markAsRead", @"action",
                         items, @"entryIds",
                         @"entries", @"type",nil];
    
    NSData* entryData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:NULL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    /* ヘッダー情報を追加する。 */
    [request setValue:_account.accessToken.accessToken forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: entryData];
    
    /* リクエスト送信 */
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    /* リクエストの送信が完了したら、DBへ反映させる */
    if (error == nil) {
        for (int i=0; i<items.count; i++) {
            [self changeUnreadWithID:items[i] unread:[NSNumber numberWithBool:NO]];
        }
    } else {
        NSLog(@"Error!");
    }
}

//-- itemsのfeedを未読にする
- (void)keepUnread:(NSArray *)items {
    /* feedlyにPOSTする */
    NSURL *url = [NSURL URLWithString:MARKERS];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"keepUnread", @"action",
                         items, @"entryIds",
                         @"entries", @"type",nil];
    
    NSData* entryData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:NULL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    /* ヘッダー情報を追加する。 */
    [request setValue:_account.accessToken.accessToken forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: entryData];
    
    /* リクエスト送信 */
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    /* リクエストの送信が完了したら、DBへ反映させる */
    if (error == nil) {
        for (int i=0; i<items.count; i++) {
            [self changeUnreadWithID:items[i] unread:[NSNumber numberWithBool:YES]];
        }
    } else {
        NSLog(@"Error!");
    }
}

@end
