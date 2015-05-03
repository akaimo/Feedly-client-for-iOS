//
//  AKADetailCustomCell.m
//  rss
//
//  Created by akaimo on 2015/05/01.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKADetailCustomCell.h"

@implementation AKADetailCustomCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(CGFloat) height {
    CGFloat bodyLabelW = _title.bounds.size.height;
    CGSize bodySize = [_title.attributedText boundingRectWithSize:CGSizeMake(bodyLabelW, MAXFLOAT)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                                  context:nil].size;
    
    return bodySize.height;
}

@end
