//
//  AKAPocketSynchronized.m
//  rss
//
//  Created by akaimo on 2015/06/01.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKAPocketSynchronized.h"
#import "PocketAPI.h"
#import "JDStatusBarNotification.h"

@implementation AKAPocketSynchronized

- (void)synchro:(UITableView *)tableView {
    [JDStatusBarNotification showWithStatus:@"Syscing..."];
    
// TODO: get unreadItem
    [[PocketAPI sharedAPI] callAPIMethod:@"get" withHTTPMethod:PocketAPIHTTPMethodPOST arguments:nil handler:^(PocketAPI *api, NSString *apiMethod, NSDictionary *response, NSError *error) {
        NSLog(@"%@", response);
    }];
    
// TODO: get savedItem
    NSDictionary *dic = [NSDictionary dictionaryWithObject:@"1" forKey:@"favorite"];
    [[PocketAPI sharedAPI] callAPIMethod:@"get" withHTTPMethod:PocketAPIHTTPMethodPOST arguments:dic handler:^(PocketAPI *api, NSString *apiMethod, NSDictionary *response, NSError *error) {
    }];
    
// TODO: delete a few day ago archive item
    
    [JDStatusBarNotification showProgress:1.0];
    
    [tableView reloadData];
    
    [JDStatusBarNotification showWithStatus:@"Sync Success!" dismissAfter:1.5 styleName:JDStatusBarStyleSuccess];
}

@end
