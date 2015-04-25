//
//  AKAFetchFeed.h
//  rss
//
//  Created by akaimo on 2015/04/25.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKAFetchFeed : NSObject

//-- DBからカテゴリーごとにfeedを収得
- (NSArray *)fechCategoryFeedUnread:(NSNumber *)unread;

//-- DBからすべてのfeedを収得
- (NSArray *)fechAllFeedUnread:(NSNumber *)unread;

@end
