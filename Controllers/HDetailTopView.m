//
//  HDetailTopView.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/13.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "HDetailTopView.h"
#import "OrderModel.h"



@implementation HDetailTopView


- (void)awakeFromNib {
    
    [super awakeFromNib];

}

- (void)updateViewWithHDModel:(OrderModel *)model {

    if (_myModel != model) {
        _myModel = model;
    }
    self.startTime.text = _myModel.startTime;
    self.endTime.text = _myModel.endTime;
    self.numberLb.text = _myModel.fkOrderId;
    self.wayLongLb.text = [NSString stringWithFormat:@"%.2fkm",[_myModel.wayLong floatValue]];
    
    NSInteger type = [_myModel.type integerValue];
    if (type == 1) {
        self.kindLb.text = @"专线订单";
    }else if (type == 2){
        self.kindLb.text = @"拼车订单";
    }else if (type == 3){
        self.kindLb.text = @"整车订单";
    }
    self.transLb.text = _myModel.modelType;
    self.carModel.text = _myModel.carModel;
    self.carSize.text = _myModel.modelSize;
    self.carLoad.text = [NSString stringWithFormat:@"%@Kg",_myModel.modelWeight];
    self.goodWeight.text = [NSString stringWithFormat:@"%@Kg",_myModel.goodWeight];
    self.goodMsg.text = _myModel.goodDescribe;
    self.fArea.text = _myModel.fAreas;
    self.fDetail.text = _myModel.fDetail;
    self.sArea.text = _myModel.sAreas;
    self.sDetail.text = _myModel.sDetail;
}








@end
