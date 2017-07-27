//
//  OrderDetailView.m
//  885logistics
//
//  Created by Blues on 17/1/20.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "OrderDetailView.h"
#import "OrderModel.h"

@implementation OrderDetailView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.header.layer.masksToBounds = YES;
    self.header.layer.cornerRadius = 25.f;
}

- (void)paddingOrderDetail:(OrderModel *)model {

    if (_myModel != model) {
        _myModel = model;
    }
    [self updateEmployInfo];
    self.startLb.text = _myModel.startTime;
    self.endLb.text = _myModel.endTime;
    self.orderNumber.text = _myModel.fkOrderId;
    self.transportType.text = _myModel.modelType;
    self.carType.text = _myModel.carModel;
    self.carSize.text = _myModel.modelSize;
    self.carLoad.text = [NSString stringWithFormat:@"%@Kg",_myModel.modelWeight];
    self.weightLb.text = [NSString stringWithFormat:@"%@Kg",_myModel.goodWeight];
    self.muchLb.text = [NSString stringWithFormat:@"%@箱",_myModel.goodNum];
    self.attentionLb.text = _myModel.goodDescribe;
    self.postTel.text = _myModel.fTel;
    self.postAddress.text = _myModel.fAddress;
    self.postmanLb.text = _myModel.fUserName;
    self.getmanLb.text = _myModel.sUserName;
    self.getAddress.text = _myModel.sAddress;
    self.getTel.text = _myModel.sTel;
    if (IsEmptyStr(_myModel.fkGoodPolicy)) {
        self.bk11.hidden = YES;
    }else {
        self.bk11.hidden = NO;
    }
}


- (void)updateEmployInfo {
    
    if (IsNilOrNull(_myModel.fkUserId)) {
        return;
    }
    NSDictionary *param = @{@"uid":_myModel.fkUserId};
    
    [[LYAPIManager sharedInstance] POST:@"transportion/employ/queryEmployDetails" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([result[@"errcode"] integerValue] == 0) {
            
            if (NotNilAndNull(result[@"data"])) {
                
                NSDictionary *data = result[@"data"];
                if (NotNilAndNull(data[@"userInfoBase"])) {
                    NSDictionary *userInfoBase = data[@"userInfoBase"];
                    if (NotNilAndNull(userInfoBase[@"userName"])) {
                        self.nickName.text = userInfoBase[@"userName"];
                    }
                    if (NotNilAndNull(userInfoBase[@"phone"])) {
                        self.telNumber.text = userInfoBase[@"phone"];
                        _myModel.employTel = userInfoBase[@"phone"];
                    }
                    if (NotNilAndNull(userInfoBase[@"userPhoto"])) {
                        NSDictionary *userPhoto = userInfoBase[@"userPhoto"];
                        NSString *imgUrlStr = [NSString stringWithFormat:ImgLoadUrl,userPhoto[@"location"]];
                        [self.header sd_setImageWithURL:[NSURL URLWithString:imgUrlStr]];
                    }
                }
                
                if (NotNilAndNull(data[@"sex"])) {
                    NSString *sex = data[@"sex"];
                    if ([sex isEqualToString:@"男"]) {
                        self.sexIv.image = [UIImage imageNamed:@"man"];
                    }else if ([sex isEqualToString:@"女"]){
                        self.sexIv.image = [UIImage imageNamed:@"lady"];
                    }
                }
                if (NotNilAndNull(data[@"companyName"])) {
                    self.company.text = data[@"companyName"];
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

}











@end
