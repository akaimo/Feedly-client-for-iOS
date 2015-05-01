//
//  AKARegularExpression.h
//  rss
//
//  Created by akaimo on 2015/05/01.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKARegularExpression : NSObject

//-- feedからimgのsrcを取り出す
- (NSArray *)imagesWithFeed:(NSString *)feed;

//-- feedからHTMLタグを取り除く
- (NSString *)noTagWithFeed:(NSString *)feed;

@end
