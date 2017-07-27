
//
//  SearchTCell.m
//  885logistics
//
//  Created by Blues on 17/1/20.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "SearchTCell.h"
#import "UserModel.h"

@implementation SearchTCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.iv.layer.masksToBounds = YES;
    self.iv.layer.cornerRadius = 24.f;
}

- (void)updateViewsWith:(UserModel *)model {

    if (_myModel != model) {
        _myModel = model;
    }
    if (NotNilAndNull(_myModel.imageUrl)) {
        NSString *urlStr = [NSString stringWithFormat:ImgLoadUrl,_myModel.imageUrl];
        [self.iv sd_setImageWithURL:[NSURL URLWithString:urlStr]];
    }
    self.nameLb.text = _myModel.userName;
    self.phone.text = _myModel.phone;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
