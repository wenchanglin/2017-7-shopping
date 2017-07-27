//
//  KindsModel.h
//  885logistics
//
//  Created by Blues on 17/1/3.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseModel.h"

@interface KindsModel : BaseModel

@property (nonatomic, copy) NSString      *kindID;//数据ID
@property (nonatomic, copy) NSString      *text; //文字描述
@property (nonatomic, copy) NSString      *isNow;
@property (nonatomic, copy) NSNumber      *createTime;//创建时间
@property (nonatomic, copy) NSNumber      *insuranceRate;


@end
