//
//  SecureDTO.h
//  885logistics
//
//  Created by Blues on 17/3/8.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseModel.h"

@interface SecureDTO : BaseModel

@property (nonatomic, copy) NSString *fkSecureId;     // 数据ID
@property (nonatomic, copy) NSString *fkUserId;
@property (nonatomic, copy) NSString *goodClass;
@property (nonatomic, copy) NSString *goodName;
@property (nonatomic, copy) NSNumber *insuranceFee;   // 保险费用
@property (nonatomic, copy) NSNumber *insuranceRate;  // 保险费率
@property (nonatomic, copy) NSNumber *packingNumber;  // 箱
@property (nonatomic, copy) NSNumber *pieces;         // 件
@property (nonatomic, copy) NSNumber *price;          // 单价
@property (nonatomic, copy) NSNumber *status;         // 状态
@property (nonatomic, copy) NSNumber *sumPrice;       // 总价
//@property (nonatomic, copy) NSString *fkUserId;
//@property (nonatomic, copy) NSString *fkUserId;
//@property (nonatomic, copy) NSString *fkUserId;
//@property (nonatomic, copy) NSString *fkUserId;
//@property (nonatomic, copy) NSString *fkUserId;
//@property (nonatomic, copy) NSString *fkUserId;
//@property (nonatomic, copy) NSString *fkUserId;
//@property (nonatomic, copy) NSString *fkUserId;
//@property (nonatomic, copy) NSString *fkUserId;
//@property (nonatomic, copy) NSString *fkUserId;





@end
