//
//  InsuranceTCell.m
//  885logistics
//
//  Created by Blues on 17/1/16.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "InsuranceTCell.h"
#import "SecureDTO.h"

@implementation InsuranceTCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)loadDataFromSecureDTO:(SecureDTO *)dto {

    if (_sDto != dto) {
        _sDto = dto;
    }
    self.typeLb.text = _sDto.goodClass;
    self.rateLb.text = [NSString stringWithFormat:@"%@%%",_sDto.insuranceRate];
    self.nameLb.text = _sDto.goodName;
    self.quantity1.text = [_sDto.packingNumber stringValue];
    self.quantity2.text = [_sDto.pieces stringValue];
    self.singleP.text = [_sDto.price stringValue];
    self.allp.text = [_sDto.sumPrice stringValue];
    self.insuranceLb.text = [_sDto.insuranceFee stringValue];
}


- (IBAction)deleteClicked:(UIButton *)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(deleteCellBySecureDTO:)]){
        [self.delegate deleteCellBySecureDTO:_sDto];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
