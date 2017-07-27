//
//  HomeOCell.h
//  LogisticsDriver
//
//  Created by Blues on 17/3/13.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderModel;

@interface HomeOCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *kindLb;
@property (weak, nonatomic) IBOutlet UILabel *instanceLb;
@property (weak, nonatomic) IBOutlet UILabel *dateLb;
@property (weak, nonatomic) IBOutlet UILabel *endLb;
@property (weak, nonatomic) IBOutlet UILabel *startLb;
@property (weak, nonatomic) IBOutlet UILabel *goodsName;
@property (weak, nonatomic) IBOutlet UILabel *goodsNum;
@property (weak, nonatomic) IBOutlet UILabel *goodsSize;
@property (weak, nonatomic) IBOutlet UILabel *goodsWeight;
@property (nonatomic, strong) OrderModel *myModel;

- (void)updateViewWithOModel:(OrderModel *)model;
@end
