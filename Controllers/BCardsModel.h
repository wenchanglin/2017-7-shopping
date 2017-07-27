//
//  BCardsModel.h
//  885logistics
//
//  Created by Blues on 17/2/7.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseModel.h"

@interface BCardsModel : BaseModel

@property (nonatomic, copy) NSString *fkCardID;//平台ID
@property (nonatomic, copy) NSString *fkUserId;//用户ID

@property (nonatomic, copy) NSString *bankOpen;//开户行
@property (nonatomic, copy) NSString *cardType;//银行名称
@property (nonatomic, copy) NSString *cardNum;//银行卡号
@property (nonatomic, copy) NSString *bankOwner;//银行卡持有人
@property (nonatomic, copy) NSString *tel;//银行卡预留电话

@property (nonatomic, copy) NSString *status;//可用状态 ？

@property (nonatomic, copy) NSNumber *createTime;//添加时间
@property (nonatomic, copy) NSString *delFlag;

@property (nonatomic, copy) NSString *transInfoBank;//银行信息

@property (nonatomic, copy) NSString *imgUrl;

@property (nonatomic, copy) NSString *isNow;

@end
