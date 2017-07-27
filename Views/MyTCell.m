//
//  MyTCell.m
//  CustomFurniture
//
//  Created by Blues on 16/10/18.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "MyTCell.h"

@implementation MyTCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    CGFloat width = 65.f * 0.8;
    self.iv.layer.masksToBounds = YES;
    self.iv.layer.cornerRadius = width/2.f;    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
