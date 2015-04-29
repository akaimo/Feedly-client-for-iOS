//
//  AKATopCustomCell.m
//  rss
//
//  Created by akaimo on 2015/04/28.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKATopCustomCell.h"

@implementation AKATopCustomCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)topRowHeight {
    return 66.0f;
}

+ (CGFloat)secondRowHeight {
    return 44.0f;
}

@end
