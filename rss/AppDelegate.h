//
//  AppDelegate.h
//  rss
//
//  Created by akaimo on 2015/04/01.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXOauth2.h"

extern NSString * const kOauth2ClientAccountType;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, retain) NSMutableArray *feed;
@property (nonatomic, assign) NXOAuth2Account *account;
@property (strong, nonatomic) UIWindow *window;

@end

