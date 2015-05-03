//
//  AKACurrentData.m
//  rss
//
//  Created by akaimo on 2015/04/22.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKACurrentData.h"
#import "AKACoreData.h"

@implementation AKACurrentData

//-- Accountテーブルから現在使っているアカウントデータを抽出する
- (id)currentAccount:(NSDictionary *)userData {
    id account;
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Account"];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    for (NSManagedObject *data in records) {
        if ([[data valueForKey:@"id"] isEqualToString:[userData valueForKey:@"id"]] && [[data valueForKey:@"client"] isEqualToString:[userData valueForKey:@"client"]]) {
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

//-- 一致するカテゴリーを探す(saved)
- (id)currentCategorySavedWithAccount:(NXOAuth2Account *)account items:(NSDictionary *)items count:(int)count {
    /* tag:savedで収得するとcategoryが収得できないため、
       entryIDを利用してもう一度収得する */
    NSString* inputString = [items valueForKey:@"id"][count];
    NSString *encodedText = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                                  NULL,
                                                                                                  (__bridge CFStringRef)inputString, //元の文字列
                                                                                                  NULL,
                                                                                                  CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                                  CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSString *urlString = [ENTRY stringByAppendingString:encodedText];
    NSLog(@"%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    /* ヘッダー情報を追加する。 */
    [urlRequest setValue:account.accessToken.accessToken forHTTPHeaderField:@"Authorization"];
    
    /* リクエスト送信 */
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    if (error != nil) {
        NSLog(@"Error!");
    }
    
    NSError *e = nil;
    /* 取得したレスポンスをJSONパース */
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
//    NSLog(@"%@", dict);
//    NSLog(@"responseText = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    
    /* Categoryテーブルを関連付けるために、Categoryテーブルを収得する */
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    /* 一致するカテゴリを探す */
    id category;
    for (NSManagedObject *data in records) {
        /* カテゴリ登録されていない場合は[categories][label]が存在しないため、nullになる */
        if ([[dict valueForKey:@"categories"] valueForKey:@"label"][0] == [NSNull null]) {
            //            NSLog(@"uncategorized");
            /* 1周目だからUncategorizedになる */
            category = data;
            break;
        } else {
            /* [categories][label]が存在した場合、必ず一致するカテゴリが存在する */
            if ([[data valueForKey:@"name"] isEqualToString:[[dict valueForKey:@"categories"][0][0] valueForKey:@"label"]]) {
                //                NSLog(@"存在した: %@", [[items valueForKey:@"categories"][count][0] valueForKey:@"label"]);
                category = data;
                break;
            }
        }
    }
    
    return category;
}

@end
