//
//  BillModel.h
//  CustomFurniture
//
//  Created by Blues on 16/12/13.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "BaseModel.h"

@interface BillModel : BaseModel

@property (nonatomic, strong) NSString *fkBillID;//数据ID

@property (nonatomic, strong) NSString *fkUserId;
@property (nonatomic, strong) NSNumber *money;

@property (nonatomic, strong) NSString *cardType;// 银行
@property (nonatomic, strong) NSString *cardNum;//银行卡号
@property (nonatomic, strong) NSString *bankOwner;//卡持有人
@property (nonatomic, strong) NSString *bankOpen;//开户行
@property (nonatomic, strong) NSString *tel;//银行预留电话

@property (nonatomic, strong) NSString *status;// 状态 成功/失败
@property (nonatomic, strong) NSString *goal;// 操作类型

@property (nonatomic, strong) NSNumber *createTime;//操作时间


@end
