//
//  AKASynchronized.h
//  rss
//
//  Created by akaimo on 2015/04/17.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOauth2.h"

@interface AKASynchronized : NSObject

@property (nonatomic, assign) NXOAuth2Account *account;
@property (nonatomic, assign) NSDictionary *userData;

//-- 同期処理
- (void)synchro:(UITableView *)tableView;

//-- URLを受け取ってJSONを収得し、辞書に変換して返す
- (NSDictionary *)urlForJSONToDictionary:(NSURL *)url;

//-- カテゴリを解析、保存
- (void)saveCategory:(NSDictionary *)categoryDict;

//-- アカウントを照合し、新規アカウントであればデータベースに保存
- (void)checkAccount;

//-- feedを収得して保存
- (void)saveFeed:(NSDictionary *)feedDict;

//-- 未読数を収得
- (NSString *)checkUnreadCount;

//-- savedを収得し、保存
- (void)saveSaved:(NSDictionary *)save;

//-- 過去のfeedを削除
- (void)deleteFeed;

@end
