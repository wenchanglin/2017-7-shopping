//
//  OrderModel.h
//  885logistics
//
//  Created by Blues on 17/1/9.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseModel.h"

@interface OrderModel : BaseModel

@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *isSafe;

@property (nonatomic, copy) NSString *fkOrderId;// 数据ID
@property (nonatomic, copy) NSNumber *wayLong;
@property (nonatomic, copy) NSString *type;  // 线路类型
@property (nonatomic, copy) NSNumber *isFriend; // 是否好友
@property (nonatomic, copy) NSString *fkDriverId; // 司机ID
@property (nonatomic, copy) NSString *startTime; // 开始时间
@property (nonatomic, copy) NSString *endTime; // 结束时间
@property (nonatomic, copy) NSNumber *goodWeight; // 货物重量
@property (nonatomic, copy) NSNumber *goodNum;   // 货物数量
@property (nonatomic, copy) NSString *goodName;  // 货物名称
@property (nonatomic, copy) NSString *goodSize;     // 货物规格
@property (nonatomic, copy) NSString *goodDescribe;// 货物描述
@property (nonatomic, copy) NSString *fkGoodPolicy;// 投保单
@property (nonatomic, copy) NSString *referencePrice;// 参考价格
@property (nonatomic, copy) NSNumber *offer;// 报价
@property (nonatomic, copy) NSString *finalPrice;// 最终价格
@property (nonatomic, copy) NSString *status;// 订单状态
@property (nonatomic, copy) NSNumber *createTime;// 订单创建时间
@property (nonatomic, copy) NSString *roleType;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *fkUserId;

/* 货主信息 */
@property (nonatomic, copy) NSString *employImg;
@property (nonatomic, copy) NSString *employSex;
@property (nonatomic, copy) NSString *employName;
@property (nonatomic, copy) NSString *employTel;
@property (nonatomic, copy) NSString *employCompany;

/* 运输信息 */
@property (nonatomic, copy) NSString *carModel;//货车型号
@property (nonatomic, copy) NSString *modelSize;//车厢尺寸
@property (nonatomic, copy) NSNumber *modelWeight;//载重
@property (nonatomic, copy) NSString *modelType;// 运输类型

/* 发货信息 */
@property (nonatomic, copy) NSString *fUserName;
@property (nonatomic, copy) NSString *fTel;
@property (nonatomic, copy) NSString *fAreas;
@property (nonatomic, copy) NSString *fDetail;
@property (nonatomic, copy) NSString *fAddress;

/* 收货信息 */
@property (nonatomic, copy) NSString *sUserName;
@property (nonatomic, copy) NSString *sTel;
@property (nonatomic, copy) NSString *sAreas;
@property (nonatomic, copy) NSString *sDetail;
@property (nonatomic, copy) NSString *sAddress;

/* 保单 */
@property (nonatomic, copy) NSNumber *payPolicyStatus;
@property (nonatomic, copy) NSNumber *goodPolicyM;
@property (nonatomic, copy) NSString *policyPayId;



@end
