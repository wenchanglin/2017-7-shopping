//
//  LineTCell.m
//  LogisticsDriver
//
//  Created by Blues on 17/1/23.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "LineTCell.h"
#import "LineModel.h"

@implementation LineTCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)updateViewWithLine:(LineModel *)model {

    if (_myModel != model) {
        _myModel = model;
    }
    self.wayLongLb.text = [NSString stringWithFormat:@"约%.2fkm",[_myModel.lineLong floatValue]];
    self.fAera.text = _myModel.lineStart;
    self.fDetail.text = _myModel.detailStarAddr;
    self.dayLong.text = [NSString stringWithFormat:@"预计%@天",_myModel.lineDay];
    self.sAera.text = _myModel.lineEnd;
    self.sDetail.text = _myModel.detailEndAddr;
}

- (IBAction)deleteClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteLineWithLineID:)]) {
        [self.delegate deleteLineWithLineID:_myModel];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
