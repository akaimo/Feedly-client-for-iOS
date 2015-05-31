//
//  AKANavigationController.h
//  rss
//
//  Created by akaimo on 2015/05/08.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FCVerticalMenu/FCVerticalMenu.h>

@interface AKANavigationController : UINavigationController <FCVerticalMenuDelegate>

typedef NS_ENUM(int, FeedStatus) {
    UnreadItems = 1,
    SavedItems = 2,
    AllItems = 3,
    Pocket = 4
};

@property (strong, readonly, nonatomic) FCVerticalMenu *verticalMenu;

-(IBAction)openVerticalMenu:(id)sender;

@end
