//
//  CityModel.h
//  LogisticsDriver
//
//  Created by Blues on 17/3/14.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseModel.h"

@interface CityModel : BaseModel

@property (nonatomic, copy) NSString *supCity;
@property (nonatomic, copy) NSString *cityID;
@property (nonatomic, copy) NSString *isMine;

@end
