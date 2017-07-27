//
//  OrderDetailView.h
//  885logistics
//
//  Created by Blues on 17/1/20.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OrderModel;

@interface OrderDetailView : UIView

@property (weak, nonatomic) IBOutlet UIView *bk1;
@property (weak, nonatomic) IBOutlet UIView *bk2;
@property (weak, nonatomic) IBOutlet UIImageView *header;
@property (weak, nonatomic) IBOutlet UILabel *telNumber;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UIImageView *sexIv;
@property (weak, nonatomic) IBOutlet UILabel *company;
@property (weak, nonatomic) IBOutlet UIButton *goBt;
@property (weak, nonatomic) IBOutlet UIButton *callBt;
@property (weak, nonatomic) IBOutlet UIButton *bfBt;
@property (weak, nonatomic) IBOutlet UILabel *startLb;
@property (weak, nonatomic) IBOutlet UILabel *endLb;
@property (weak, nonatomic) IBOutlet UILabel *orderNumber;
@property (weak, nonatomic) IBOutlet UILabel *transportType;
@property (weak, nonatomic) IBOutlet UILabel *carType;
@property (weak, nonatomic) IBOutlet UILabel *carSize;
@property (weak, nonatomic) IBOutlet UILabel *carLoad;
@property (weak, nonatomic) IBOutlet UILabel *postmanLb;
@property (weak, nonatomic) IBOutlet UILabel *postTel;
@property (weak, nonatomic) IBOutlet UILabel *postAddress;
@property (weak, nonatomic) IBOutlet UILabel *weightLb;
@property (weak, nonatomic) IBOutlet UILabel *muchLb;
@property (weak, nonatomic) IBOutlet UILabel *attentionLb;
@property (weak, nonatomic) IBOutlet UILabel *getmanLb;
@property (weak, nonatomic) IBOutlet UILabel *getTel;
@property (weak, nonatomic) IBOutlet UILabel *getAddress;
@property (weak, nonatomic) IBOutlet UIView *bk11;
@property (weak, nonatomic) IBOutlet UIImageView *isInsuranceIv;
@property (weak, nonatomic) IBOutlet UILabel *insuranceLb;

@property (nonatomic, strong) OrderModel *myModel;

- (void)paddingOrderDetail:(OrderModel *)model;

@end
