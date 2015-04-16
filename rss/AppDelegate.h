//
//  AppDelegate.h
//  rss
//
//  Created by akaimo on 2015/04/01.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kOauth2ClientAccountType;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


- (NSString *)jsonToString:(id)json;

@end

