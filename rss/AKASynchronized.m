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

//-- 同期処理
- (void)synchro {
    /* アカウントの照合 */
    [self checkAccount:_userData];
    
    /* カテゴリ一覧を収得 */
    NSURL *url = [NSURL URLWithString:CATEGORY];
    NSDictionary *category = [self urlForJSONToDictionary:url];
    /* カテゴリを解析し保存 */
    [self saveCategory:category];
    
    /* 未読数を収得して、その数だけ記事を収得 */
    NSString *str = [FEED stringByAppendingString:[self checkUnreadCount]];
    NSLog(@"%@", str);
    url = [NSURL URLWithString:str];
    NSDictionary *feed = [self urlForJSONToDictionary:url];
    /* 記事を解析し保存 */
    [self saveFeed:feed];
    
    /* お気に入りを収得 */
    url = [NSURL URLWithString:SAVED];
    NSDictionary *save = [self urlForJSONToDictionary:url];
    /* お気に入りを解析し保存 */
    [self saveSaved:save];
    
    /* データベースの整合性のチェック */
    
    /* 過去のfeedを削除 */
    [self deleteFeed];
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

//-- カテゴリを解析、保存
- (void)saveCategory:(NSDictionary *)categoryDict {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    NSArray *categoryArray = (NSArray *)categoryDict;
    
//    NSLog(@"category: %lu", (unsigned long)categoryArray.count);
//    NSLog(@"records: %lu", (unsigned long)records.count);
    
    /* sqlite3のURLを収得 */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = paths[0];
    NSLog(@"sqlite3: %@", documentsPath);
    
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
- (void)checkAccount:(NSDictionary *)userData {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Account"];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    BOOL *exist = false;
    
    if (records.count == 0) {
        /* データベースが空の場合はそのまま保存 */
        id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Account"
                                               inManagedObjectContext:[AKACoreData sharedCoreData].managedObjectContext];
        [obj setValue:[userData valueForKey:@"id"] forKey:@"id"];
        [obj setValue:[userData valueForKey:@"client"] forKey:@"client"];
        [[AKACoreData sharedCoreData] saveContext];
    } else {
        /* データベースが存在する場合は、一致するアカウントが無い場合のみ保存 */
        for (NSManagedObject *data in records) {
            if ([[data valueForKey:@"id"] isEqualToString:[userData valueForKey:@"id"]] && [[data valueForKey:@"client"] isEqualToString:[userData valueForKey:@"client"]]) {
                exist = true;
                break;
            }
        }
        if (exist == false) {
            id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Account"
                                                   inManagedObjectContext:[AKACoreData sharedCoreData].managedObjectContext];
            [obj setValue:[userData valueForKey:@"id"] forKey:@"id"];
            [obj setValue:[userData valueForKey:@"client"] forKey:@"client"];
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
    
    /* Accountテーブルから現在使っているアカウントデータを抽出する */
    id account = [self currentAccount];
    
    NSDictionary *items = [feedDict valueForKey:@"items"];
    
    /* feedの保存処理 */
    for (int i=0; i<items.count; i++) {
        @autoreleasepool {
            BOOL *exist = false;
            
            /* 一致するカテゴリを探す */
            id category = [self currentCategory:items :i];
            
            /* 一致するサイトを探す */
            id site = [self currentSite:items :i];
            
            /* データベースに存在しないfeedを追加する
               データベースが空の場合を考慮して分岐   */
            if (records.count == 0) {
                // 空の場合はすべてのfeedを保存
                
                id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Article"
                                                       inManagedObjectContext:[AKACoreData sharedCoreData].managedObjectContext];
                
                [obj setValue:[items valueForKey:@"id"][i] forKey:@"id"];                                     // feedのID
                [obj setValue:[items valueForKey:@"title"][i] forKey:@"title"];                               // feedのタイトル
                if ([[items valueForKey:@"summary"] valueForKey:@"content"][i] == [NSNull null]) {            // feedの詳細
                    [obj setValue:[[items valueForKey:@"content"] valueForKey:@"content"][i] forKey:@"detail"];
                } else {
                    [obj setValue:[[items valueForKey:@"summary"] valueForKey:@"content"][i] forKey:@"detail"];
                }
                if ([[items valueForKey:@"alternate"] valueForKey:@"herf"][i] == [NSNull null]) {             // feedのURL
                    [obj setValue:@"nil" forKey:@"url"];
                } else {
                    [obj setValue:[[items valueForKey:@"alternate"][i][0] valueForKey:@"href"] forKey:@"url"];
                }
                [obj setValue:[items valueForKey:@"unread"][i] forKey:@"unread"];                             // 未読のフラグ
                [obj setValue:[items valueForKey:@"crawled"][i] forKey:@"timestamp"];                       // タイムスタンプ
                [obj setValue:account forKey:@"account"];                                                     // Accountテーブルとの関連付け
                [obj setValue:category forKey:@"category"];                                                   // Categoryテーブルとの関連付け
                [obj setValue:site forKey:@"site"];                                                           // Siteテーブルとの関連付け

                [[AKACoreData sharedCoreData] saveContext];
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
                    id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Article"
                                                           inManagedObjectContext:[AKACoreData sharedCoreData].managedObjectContext];
                    
                    [obj setValue:[items valueForKey:@"id"][i] forKey:@"id"];                                     // feedのID
                    [obj setValue:[items valueForKey:@"title"][i] forKey:@"title"];                               // feedのタイトル
                    if ([[items valueForKey:@"summary"] valueForKey:@"content"][i] == [NSNull null]) {            // feedの詳細
                        [obj setValue:[[items valueForKey:@"content"] valueForKey:@"content"][i] forKey:@"detail"];
                    } else {
                        [obj setValue:[[items valueForKey:@"summary"] valueForKey:@"content"][i] forKey:@"detail"];
                    }
                    if ([[items valueForKey:@"alternate"] valueForKey:@"herf"][i] == [NSNull null]) {             // feedのURL
                        [obj setValue:@"nil" forKey:@"url"];
                    } else {
                        [obj setValue:[[items valueForKey:@"alternate"][i][0] valueForKey:@"href"] forKey:@"url"];
                    }
                    [obj setValue:[items valueForKey:@"unread"][i] forKey:@"unread"];                             // 未読のフラグ
                    [obj setValue:[items valueForKey:@"crawled"][i] forKey:@"timestamp"];                         // タイムスタンプ
                    [obj setValue:account forKey:@"account"];                                                     // Accountテーブルとの関連付け
                    [obj setValue:category forKey:@"category"];                                                   // Categoryテーブルとの関連付け
                    [obj setValue:site forKey:@"site"];                                                           // Siteテーブルとの関連付け
                    
                    [[AKACoreData sharedCoreData] saveContext];
                } else {
                    NSLog(@"no");
                    break;
                }
            }
        }
    }
}

//-- Accountテーブルから現在使っているアカウントデータを抽出する
- (id)currentAccount {
    id account;
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Account"];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    for (NSManagedObject *data in records) {
        if ([[data valueForKey:@"id"] isEqualToString:[_userData valueForKey:@"id"]] && [[data valueForKey:@"client"] isEqualToString:[_userData valueForKey:@"client"]]) {
            account = data;
            break;
        }
    }
    return account;
}

//-- 一致するカテゴリを探す
- (id)currentCategory:(NSDictionary *)items :(int)count {
    /* Categoryテーブルを関連付けるために、Categoryテーブルを収得する */
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    /* 一致するカテゴリを探す */
    id category;
    for (NSManagedObject *data in records) {
        /* カテゴリ登録されていない場合は[categories][label]が存在しないため、nullになる */
        if ([[items valueForKey:@"categories"] valueForKey:@"label"][count] == [NSNull null]) {
//            NSLog(@"uncategorized");
            category = data;
            break;
        } else {
            /* [categories][label]が存在した場合、必ず一致するカテゴリが存在する */
            if ([[data valueForKey:@"name"] isEqualToString:[[items valueForKey:@"categories"][count][0] valueForKey:@"label"]]) {
//                NSLog(@"存在した: %@", [[items valueForKey:@"categories"][count][0] valueForKey:@"label"]);
                category = data;
                break;
            }
        }
    }
    
    return category;
}

//-- 一致するサイトを探す
- (id)currentSite:(NSDictionary *)items :(int)count {
    /* Siteテーブルを関連付けるために、Siteテーブルを収得する */
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Site"];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    /* 一致するサイトを探す Siteテーブルは始めは空なので、処理を分岐させる */
    id site;
    if (records.count == 0) {
        /* Siteテーブルが空 */
        id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Site"
                                               inManagedObjectContext:[AKACoreData sharedCoreData].managedObjectContext];
        [obj setValue:[[items valueForKey:@"origin"] valueForKey:@"title"][count] forKey:@"title"];
        [obj setValue:[[items valueForKey:@"origin"] valueForKey:@"htmlUrl"][count] forKey:@"url"];
        [[AKACoreData sharedCoreData] saveContext];
//        NSLog(@"site 0");
//        NSLog(@"%@", [[items valueForKey:@"origin"] valueForKey:@"title"][count]);
//        NSLog(@"%@", [[items valueForKey:@"origin"] valueForKey:@"htmlUrl"][count]);
        site = obj;
    } else {
        /* Siteテーブルが存在する */
//        NSLog(@"site not 0");
        BOOL *exist = false;
        for (NSManagedObject *data in records) {
            /* Siteテーブルの中に目的のサイトが登録されている場合 */
            if ([[data valueForKey:@"title"] isEqualToString:[[items valueForKey:@"origin"] valueForKey:@"title"][count]] && [[data valueForKey:@"url"] isEqualToString:[[items valueForKey:@"origin"] valueForKey:@"htmlUrl"][count]]) {
                site = data;
                exist = true;
                break;
            }
        }
        if (exist == false) {
            /* 目的のサイトが登録されていない場合は保存 */
            id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Site"
                                                   inManagedObjectContext:[AKACoreData sharedCoreData].managedObjectContext];
            [obj setValue:[[items valueForKey:@"origin"] valueForKey:@"title"][count] forKey:@"title"];
            [obj setValue:[[items valueForKey:@"origin"] valueForKey:@"htmlUrl"][count] forKey:@"url"];
            [[AKACoreData sharedCoreData] saveContext];
//            NSLog(@"%@", [[items valueForKey:@"origin"] valueForKey:@"title"][count]);
//            NSLog(@"%@", [[items valueForKey:@"origin"] valueForKey:@"htmlUrl"][count]);
            site = obj;
        }
    }
    
    return site;
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
                /* Accountテーブルから現在使っているアカウントデータを抽出する */
                id account = [self currentAccount];
                /* 一致するカテゴリを探す */
                id category = [self currentCategory:items :i];
                /* 一致するサイトを探す */
                id site = [self currentSite:items :i];
                id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Article"
                                                       inManagedObjectContext:[AKACoreData sharedCoreData].managedObjectContext];
                
                [obj setValue:[items valueForKey:@"id"][i] forKey:@"id"];                                     // feedのID
                [obj setValue:[items valueForKey:@"title"][i] forKey:@"title"];                               // feedのタイトル
                if ([[items valueForKey:@"summary"] valueForKey:@"content"][i] == [NSNull null]) {            // feedの詳細
                    [obj setValue:[[items valueForKey:@"content"] valueForKey:@"content"][i] forKey:@"detail"];
                } else {
                    [obj setValue:[[items valueForKey:@"summary"] valueForKey:@"content"][i] forKey:@"detail"];
                }
                if ([[items valueForKey:@"alternate"] valueForKey:@"herf"][i] == [NSNull null]) {             // feedのURL
                    [obj setValue:@"nil" forKey:@"url"];
                } else {
                    [obj setValue:[[items valueForKey:@"alternate"][i][0] valueForKey:@"href"] forKey:@"url"];
                }
                [obj setValue:[items valueForKey:@"unread"][i] forKey:@"unread"];                             // 未読のフラグ
                [obj setValue:[items valueForKey:@"crawled"][i] forKey:@"timestamp"];                         // タイムスタンプ
                [obj setValue:account forKey:@"account"];                                                     // Accountテーブルとの関連付け
                [obj setValue:category forKey:@"category"];                                                   // Categoryテーブルとの関連付け
                [obj setValue:site forKey:@"site"];                                                           // Siteテーブルとの関連付け
                NSNumber *num = [NSNumber numberWithBool:YES];
                [obj setValue:num forKey:@"saved"];
                
                [[AKACoreData sharedCoreData] saveContext];
            }
        }
    }
    /* savedを解除されたfeedが存在しないかをチェック
       他のアプリでsavedを解除した時の整合性を保つための処理 */
    request.predicate = [NSPredicate predicateWithFormat:@"saved == 1"];
    records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    for (NSManagedObject *data in records) {
        NSLog(@"%@", [data valueForKey:@"title"]);
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
    NSLog(@"7日前：%@", result);
    double unixtime = [result timeIntervalSince1970];
    NSLog(@"%f", unixtime * 1000);
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Article"];
    request.predicate = [NSPredicate predicateWithFormat:@"timestamp <= %f", unixtime * 1000 && @"saved == 0"];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    if (records.count != 0) {
        for (NSManagedObject *data in records) {
//            NSLog(@"%@", [data valueForKey:@"timestamp"]);
            [[[AKACoreData sharedCoreData] managedObjectContext] deleteObject:data];
        }
        [[AKACoreData sharedCoreData] saveContext];
        NSLog(@"削除");
    } else {
        NSLog(@"削除なし");
    }
}


@end
