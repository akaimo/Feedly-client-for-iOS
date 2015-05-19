//
//  AKAReadability.h
//  rss
//
//  Created by akaimo on 2015/05/17.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKAReadability : NSObject

@property (copy) NSString *authorizationToken;

- (void)getReadabilityForURL:(NSURL *)url completionHandler:(void (^)(NSDictionary *, NSError *))handler ;

@end
