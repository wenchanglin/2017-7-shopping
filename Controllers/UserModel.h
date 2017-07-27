//
//  UserModel.h
//  885logistics
//
//  Created by Blues on 17/2/23.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseModel.h"

@interface UserModel : BaseModel

@property (nonatomic, copy) NSString *fkUserId;
@property (nonatomic, copy) NSString *roleType;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *remark;

@end
