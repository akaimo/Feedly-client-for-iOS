//
//  AKATopCustomCell.h
//  rss
//
//  Created by akaimo on 2015/04/28.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AKATopCustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *unreadCount;

+ (CGFloat)topRowHeight;
+ (CGFloat)secondRowHeight;

@end
