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
        self.account = delegate.account;
    }
    return self;
}

- (void)synchro {
    // カテゴリ一覧を収得
    NSURL *url = [NSURL URLWithString:CATEGORY];
    NSDictionary *category = [self getJSONToDictionary:url];
    // カテゴリを解析し保存
    [self saveCategory:category];
    // 記事を収得
    url = [NSURL URLWithString:FEED];
    NSDictionary *feed = [self getJSONToDictionary:url];
    // 記事を解析し保存
    // お気に入りを収得
    // お気に入りを解析し保存
}

//-- URLを受け取ってJSONを収得し、辞書に変換して返す
- (NSDictionary *)getJSONToDictionary:(NSURL *)url {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // ヘッダー情報を追加する。
    [request setValue:self.account.accessToken.accessToken forHTTPHeaderField:@"Authorization"];
    
    // リクエスト送信
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error != nil) {
        NSLog(@"Error!");
        return nil;
    }
    
    NSError *e = nil;    
    //取得したレスポンスをJSONパース
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    NSLog(@"%@", dict);
    NSLog(@"responseText = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    return dict;
}

//-- カテゴリを解析、保存
- (void)saveCategory:(NSDictionary *)categoryDict {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    NSArray* records = [[AKACoreData sharedCoreData].managedObjectContext executeFetchRequest:request error:nil];
    
    NSArray *categoryArray = (NSArray *)categoryDict;
    
    NSLog(@"category: %lu", (unsigned long)categoryArray.count);
    NSLog(@"records: %lu", (unsigned long)records.count);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = paths[0];
    NSLog(@"sqlite3: %@", documentsPath);
    
    for (int i=0; i<categoryArray.count; i++) {
        @autoreleasepool {
            BOOL *exist = false;
            id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Category"
                                                   inManagedObjectContext:[AKACoreData sharedCoreData].managedObjectContext];
            
            NSLog(@"label: %@", [categoryArray[i] valueForKey:@"label"]);
            
            /* データベースに存在しないカテゴリを追加する
               データベースが空の場合を考慮して分岐 */
            if (records.count == 0) {
                // 空の場合
                NSLog(@"count 0");
                [obj setValue:[categoryArray[i] valueForKey:@"label"] forKey:@"name"];
                [[AKACoreData sharedCoreData] saveContext];
            } else {
                // 保存されたデータがある場合は既に存在するかどうかの確認
                for (NSManagedObject *data in records) {
                    NSLog(@"name: %@", [data valueForKey:@"name"]);
                    if ([[data valueForKey:@"name"] isEqualToString:[categoryArray[i] valueForKey:@"label"]]) {
                        exist = true;
                        NSLog(@"存在した");
                        break;
                    }
                }
                // 存在しない場合は保存
                if (exist == false) {
                    NSLog(@"存在しないから保存");
                    [obj setValue:[categoryArray[i] valueForKey:@"label"] forKey:@"name"];
                    [[AKACoreData sharedCoreData] saveContext];
                }
            }
        }
    }
}

@end
