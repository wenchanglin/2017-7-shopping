//
//  PayHeader.m
//  885logistics
//
//  Created by Blues on 17/3/1.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "PayHeader.h"

@implementation PayHeader


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)attentionForUserBalance:(BOOL)balance ccb:(BOOL)ccb ali:(BOOL)ali weixin:(BOOL)weixin {
    if (balance) {
        self.balanceL.text = @"";
        self.balanceBt.hidden = NO;
        self.balanceBt.userInteractionEnabled = YES;
    }
    if (ccb) {
        self.ccbL.text = @"";
        self.ccbBt.hidden = NO;
        self.ccbBt.userInteractionEnabled = YES;
    }
    if (ali) {
        self.aliL.text = @"";
        self.aliBt.hidden = NO;
        self.aliBt.userInteractionEnabled = YES;
    }
    if (weixin) {
        self.wxL.text = @"";
        self.wxBt.hidden = NO;
        self.aliBt.userInteractionEnabled = YES;
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
