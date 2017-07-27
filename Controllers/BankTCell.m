//
//  BankTCell.m
//  885logistics
//
//  Created by Blues on 17/1/19.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BankTCell.h"
#import "BCardsModel.h"

@implementation BankTCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)updateViewWith:(BCardsModel *)model {

    if (_myModel != model) {
        _myModel = model;
    }
    self.bankName.text = model.cardType;
    NSString *cardNumber = model.cardNum;
    if (cardNumber.length > 5) {
        self.numberLb.text = [model.cardNum substringFromIndex:cardNumber.length - 4];
    }
    if (NotNilAndNull(model.imgUrl)) {
        NSString *url = [NSString stringWithFormat:ImgLoadUrl,model.imgUrl];
        [self.bankIv sd_setImageWithURL:[NSURL URLWithString:url]];
    }else {
        self.bankIv.image = nil;
    }
}

- (IBAction)delete:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteBankCardBy:)]) {
        [self.delegate deleteBankCardBy:_myModel];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
