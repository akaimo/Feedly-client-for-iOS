//
//  AKAFetchFeed.h
//  rss
//
//  Created by akaimo on 2015/04/25.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKAFetchFeed : NSObject

//-- DBからカテゴリーごとにfeedを収得(unread)
- (NSArray *)fechCategoryFeedUnread:(NSNumber *)unread;

//-- DBからすべてのfeedを収得(unread)
- (NSArray *)fechAllFeedUnread:(NSNumber *)unread;

//-- DBからカテゴリーごとにfeedを取得(saved)
- (NSArray *)fechCategoryFeedSaved:(NSNumber *)saved;

//-- DBからすべてのfeedを収得(saved)
- (NSArray *)fechAllFeedSaved:(NSNumber *)saved;

@end
