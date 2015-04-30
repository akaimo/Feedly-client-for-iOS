//
//  AKAImgCustomCell.h
//  rss
//
//  Created by akaimo on 2015/04/29.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AKAImgCustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *siteTitle;
@property (weak, nonatomic) IBOutlet UILabel *detail;

@end
