//
//  AKACurrentData.h
//  rss
//
//  Created by akaimo on 2015/04/22.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOAuth2.h"

@interface AKACurrentData : NSObject

//-- 現在使っているアカウントデータを抽出
- (id)currentAccount:(NSDictionary *)userData;

//-- 一致するカテゴリを抽出
- (id)currentCategory:(NSDictionary *)items :(int)count;

//-- 一致するサイトを抽出
- (id)currentSite:(NSDictionary *)items :(int)count;

//-- savedのfeedの一致するカテゴリを抽出
- (id)currentCategorySavedWithAccount:(NXOAuth2Account *)account items:(NSDictionary *)items count:(int)count;

@end
