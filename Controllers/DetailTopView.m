//
//  DetailTopView.m
//  885logistics
//
//  Created by Blues on 17/1/12.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "DetailTopView.h"

@implementation DetailTopView

- (void)awakeFromNib {

    [super awakeFromNib];
    self.header.layer.masksToBounds = YES;
    self.header.layer.cornerRadius = 25.f;
}

- (void)detailFromServer:(NSDictionary *)dict {

    if (NotNilAndNull(dict[@"companyName"])) {
        self.companyLb.text = dict[@"companyName"];
    }
    if (NotNilAndNull(dict[@"sex"])) {
        NSString *sex = dict[@"sex"];
        if ([sex isEqualToString:@"男"]) {
            self.sexIv.image = [UIImage imageNamed:@"man"];
        }else if ([sex isEqualToString:@"女"]){
            self.sexIv.image = [UIImage imageNamed:@"lady"];
        }
    }
    if (NotNilAndNull(dict[@"userInfoBase"])) {
        NSDictionary *userInfoBase = dict[@"userInfoBase"];
        if (NotNilAndNull(userInfoBase[@"userName"])) {
            self.nameLb.text = userInfoBase[@"userName"];
        }
        if (NotNilAndNull(userInfoBase[@"phone"])) {
            self.phoneLb.text = userInfoBase[@"phone"];
        }
        if (NotNilAndNull(userInfoBase[@"userPhoto"])) {
            NSDictionary *driverPhoto = userInfoBase[@"userPhoto"];
            NSString *urlStr = [NSString stringWithFormat:ImgLoadUrl,driverPhoto[@"location"]];
            [self.header sd_setImageWithURL:[NSURL URLWithString:urlStr]];
        }
    }
    
    NSNumber *good = dict[@"quality"];
    self.goodLb.text = [NSString stringWithFormat:@"%.1f",[good floatValue]];
    NSNumber *coNum = dict[@"coNum"];
    self.finishedLb.text = [coNum stringValue];
    if (NotNilAndNull(dict[@"address"])) {
        self.areaLb.text = dict[@"address"];
    }
    if (NotNilAndNull(dict[@"truckModel"])) {
        NSDictionary *truck = dict[@"truckModel"];
        self.carLb.text = truck[@"carModel"];
        self.loadLb.text = [NSString stringWithFormat:@"%@kg",truck[@"modelWeight"]];
    }
    if (NotNilAndNull(dict[@"idNumber"])) {
        self.markLb.text = dict[@"idNumber"];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
