//
//  OrderDetailController.h
//  885logistics
//
//  Created by Blues on 17/1/20.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseViewController.h"

@class OrderModel;

@interface OrderDetailController : BaseViewController

@property (nonatomic, strong) OrderModel *model;
@property (nonatomic, strong) NSString *isCancel;
@property (nonatomic, strong) NSString *begin;
@property (nonatomic, strong) NSString *end;
@property (nonatomic, strong) NSString *isPay;

@end
