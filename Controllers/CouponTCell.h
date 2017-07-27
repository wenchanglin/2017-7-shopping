//
//  CouponTCell.h
//  885logistics
//
//  Created by Blues on 17/1/9.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponTCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *bkView;
@property (weak, nonatomic) IBOutlet UIButton *imgBt;
@property (weak, nonatomic) IBOutlet UILabel *limitDate;
@property (weak, nonatomic) IBOutlet UILabel *otherLb;
@property (weak, nonatomic) IBOutlet UILabel *muchLb;
@property (weak, nonatomic) IBOutlet UILabel *couponName;

@end
