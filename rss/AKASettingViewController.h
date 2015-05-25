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
    Never = 1,
    Day1 = 2,
    Day2 = 3,
    Day3 = 4,
    Week1 = 5,
    Week2 = 6,
    Month1 = 7
};

typedef NS_ENUM(int, RightSwipe) {
    RNon = 0,
    RRead = 1,
    RSaved = 2
};

typedef NS_ENUM(int, LeftSwipe) {
    LNon = 0,
    LRead = 1,
    LSaved = 2
};

@end
