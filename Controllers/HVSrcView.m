//
//  HVSrcView.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/19.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "HVSrcView.h"

@implementation HVSrcView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.bk.layer.masksToBounds = YES;
    self.bk.layer.cornerRadius = 1.f;
}


@end
