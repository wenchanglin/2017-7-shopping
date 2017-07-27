//
//  TSListController.h
//  LogisticsDriver
//
//  Created by Blues on 17/3/9.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseViewController.h"

@class KindsModel;

typedef void(^RTKindBlock)(KindsModel *model);

@interface TSListController : BaseViewController

@property (nonatomic, copy) RTKindBlock myBlock;

- (instancetype)initWithRTKindBlock:(RTKindBlock)block;


@end
