//
//  PayHeader.h
//  885logistics
//
//  Created by Blues on 17/3/1.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayHeader : UIView

@property (weak, nonatomic) IBOutlet UILabel *payMoney;
@property (weak, nonatomic) IBOutlet UIButton *balanceBt;
@property (weak, nonatomic) IBOutlet UIButton *ccbBt;
@property (weak, nonatomic) IBOutlet UIButton *aliBt;
@property (weak, nonatomic) IBOutlet UIButton *wxBt;
@property (weak, nonatomic) IBOutlet UIButton *payBt;
@property (weak, nonatomic) IBOutlet UILabel *balanceL;
@property (weak, nonatomic) IBOutlet UILabel *ccbL;
@property (weak, nonatomic) IBOutlet UILabel *aliL;
@property (weak, nonatomic) IBOutlet UILabel *wxL;

- (void)attentionForUserBalance:(BOOL)balance ccb:(BOOL)ccb ali:(BOOL)ali weixin:(BOOL)weixin;

@end
