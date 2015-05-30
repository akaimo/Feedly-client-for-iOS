//
//  AKASettingViewController.h
//  rss
//
//  Created by akaimo on 2015/05/10.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AKASettingViewController : UITableViewController

typedef NS_ENUM(char, SaveDay) {
    Never,
    Day1,
    Day2,
    Day3,
    Week1,
    Week2,
    Month1,
    
    SDend
};

typedef NS_ENUM(int, RightSwipe) {
    RNon,
    RRead,
    RSaved,
    
    Rend
};

typedef NS_ENUM(int, LeftSwipe) {
    LNon,
    LRead,
    LSaved,
    
    Lend
};

typedef NS_ENUM(int, OrderItems) {
    OlderFirst,
    NewestFirst,
    
    OrderCount
};

@end
