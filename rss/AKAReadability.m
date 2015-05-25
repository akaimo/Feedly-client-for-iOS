//
//  AKAReadability.m
//  rss
//
//  Created by akaimo on 2015/05/17.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKAReadability.h"

@implementation AKAReadability

- (void)getReadabilityForURL:(NSURL *)url completionHandler:(void (^)(NSDictionary *, NSError *))handler {
    NSString *getUrl = [NSString stringWithFormat:@"url=%@", [url.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *token = [NSString stringWithFormat:@"&token=%@", @"01a12b1b435c61b59e2dd8c75b4f86fcefa1bc2d"];
    NSString *shortenUrl = [@"https://readability.com/api/content/v1/parser?" stringByAppendingString:getUrl];
    shortenUrl = [shortenUrl stringByAppendingString:token];
    NSLog(@"%@", shortenUrl);
    
    NSURL *readabilityUrl = [NSURL URLWithString:shortenUrl];
    NSMutableURLRequest *shortenRequest = [NSMutableURLRequest requestWithURL:readabilityUrl];
    shortenRequest.HTTPMethod = @"GET";
    
    [NSURLConnection sendAsynchronousRequest:shortenRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *shortenResponse, NSData *shortenData, NSError *shortenError) {
                               if (shortenError) {
                                   handler(nil, shortenError);
                               }
                               else {
                                   NSDictionary *shortenJson = [NSJSONSerialization JSONObjectWithData:shortenData
                                                                                               options:0
                                                                                                 error:NULL];
                                   handler(shortenJson, nil);
                               }
                           }];
}

@end
