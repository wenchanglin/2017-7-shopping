//
//  CityCCell.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/14.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "CityCCell.h"
#import "CityModel.h"

@implementation CityCCell

- (void)awakeFromNib {
    [super awakeFromNib];

    // Initialization code
}

- (void)updateViewWithCity:(CityModel *)model {

    if (_myModel != model) {
        _myModel = model;
    }
    self.cityLb.text = _myModel.supCity;
    
    if ([_myModel.isMine isEqualToString:@"YES"]) {
        [self.bt setImage:[UIImage imageNamed:@"cv_delete"] forState:UIControlStateNormal];
        [self.bt addTarget:self action:@selector(deleteCity) forControlEvents:UIControlEventTouchUpInside];
    }else {
        [self.bt setImage:[UIImage imageNamed:@"cv_more"] forState:UIControlStateNormal];
        [self.bt addTarget:self action:@selector(moreCity) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)deleteCity{

    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteCityModel:)]) {
        [self.delegate deleteCityModel:_myModel];
    }
}

- (void)moreCity {
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteCityModel:)]) {
        [self.delegate moreCityModel:_myModel];
    }

}

@end
