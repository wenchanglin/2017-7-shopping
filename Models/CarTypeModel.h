//
//  CarTypeModel.h
//  885logistics
//
//  Created by Blues on 17/2/16.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseModel.h"

@interface CarTypeModel : BaseModel

@property (nonatomic, copy) NSString *carModel;
@property (nonatomic, copy) NSString *isNow;
@property (nonatomic, copy) NSString *CarID;
@property (nonatomic, copy) NSString *modelSize;
@property (nonatomic, copy) NSString *modelWeight;

@end
