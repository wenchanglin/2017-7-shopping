//
//  OrderTCell.h
//  885logistics
//
//  Created by Blues on 17/1/9.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderTCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *topbk;
@property (weak, nonatomic) IBOutlet UIView *showCarView;
@property (weak, nonatomic) IBOutlet UIButton *showCarbt;
@property (weak, nonatomic) IBOutlet UIView *okView;
@property (weak, nonatomic) IBOutlet UILabel *okMoneyLb;
@property (weak, nonatomic) IBOutlet UILabel *dateLb;
@property (weak, nonatomic) IBOutlet UILabel *typeLb;
@property (weak, nonatomic) IBOutlet UIImageView *isSafeIv;

@property (weak, nonatomic) IBOutlet UIView *middlebk;
@property (weak, nonatomic) IBOutlet UILabel *endAddress;
@property (weak, nonatomic) IBOutlet UILabel *startAddress;

@property (weak, nonatomic) IBOutlet UIView *bottombk;
@property (weak, nonatomic) IBOutlet UILabel *orderNumber;
@property (weak, nonatomic) IBOutlet UIButton *rightBt;
@property (weak, nonatomic) IBOutlet UIButton *leftBt;


@end
