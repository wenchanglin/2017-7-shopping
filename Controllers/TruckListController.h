//
//  TruckListController.h
//  LogisticsDriver
//
//  Created by Blues on 17/3/6.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseViewController.h"

@class CarTypeModel;

typedef void(^RTTruckBlock)(CarTypeModel *model);

@interface TruckListController : BaseViewController

@property (nonatomic, copy) RTTruckBlock myBlock;

- (instancetype)initWithRTTruckBlock:(RTTruckBlock)myblock;


@end
