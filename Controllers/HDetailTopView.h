//
//  HDetailTopView.h
//  LogisticsDriver
//
//  Created by Blues on 17/3/13.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderModel;

@interface HDetailTopView : UIView

@property (weak, nonatomic) IBOutlet UILabel *kindLb;
@property (weak, nonatomic) IBOutlet UILabel *wayLongLb;
@property (weak, nonatomic) IBOutlet UILabel *fArea;
@property (weak, nonatomic) IBOutlet UILabel *fDetail;
@property (weak, nonatomic) IBOutlet UILabel *sArea;
@property (weak, nonatomic) IBOutlet UILabel *sDetail;
@property (weak, nonatomic) IBOutlet UILabel *startTime;
@property (weak, nonatomic) IBOutlet UILabel *endTime;
@property (weak, nonatomic) IBOutlet UILabel *numberLb;
@property (weak, nonatomic) IBOutlet UILabel *transLb;
@property (weak, nonatomic) IBOutlet UILabel *carModel;
@property (weak, nonatomic) IBOutlet UILabel *carLoad;
@property (weak, nonatomic) IBOutlet UILabel *carSize;
@property (weak, nonatomic) IBOutlet UILabel *goodWeight;
@property (weak, nonatomic) IBOutlet UILabel *goodMsg;
@property (weak, nonatomic) IBOutlet UIButton *offerBt;

@property (nonatomic, strong) OrderModel *myModel;
- (void)updateViewWithHDModel:(OrderModel *)model;
@end
