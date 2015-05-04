//
//  AKAMarkersFeed.h
//  rss
//
//  Created by akaimo on 2015/05/02.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXOauth2.h"

@interface AKAMarkersFeed : NSObject

@property (nonatomic, assign) NXOAuth2Account *account;

//-- itemsのfeedを既読にする
- (void)markAsRead:(NSArray *)items;

//-- itemsのfeedを未読にする
- (void)keepUnread:(NSArray *)items;

//-- itemsをsavedにする
- (void)markAsSaved:(NSArray *)items;

//-- itemsをunSavedにする
- (void)markAsUnsaved:(NSArray *)items;

@end
