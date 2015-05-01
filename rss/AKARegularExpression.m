//
//  AKARegularExpression.m
//  rss
//
//  Created by akaimo on 2015/05/01.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKARegularExpression.h"

@implementation AKARegularExpression

//-- feedからimgのsrcを取り出す
- (NSArray *)imagesWithFeed:(NSString *)feed {
    if (!feed){
        return nil;
    }
    
    NSMutableArray *results = [NSMutableArray new];
    NSString* pattern = @"(<img.*?src=\\\")(?!.*rss.rssad.jp)(.*?)(\\\".*?>)";
    
    NSError* error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (error == nil){
        NSArray *matches = [regex matchesInString:feed options:0 range:NSMakeRange(0, feed.length)];
        for (NSTextCheckingResult *match in matches){
            //                NSLog(@"hoge: %@", [feed substringWithRange:[match rangeAtIndex:2]]);
            [results addObject:[feed substringWithRange:[match rangeAtIndex:2]]];
        }
    }
    
    return results;
}

//-- feedからHTMLタグを取り除く
- (NSString *)noTagWithFeed:(NSString *)feed {
    if (!feed){
        return nil;
    }
    
    NSString* noteTitle = feed;
    //    NSLog(@"除去前：%@", noteTitle);
    /* 改行を除去 */
    NSString* regPattern = @"(\r|(\r?\n))";
    NSRegularExpression* regExp = [NSRegularExpression regularExpressionWithPattern:regPattern options:0 error:nil];
    noteTitle = [regExp stringByReplacingMatchesInString:noteTitle options:0 range:NSMakeRange(0, noteTitle.length) withTemplate:@""];
    //    NSLog(@"除去後：%@", noteTitle);
    /* HTMLタグを除去 */
    regPattern = @"<(\\\"[^\\\"]*\\\"|'[^']*'|[^'\\\">])*>";
    regExp = [NSRegularExpression regularExpressionWithPattern:regPattern options:1 error:nil];
    noteTitle = [regExp stringByReplacingMatchesInString:noteTitle options:0 range:NSMakeRange(0, noteTitle.length) withTemplate:@""];
    //    NSLog(@"除去後2：%@", noteTitle);
    
    return noteTitle;
}

@end
