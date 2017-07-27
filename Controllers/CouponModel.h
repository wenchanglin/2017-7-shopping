//
//  CouponModel.h
//  885logistics
//
//  Created by Blues on 17/2/22.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseModel.h"

@interface CouponModel : BaseModel



@property (nonatomic, copy) NSString *fkCouponId;
@property (nonatomic, copy) NSString *fkUserId;
@property (nonatomic, copy) NSString *fkVoucher;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *voucherName;
@property (nonatomic, copy) NSNumber *amounts;
@property (nonatomic, copy) NSNumber *useRequire;
@property (nonatomic, copy) NSString *term;
@property (nonatomic, copy) NSNumber *createTime;

@property (nonatomic, copy) NSString *isNow;


@end
