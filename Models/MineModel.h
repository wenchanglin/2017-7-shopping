//
//  MineModel.h
//  885logistics
//
//  Created by Blues on 17/1/9.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseModel.h"

@interface MineModel : BaseModel

@property (nonatomic, copy) NSString *titleName;

@property (nonatomic, copy) NSString *imgName;

@property (nonatomic, copy) NSString *isNow;

// 首页筛选订单
@property (nonatomic, copy) NSString *htype;


@end
