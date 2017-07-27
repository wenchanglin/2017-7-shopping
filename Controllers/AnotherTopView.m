//
//  AnotherTopView.m
//  885logistics
//
//  Created by Blues on 17/3/31.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "AnotherTopView.h"

@implementation AnotherTopView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.header.layer.masksToBounds = YES;
    self.header.layer.cornerRadius = 25.f;
}

- (void)fillMyInformationWith:(NSDictionary *)data {
    
    if (NotNilAndNull(data[@"companyName"])) {
        self.companyLb.text = data[@"companyName"];
    }
    if (NotNilAndNull(data[@"idNumber"])) {
        self.idLb.text = data[@"idNumber"];
    }
    if (NotNilAndNull(data[@"sex"])) {
        NSString *text = data[@"sex"];
        if ([text isEqualToString:@"男"]) {
            self.sexIv.image = [UIImage imageNamed:@"man"];
        }else if ([text isEqualToString:@"女"]){
            self.sexIv.image = [UIImage imageNamed:@"lady"];
        }
    }
    if (NotNilAndNull(data[@"userInfoBase"])) {
        NSDictionary *userInfoBase = data[@"userInfoBase"];
        if (NotNilAndNull(userInfoBase[@"userName"])) {
            self.nameLb.text = userInfoBase[@"userName"];
        }
        if (NotNilAndNull(userInfoBase[@"userPhoto"])) {
            NSDictionary *userPhoto = userInfoBase[@"userPhoto"];
            NSString *imgUrlStr = [NSString stringWithFormat:ImgLoadUrl,userPhoto[@"location"]];
            [self.header sd_setImageWithURL:[NSURL URLWithString:imgUrlStr]];
        }
        
        if (NotNilAndNull(userInfoBase[@"phone"])) {
            self.phoneLb.text = userInfoBase[@"phone"];
        }
    }
    if (NotNilAndNull(data[@"email"])) {
        self.emailLb.text = data[@"email"];
    }
}


@end
