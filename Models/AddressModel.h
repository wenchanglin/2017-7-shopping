//
//  AddressModel.h
//  CustomFurniture
//
//  Created by Blues on 16/11/30.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "BaseModel.h"

@interface AddressModel : BaseModel


@property (nonatomic, strong) NSString *adressID;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *phone;

@property (nonatomic, strong) NSString *detailedAddress;

@property (nonatomic, strong) NSString *detailStr;

@property (nonatomic, strong) NSString *provinceId;

@property (nonatomic, strong) NSString *cityId;

@property (nonatomic, strong) NSString *areaId;

@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) NSString *create_time;

@property (nonatomic, strong) NSString *province;

@property (nonatomic, strong) NSString *city;

@property (nonatomic, strong) NSString *area;


@end
