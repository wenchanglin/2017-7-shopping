//
//  MOTCell.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/10.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "MOTCell.h"
#import "OrderDetailController.h"
#import "MyOrdersController.h"
#import "PayViewController.h"
#import "SureViewController.h"
#import "BrokerageController.h"
#import "OrderModel.h"

@implementation MOTCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.leftBt.layer.masksToBounds = YES;
    self.leftBt.layer.cornerRadius = 2.f;
    self.rightBt.layer.masksToBounds = YES;
    self.rightBt.layer.cornerRadius = 2.f;
}

- (void)updateViewWithOModel:(OrderModel *)model {

    if (_myModel != model) {
        _myModel = model;
    }
    
    [self removerSelectors];
    
    [self getLineType:_myModel.type transClass:_myModel.modelType];
    self.dateLb.text = [LYHelper justDateStringWithInterval:_myModel.createTime dateFM:@"yyyy年MM月dd日"];
    self.numberLb.text = [NSString stringWithFormat:@"订单编号:%@",_myModel.fkOrderId];
    self.statusLb.text = [LYHelper getOrderStatus:_myModel.status];
    if ([_myModel.payPolicyStatus integerValue] == 10) {
        self.isSafeIv.hidden = NO;
    }else {
        self.isSafeIv.hidden = YES;
    }
    self.startLb.text = _myModel.fAddress;
    self.endLb.text = _myModel.sAddress;
    if (NotNilAndNull(_myModel.goodName)) {
        self.goodsName.text = _myModel.goodName;
    }
    if (NotNilAndNull(_myModel.goodSize)) {
        self.goodsSize.text = _myModel.goodSize;
    }
    self.goodsNum.text = [NSString stringWithFormat:@"%@箱",_myModel.goodNum];
    self.goodsWeight.text = [NSString stringWithFormat:@"%@Kg",_myModel.goodWeight];
    
    [self addTargetByOrderStatus];
}


- (void)addTargetByOrderStatus {

    NSString *status = _myModel.status;
    NSString *leftStr = nil;
    NSString *selectorLeft = nil;
    NSString *rightStr = nil;
    NSString *selectorRight = nil;
    self.leftCS.constant = 80.f;
    self.rightCS.constant = 80.f;
    [self.leftBt setBackgroundImage:[UIImage imageNamed:@"bk35"] forState:UIControlStateNormal];
    [self.rightBt setBackgroundImage:[UIImage imageNamed:@"bk36"] forState:UIControlStateNormal];
    
    if ([status isEqualToString:@"待处理_暂未报价"] || [status isEqualToString:@"待处理_待客户付款"])
    {
        rightStr = @"取消订单";
        selectorRight = @"cancelOrder";
        self.statusLb.text = @"已报价";
        [self.rightBt setBackgroundImage:[UIImage imageNamed:@"bk35"] forState:UIControlStateNormal];
        self.leftCS.constant = 1.f;
    }
    else if ([status isEqualToString:@"待处理_待付保证金"])
    {
        leftStr = @"取消订单";
        selectorLeft = @"cancelOrder";
        rightStr = @"支付保证金";
        selectorRight = @"payOrder";
    }
    else if ([status isEqualToString:@"待运输"] ||[status isEqualToString:@"待运输_待支付投保"])
    {
        leftStr = @"申请取消";
        selectorLeft = @"cancelOrder";
        rightStr = @"开始运输";
        selectorRight = @"startTrans";
    }
    else if ([status isEqualToString:@"运输中"])
    {
        leftStr = @"投诉";
        selectorLeft = @"reportDriver";
        rightStr = @"确认送达";
        selectorRight = @"finishOrder";
    }
    else if ([status isEqualToString:@"运输中_待用户收货"])
    {
        rightStr = @"投诉";
        selectorRight = @"reportDriver";
        self.leftCS.constant = 2.f;
        [self.leftBt setBackgroundImage:nil forState:UIControlStateNormal];
    }
    else if ([status isEqualToString:@"已完成_待支付佣金"])
    {
        rightStr = @"支付平台佣金";
        selectorRight = @"payMoneyForBbw";
        self.leftCS.constant = 1.f;
    }
    else if ([status isEqualToString:@"已完成"]||[status isEqualToString:@"已完成_已关闭"])
    {
        rightStr = @"";
        self.leftCS.constant = 1.f;
        [self.rightBt setBackgroundImage:nil forState:UIControlStateNormal];
    }
    if (NotNilAndNull(leftStr)) {
        
        [self.leftBt setTitle:leftStr forState:UIControlStateNormal];
        if (NotNilAndNull(selectorLeft)) {
            SEL selectorL = NSSelectorFromString(selectorLeft);
            [self.leftBt addTarget:self action:selectorL forControlEvents:UIControlEventTouchUpInside];
        }
        self.leftBt.hidden = NO;
    }else {
        self.leftBt.hidden = YES;
    }
    if (NotNilAndNull(rightStr)) {
        
        [self.rightBt setTitle:rightStr forState:UIControlStateNormal];
        if (NotNilAndNull(selectorRight)) {
            SEL selectorR = NSSelectorFromString(selectorRight);
            [self.rightBt addTarget:self action:selectorR forControlEvents:UIControlEventTouchUpInside];
        }
        self.rightBt.hidden = NO;
    }else {
        self.rightBt.hidden = YES;
    }
    [self updateConstraintsIfNeeded];
}

- (void)getLineType:(NSString *)type transClass:(NSString *)ts {
    
    NSString *text = nil;
    if ([type isEqualToString:@"1"]) {
        text = [NSString stringWithFormat:@"专线*%@",ts];
        self.kindLb.backgroundColor = LineIndigoColor;
    }else if ([type isEqualToString:@"2"]){
        text = [NSString stringWithFormat:@"拼车*%@",ts];
        self.kindLb.backgroundColor = LineBrownColor;
    }else {
        text = [NSString stringWithFormat:@"整车*%@",ts];
        self.kindLb.backgroundColor = LineRedColor;
    }
    self.kindLb.text = text;
}

- (void)removerSelectors {

    NSArray *selectorArray1 = @[@"cancelOrder",@"payOrder",@"startTrans",@"finishOrder",@"payMoneyForBbw",@"reportDriver"];
    for (NSString *tmp in selectorArray1) {
        SEL selectorR = NSSelectorFromString(tmp);
        [self.rightBt removeTarget:self action:selectorR forControlEvents:UIControlEventTouchUpInside];
    }
    NSArray *selectorArray2 = @[@"cancelOrder",@"reportDriver"];
    for (NSString *tmp in selectorArray2) {
        SEL selectorR = NSSelectorFromString(tmp);
        [self.leftBt removeTarget:self action:selectorR forControlEvents:UIControlEventTouchUpInside];
    }
}


- (void)cancelOrder {
    
    OrderDetailController *detail = [[OrderDetailController alloc] init];
    [detail addPopItem];
    detail.model = _myModel;
    detail.isCancel = @"YES";
    detail.hidesBottomBarWhenPushed = YES;
    [self.home.navigationController pushViewController:detail animated:YES];
}

- (void)finishOrder {
    
    OrderDetailController *detail = [[OrderDetailController alloc] init];
    [detail addPopItem];
    detail.model = _myModel;
    detail.end = @"YES";
    detail.hidesBottomBarWhenPushed = YES;
    [self.home.navigationController pushViewController:detail animated:YES];
}

- (void)payOrder {
    
    PayViewController *detail = [[PayViewController alloc] init];
    [detail addPopItem];
    detail.myModel = _myModel;
    detail.hidesBottomBarWhenPushed = YES;
    [self.home.navigationController pushViewController:detail animated:YES];
}

//______________ 司机支付佣金给平台____________
- (void)payMoneyForBbw {

    OrderDetailController *detail = [[OrderDetailController alloc] init];
    [detail addPopItem];
    detail.model = _myModel;
    detail.isPay = @"YES";
    detail.hidesBottomBarWhenPushed = YES;
    [self.home.navigationController pushViewController:detail animated:YES];
}

- (void)startTrans {

    OrderDetailController *detail = [[OrderDetailController alloc] init];
    [detail addPopItem];
    detail.model = _myModel;
    detail.begin = @"YES";
    detail.hidesBottomBarWhenPushed = YES;
    [self.home.navigationController pushViewController:detail animated:YES];
}

- (void)reportDriver {
    
    SureViewController *detail = [[SureViewController alloc] init];
    [detail addPopItem];
    detail.myModel = _myModel;
    detail.hidesBottomBarWhenPushed = YES;
    [self.home.navigationController pushViewController:detail animated:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
