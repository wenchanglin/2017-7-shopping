//
//  MOTCell.h
//  LogisticsDriver
//
//  Created by Blues on 17/3/10.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderModel,MyOrdersController;

@interface MOTCell : UITableViewCell

@property (nonatomic, weak) MyOrdersController *home;

@property (weak, nonatomic) IBOutlet UILabel *kindLb;
@property (weak, nonatomic) IBOutlet UILabel *statusLb;
@property (weak, nonatomic) IBOutlet UIImageView *isSafeIv;
@property (weak, nonatomic) IBOutlet UILabel *dateLb;
@property (weak, nonatomic) IBOutlet UILabel *endLb;
@property (weak, nonatomic) IBOutlet UILabel *startLb;
@property (weak, nonatomic) IBOutlet UILabel *goodsName;
@property (weak, nonatomic) IBOutlet UILabel *goodsNum;
@property (weak, nonatomic) IBOutlet UILabel *goodsSize;
@property (weak, nonatomic) IBOutlet UILabel *goodsWeight;
@property (weak, nonatomic) IBOutlet UILabel *numberLb;
@property (weak, nonatomic) IBOutlet UIButton *rightBt;
@property (weak, nonatomic) IBOutlet UIButton *leftBt;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightCS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftCS;

@property (nonatomic, strong) OrderModel *myModel;
- (void)updateViewWithOModel:(OrderModel *)model;

@end
