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

- (void)getRequestForURL:(NSURL *)url completionHandler:(void (^)(NSURLRequest *, NSError *))handler {
    if (!self.authorizationToken) {
        [self authorizeWithCompletionHandler:^(NSError *error) {
            if (error) {
                handler(nil, error);
            }
            else {
                [self getRequestForURL:url
                     completionHandler:handler];
            }
        }];
    }
    else {
        NSURL *shortenUrl = [NSURL URLWithString:@"http://www.readability.com/~/"];
        NSMutableURLRequest *shortenRequest = [NSMutableURLRequest requestWithURL:shortenUrl];
        shortenRequest.HTTPMethod = @"POST";
        shortenRequest.HTTPBody = [[NSString stringWithFormat:
                                    @"url=%@",
                                    [url.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                   dataUsingEncoding:NSUTF8StringEncoding];
        [shortenRequest setValue:[NSString stringWithFormat:@"csrftoken=%@", self.authorizationToken]
              forHTTPHeaderField:@"Cookie"];
        [shortenRequest setValue:self.authorizationToken
              forHTTPHeaderField:@"X-CSRFToken"];
        [NSURLConnection sendAsynchronousRequest:shortenRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *shortenResponse, NSData *shortenData, NSError *shortenError) {
                                   if (shortenError) {
                                       handler(nil, shortenError);
                                   }
                                   else {
                                       NSLog(@"%@", shortenResponse);
                                       NSString *sessionToken;
                                       NSDictionary *headers = ((NSHTTPURLResponse *)shortenResponse).allHeaderFields;
                                       NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headers
                                                                                                 forURL:shortenResponse.URL];
                                       for (NSHTTPCookie *cookie in cookies) {
                                           if ([cookie.name isEqualToString:@"sessionid"]) {
                                               sessionToken = cookie.value;
                                           }
                                       }
                                       NSDictionary *shortenJson = [NSJSONSerialization JSONObjectWithData:shortenData
                                                                                                   options:0
                                                                                                     error:NULL];
                                       NSString *articleIdentifier = [shortenJson objectForKey:@"shortened_id"];
                                       if (articleIdentifier) {
                                           NSURL *articleUrl = [NSURL URLWithString:
                                                                [@"http://www.readability.com/articles/" stringByAppendingString:articleIdentifier]];
                                           NSMutableURLRequest *articleRequest = [NSMutableURLRequest requestWithURL:articleUrl];
                                           [articleRequest setValue:[NSString stringWithFormat:@"sessionid=%@", sessionToken]
                                                 forHTTPHeaderField:@"Cookie"];
                                           handler(articleRequest, nil);
                                       }
                                       else {
                                           handler(nil, nil);
                                       }
                                   }
                               }];
    }
}


- (void)authorizeWithCompletionHandler:(void (^)(NSError *))handler {
    NSURL *url = [NSURL URLWithString:@"http://www.readability.com/shorten"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPShouldHandleCookies:NO];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   self.authorizationToken = nil;
                                   handler(error);
                               }
                               else {
                                   NSDictionary *headers = ((NSHTTPURLResponse *)response).allHeaderFields;
                                   NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headers
                                                                                             forURL:response.URL];
                                   for (NSHTTPCookie *cookie in cookies) {
                                       if ([cookie.name isEqualToString:@"csrftoken"]) {
                                           self.authorizationToken = cookie.value;
                                       }
                                   }
                                   handler(nil);
                               }
                           }];
}

@end
