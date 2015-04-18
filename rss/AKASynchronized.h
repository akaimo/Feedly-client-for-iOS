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

//-- 同期処理
- (void)synchro;

@end
