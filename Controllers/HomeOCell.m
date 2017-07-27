//
//  HomeOCell.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/13.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "HomeOCell.h"
#import "OrderModel.h"

@implementation HomeOCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateViewWithOModel:(OrderModel *)model {
    
    if (_myModel != model) {
        _myModel = model;
    }
    [self getLineType:_myModel.type transClass:_myModel.modelType];
    self.dateLb.text = [LYHelper justDateStringWithInterval:_myModel.createTime dateFM:@"yyyy年MM月dd日"];
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
    self.instanceLb.text = [NSString stringWithFormat:@"%.2fkm",[_myModel.wayLong floatValue]];
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


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
