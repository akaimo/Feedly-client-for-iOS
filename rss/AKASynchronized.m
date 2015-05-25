//
//  AKASynchronized.m
//  rss
//
//  Created by akaimo on 2015/04/17.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKASynchronized.h"
#import "AppDelegate.h"
#import "AKACoreData.h"
#import "AKACurrentData.h"
#import "JDStatusBarNotification.h"
#import "AKAFetchFeed.h"
#import "AKANavigationController.h"
#import "AKAMarkersFeed.h"

@implementation AKASynchronized

//-- 初期化時にアカウント情報を収得
- (id)init {
    self = [super init];
    if (self != nil) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _account = delegate.account;
        _userData = [_account userData];
    }
    return self;
}


#pragma mark - Synchro
//-- 同期処理
- (void)synchro:(UITableView *)tableView {
    /* sqlite3のURLを収得 */
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsPath = paths[0];
//    NSLog(@"sqlite3: %@", documentsPath);
    
    [JDStatusBarNotification showWithStatus:@"Syscing..."];
    
    /* マルチスレッド */
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        /* 同期処理 */
        /* アカウントの照合 */
        [self checkAccount];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [JDStatusBarNotification showProgress:0.1];
        });
        
        
        /* データベースの整合性のチェック */
        NSURL *url = [NSURL URLWithString:LATESTREAD];
        NSDictionary *latestRead = [self urlForJSONToDictionary:url];
        if (latestRead == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [JDStatusBarNotification showWithStatus:@"Sync Failed!!" dismissAfter:1.5 styleName:JDStatusBarStyleError];
            });
            return;
        }
        /* 他のクライアントで既読にされた記事を既読にする */
        if ([latestRead valueForKey:@"entries"]) {
            NSArray *entries = [latestRead valueForKey:@"entries"];
//            NSLog(@"%@", entries);
            for (int i=0; i<entries.count; i++) {
                AKAMarkersFeed *markersFeed = [[AKAMarkersFeed alloc] init];
                [markersFeed changeUnreadWithID:entries[i] unread:[NSNumber numberWithBool:NO]];
            }
        }
        /* 他のクライアントで未読にされた記事を未読にする */
        if ([latestRead valueForKey:@"unread"]) {
            NSArray *unread = [latestRead valueForKey:@"unread"];
//            NSLog(@"%@", unread);
            for (int i=0; i<unread.count; i++) {
                AKAMarkersFeed *markersFeed = [[AKAMarkersFeed alloc] init];
                [markersFeed changeUnreadWithID:unread[i] unread:[NSNumber numberWithBool:NO]];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [JDStatusBarNotification showProgress:0.3];
        });
        
        
        /* カテゴリ一覧を収得 */
        url = [NSURL URLWithString:CATEGORY];
        NSDictionary *category = [self urlForJSONToDictionary:url];
        /* カテゴリを解析し保存 */
        [self saveCategory:category];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [JDStatusBarNotification showProgress:0.5];
        });
        
        
        /* 未読数を収得して、その数だけ記事を収得 */
        NSString *str = [STREAMS stringByAppendingString:[_userData valueForKey:@"id"]];
        str = [str stringByAppendingString:FEED];
        str = [str stringByAppendingString:[self checkUnreadCount]];
        NSLog(@"%@", str);
        url = [NSURL URLWithString:str];
        NSDictionary *feed = [self urlForJSONToDictionary:url];
        /* 記事を解析し保存 */
        [self saveFeed:feed];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [JDStatusBarNotification showProgress:0.7];
        });
        
        
        /* お気に入りを収得 */
        str = [STREAMS stringByAppendingString:[_userData valueForKey:@"id"]];
        str = [str stringByAppendingString:SAVED];
        url = [NSURL URLWithString:str];
        NSDictionary *save = [self urlForJSONToDictionary:url];
        /* お気に入りを解析し保存 */
        [self saveSaved:save];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [JDStatusBarNotification showProgress:0.9];
        });
        
        
        /* 過去のfeedを削除 */
        [self deleteFeed];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [JDStatusBarNotification showProgress:1.0];
        });
        
        
        /* fech */
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        AKAFetchFeed *fechFeed = [[AKAFetchFeed alloc] init];
        switch (delegate.feedStatus) {
            case UnreadItems:
                delegate.feed = [NSMutableArray arrayWithObject:[fechFeed fechAllFeedUnread:[NSNumber numberWithBool:YES]]];
                for (NSDictionary *dic in [NSMutableArray arrayWithArray:[fechFeed fechCategoryFeedUnread:[NSNumber numberWithBool:YES]]]) {
                    [delegate.feed addObject:dic];
                }
                break;
                
            case SavedItems:
                delegate.feed = [NSMutableArray arrayWithObject:[fechFeed fechAllFeedSaved:[NSNumber numberWithBool:YES]]];
                for (NSDictionary *dic in [NSMutableArray arrayWithArray:[fechFeed fechCategoryFeedSaved:[NSNumber numberWithBool:YES]]]) {
                    [delegate.feed addObject:dic];
                }
                break;
                
            case ReadItems:
                delegate.feed = [NSMutableArray arrayWithObject:[fechFeed fechAllFeedUnread:[NSNumber numberWithBool:NO]]];
                for (NSDictionary *dic in [NSMutableArray arrayWithArray:[fechFeed fechCategoryFeedUnread:[NSNumber numberWithBool:NO]]]) {
                    [delegate.feed addObject:dic];
                }
                break;
                
            case AllItems:
                delegate.feed = [NSMutableArray arrayWithObject:[fechFeed fechAllFeedUnread:nil]];
                for (NSDictionary *dic in [NSMutableArray arrayWithArray:[fechFeed fechCategoryFeedUnread:nil]]) {
                    [delegate.feed addObject:dic];
                }
                break;
                
            default:
                delegate.feed = [NSMutableArray arrayWithObject:[fechFeed fechAllFeedUnread:[NSNumber numberWithBool:YES]]];
                for (NSDictionary *dic in [NSMutableArray arrayWithArray:[fechFeed fechCategoryFeedUnread:[NSNumber numberWithBool:YES]]]) {
                    [delegate.feed addObject:dic];
                }
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (tableView) {
                [tableView reloadData];
            }
            [JDStatusBarNotification showWithStatus:@"Sync Success!" dismissAfter:1.5 styleName:JDStatusBarStyleSuccess];
        });
    }];
}

//-- URLを受け取ってJSONを収得し、辞書に変換して返す
- (NSDictionary *)urlForJSONToDictionary:(NSURL *)url {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    /* ヘッダー情報を追加する。 */
    [request setValue:_account.accessToken.accessToken forHTTPHeaderField:@"Authorization"];
    
    /* リクエスト送信 */
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error != nil) {
        NSLog(@"Error!");
        return nil;
    }
    
    NSError *e = nil;    
    /* 取得したレスポンスをJSONパース */
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
//    NSLog(@"%@", dict);
//    NSLog(@"responseText = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    return dict;
}

//-- 未読数を収得
- (NSString *)checkUnreadCount {
    NSString *count;
    NSURL *url = [NSURL URLWithString:UNREAD_COUNT];
    NSDictionary *unreadDict = [self urlForJSONToDictionary:url];
    NSArray *unreadArray = [unreadDict valueForKey:@"unreadcounts"];
    for (int i=0; i<unreadArray.count; i++) {
        @autoreleasepool {
            NSError *error = nil;
            NSString *str = [unreadArray[i] valueForKey:@"id"];
            NSString *pattern = @"/category/global.all";
            
            // パターンから正規表現を生成する
            NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
            
            // 正規表現を適用して結果を得る
            NSTextCheckingResult *match = [regexp firstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
            
            if (match) {
                count = [[unreadArray[i] valueForKey:@"count"] stringValue];
                //                NSLog(@"count: %@", count);
            }
        }
    }
    
    return count;
}


#pragma mark - Save
//-- カテゴリを解析、保存
- (void)saveCategory:(NSDictionary *)categoryDict {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    NSArray *categoryArray = (NSArray *)categoryDict;
    
//    NSLog(@"category: %lu", (unsigned long)categoryArray.count);
//    NSLog(@"records: %lu", (unsigned long)records.count);
    
    int *one = 0;
    for (int i=0; i<categoryArray.count; i++) {
        @autoreleasepool {
            BOOL *exist = false;
            
//            NSLog(@"label: %@", [categoryArray[i] valueForKey:@"label"]);
            
            /* データベースに存在しないカテゴリを追加する
               データベースが空の場合を考慮して分岐 */
            if (records.count == 0) {
                // 空の場合
                NSLog(@"count 0");
                
                /* 初回はuncategorizedを作成する */
                if (one == (int *)0) {
                    id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Category"
                                                           inManagedObjectContext:[AKACoreData sharedCoreData].managedObjectContext];
                    [obj setValue:@"uncategorized" forKey:@"name"];
                    [[AKACoreData sharedCoreData] saveContext];
//                    NSLog(@"hoge");
                    one = (int *)1;
                }
                
                id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Category"
                                                       inManagedObjectContext:[AKACoreData sharedCoreData].managedObjectContext];
                [obj setValue:[categoryArray[i] valueForKey:@"label"] forKey:@"name"];
                [[AKACoreData sharedCoreData] saveContext];
            } else {
                /* 保存されたデータがある場合は既に存在するかどうかの確認 */
                @autoreleasepool {
                    for (NSManagedObject *data in records) {
//                        NSLog(@"name: %@", [data valueForKey:@"name"]);
                        if ([[data valueForKey:@"name"] isEqualToString:[categoryArray[i] valueForKey:@"label"]]) {
                            exist = true;
//                            NSLog(@"存在した");
                            break;
                        }
                    }
                }
                /* 存在しない場合は保存 */
                if (exist == false) {
//                    NSLog(@"存在しないから保存");
                    id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Category"
                                                           inManagedObjectContext:[AKACoreData sharedCoreData].managedObjectContext];
                    [obj setValue:[categoryArray[i] valueForKey:@"label"] forKey:@"name"];
                    [[AKACoreData sharedCoreData] saveContext];
                }
            }
        }
    }
}

//-- アカウントを照合し、新規アカウントであればデータベースに保存
- (void)checkAccount {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Account"];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    BOOL *exist = false;
    
    if (records.count == 0) {
        /* データベースが空の場合はそのまま保存 */
        id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Account"
                                               inManagedObjectContext:[AKACoreData sharedCoreData].managedObjectContext];
        [obj setValue:[_userData valueForKey:@"id"] forKey:@"id"];
        [obj setValue:[_userData valueForKey:@"client"] forKey:@"client"];
        [[AKACoreData sharedCoreData] saveContext];
    } else {
        /* データベースが存在する場合は、一致するアカウントが無い場合のみ保存 */
        for (NSManagedObject *data in records) {
            if ([[data valueForKey:@"id"] isEqualToString:[_userData valueForKey:@"id"]] && [[data valueForKey:@"client"] isEqualToString:[_userData valueForKey:@"client"]]) {
                exist = true;
                break;
            }
        }
        if (exist == false) {
            id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Account"
                                                   inManagedObjectContext:[AKACoreData sharedCoreData].managedObjectContext];
            [obj setValue:[_userData valueForKey:@"id"] forKey:@"id"];
            [obj setValue:[_userData valueForKey:@"client"] forKey:@"client"];
            [[AKACoreData sharedCoreData] saveContext];
        }
    }
}

//-- feedを収得して保存
- (void)saveFeed:(NSDictionary *)feedDict {
    /* 既存のfeedを収得 */
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    NSSortDescriptor* timestampSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    request.sortDescriptors = @[timestampSortDescriptor];
    request.fetchLimit = 1;
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    AKACurrentData *currentData = [[AKACurrentData alloc] init];
    
    /* Accountテーブルから現在使っているアカウントデータを抽出する */
    id account = [currentData currentAccount:_userData];
    
    NSArray *items = [feedDict valueForKey:@"items"];
    
    /* savedのフラグ */
    NSNumber *save = [NSNumber numberWithBool:NO];
    
    /* feedの保存処理 */
    for (int i=0; i<items.count; i++) {
        @autoreleasepool {
            BOOL *exist = false;
            
            /* 一致するカテゴリを探す */
            id category = [currentData currentCategory:items :i];
            
            /* 一致するサイトを探す */
            id site = [currentData currentSite:items :i];
            
            /* データベースに存在しないfeedを追加する
               データベースが空の場合を考慮して分岐   */
            if (records.count == 0) {
                // 空の場合はすべてのfeedを保存
                
                [self saveItem:items account:account category:category site:site save:save count:i];
            } else {
                // 保存されたデータがある場合は、タイムスタンプを利用して新しいfeedだけを保存
                
                NSLog(@"items:   %lld", [[items valueForKey:@"crawled"][i] longLongValue]);
                NSLog(@"records: %lld", [[records[0] valueForKey:@"timestamp"] longLongValue]);
                NSLog(@"%@", [items valueForKey:@"title"][i]);
                NSLog(@"%@", [records[0] valueForKey:@"title"]);
                
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[items valueForKey:@"crawled"][i] longLongValue] /1000.0];
                NSLog(@"item: %@", date);
                
                date = [NSDate dateWithTimeIntervalSince1970:[[records[0] valueForKey:@"timestamp"] longLongValue] /1000.0];
                NSLog(@"record: %@", date);
                
                NSDate *now = [NSDate date];
                NSLog(@"now: %@", now);
                
                if ([[items valueForKey:@"crawled"][i] longLongValue] > [[records[0] valueForKey:@"timestamp"] longLongValue]) {
                    NSLog(@"新着記事");
                    /* 保存 */
                    [self saveItem:items account:account category:category site:site save:save count:i];
                } else {
                    NSLog(@"no");
                    break;
                }
            }
        }
    }
}

//-- savedを収得し、保存
- (void)saveSaved:(NSDictionary *)save {
    /* データベースのfeedを収得 */
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    NSSortDescriptor* timestampSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timestampSortDescriptor];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    NSArray *items = [save valueForKey:@"items"];
    /* savedのfeedを保存 */
    for (int i=0; i<items.count; i++) {
        @autoreleasepool {
            BOOL *exist = false;
            /* データベースからsavedのfeedを探す */
            for (NSManagedObject *data in records) {
                if ([[items valueForKey:@"id"][i] isEqualToString:[data valueForKey:@"id"]]) {
                    NSLog(@"一致");
                    exist = true;
                    /* データベースのfeedがsavedになっていなかったら、savedにする
                       他のアプリでsavedにした時に、整合性を保つための処理 */
                    if ([[data valueForKey:@"saved"] isEqualToNumber:[NSNumber numberWithBool:NO]]) {
                        NSLog(@"savedにして保存");
                        NSNumber *num = [NSNumber numberWithBool:YES];
                        [data setValue:num forKey:@"saved"];
                        [[AKACoreData sharedCoreData] saveContext];
                    } else {
                        /* データベースに存在するfeedをsavedにした場合は、サーバーにsavedの処理を投げたと同時に
                           データベースも更新するので、基本的には既にsavedになっていると考えられる */
                        NSLog(@"既にsaved");
                    }
                    break;
                }
            }
            /* データベースにfeedがなかった場合は保存
               主に、初めて同期したときに行われる処理
               昔にsavedにした（最近のfeedしか読み込まないため）feedを保存することが目的 */
            if (exist == false) {
                NSLog(@"savedのfeedとして保存");
                AKACurrentData *currentData = [[AKACurrentData alloc] init];
                /* Accountテーブルから現在使っているアカウントデータを抽出する */
                id account = [currentData currentAccount:_userData];
                /* 一致するカテゴリを探す */
                id category = [currentData currentCategorySavedWithAccount:_account items:items count:i];
//                id category = [currentData currentCategory:items :i];
                /* 一致するサイトを探す 要変更 */
                id site = [currentData currentSite:items :i];
                /* savedのフラグ */
                NSNumber *num = [NSNumber numberWithBool:YES];
                /* 保存 */
                [self saveItem:items account:account category:category site:site save:num count:i];
            }
        }
    }
    /* savedを解除されたfeedが存在しないかをチェック
       他のアプリでsavedを解除した時の整合性を保つための処理 */
    request.predicate = [NSPredicate predicateWithFormat:@"saved == %@", [NSNumber numberWithBool:YES]];
    records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    for (NSManagedObject *data in records) {
        NSLog(@"%@: %@: %@",[[data valueForKey:@"category"] valueForKey:@"name"], [[data valueForKey:@"site"] valueForKey:@"title"], [data valueForKey:@"title"]);
    }
    
    for (NSManagedObject *data in records) {
        BOOL *exist = false;
        /* データベースのsavedのfeedが現在もsavedかを確認し、savedではない場合は解除する */
        for (int i=0; i<items.count; i++) {
            if ([[data valueForKey:@"id"] isEqualToString:[items valueForKey:@"id"][i]]) {
                NSLog(@"savedである");
                exist = true;
                break;
            }
        }
        if (exist == false) {
            NSLog(@"savedを解除して保存");
            NSNumber *num = [NSNumber numberWithBool:NO];
            [data setValue:num forKey:@"saved"];
            [[AKACoreData sharedCoreData] saveContext];
        }
    }
}

//-- 過去のfeedを削除
- (void)deleteFeed {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSLog(@"now: %@", now);
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    comps.day = -7;
    NSDate *result = [calendar dateByAddingComponents:comps toDate:now options:0];
    NSLog(@"3日前：%@", result);
    double unixtime = [result timeIntervalSince1970];
    NSLog(@"%f", unixtime * 1000);
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"saved == %@ && timestamp <= %f",[NSNumber numberWithBool:NO], unixtime * 1000];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    if (records.count != 0) {
        for (NSManagedObject *data in records) {
            NSLog(@"%@", [data valueForKey:@"title"]);
            NSLog(@"%@", [data valueForKey:@"timestamp"]);
            [[[AKACoreData sharedCoreData] managedObjectContext] deleteObject:data];
        }
        [[AKACoreData sharedCoreData] saveContext];
        NSLog(@"削除");
    } else {
        NSLog(@"削除なし");
    }
}

//-- feedの保存処理
- (void)saveItem:(NSArray *)items account:(id)account category:(id)category site:(id)site save:(id)save count:(int)i {
    id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Article"
                                           inManagedObjectContext:[AKACoreData sharedCoreData].managedObjectContext];
    
    [obj setValue:[items valueForKey:@"id"][i] forKey:@"id"];                                     // feedのID
    [obj setValue:[items valueForKey:@"title"][i] forKey:@"title"];                               // feedのタイトル
    if ([[items valueForKey:@"summary"] valueForKey:@"content"][i] != [NSNull null]) {            // feedの詳細
        [obj setValue:[[items valueForKey:@"summary"] valueForKey:@"content"][i] forKey:@"detail"];
    } else if ([[items valueForKey:@"content"] valueForKey:@"content"][i] != [NSNull null]) {
        [obj setValue:[[items valueForKey:@"content"] valueForKey:@"content"][i] forKey:@"detail"];
    } else {
        [obj setValue:@"" forKey:@"detail"];
    }
    if ([[items valueForKey:@"alternate"] valueForKey:@"herf"][i] != [NSNull null]) {             // feedのURL
        [obj setValue:[[items valueForKey:@"alternate"][i][0] valueForKey:@"href"] forKey:@"url"];
    } else {
        [obj setValue:@"" forKey:@"url"];
    }
    [obj setValue:[items valueForKey:@"unread"][i] forKey:@"unread"];                             // 未読のフラグ
    [obj setValue:save forKey:@"saved"];
    [obj setValue:[items valueForKey:@"crawled"][i] forKey:@"timestamp"];                       // タイムスタンプ
    [obj setValue:account forKey:@"account"];                                                     // Accountテーブルとの関連付け
    [obj setValue:category forKey:@"category"];                                                   // Categoryテーブルとの関連付け
    [obj setValue:site forKey:@"site"];                                                           // Siteテーブルとの関連付け
    
    [[AKACoreData sharedCoreData] saveContext];
}


@end
