//
//  HeadView.m
//  Daup
//
//  Created by Blues on 16/5/20.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "HeadView.h"

@implementation HeadView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headIv.layer.masksToBounds = YES;
    self.headIv.layer.cornerRadius = 36.f;
    [self.activityView startAnimating];
    self.headIv.userInteractionEnabled = NO;
    self.isVia.hidden = YES;
}

- (void)fillMyInformationWith:(NSDictionary *)data {
    
    if (!data) {
        return;
    }
    [self.activityView stopAnimating];
    if (NotNilAndNull(data[@"companyName"])) {
        self.companyNameLb.text = data[@"companyName"];
    }
    if (NotNilAndNull(data[@"audit"])) {
        NSString *via = data[@"audit"];
        if ([via isEqualToString:@"SUCCESS"]) {
            self.isVia.hidden = NO;
        }else {
            self.isVia.hidden = YES;
        }
    }else {
        self.isVia.hidden = YES;
    }
    if (NotNilAndNull(data[@"userInfoBase"])) {
        NSDictionary *userInfoBase = data[@"userInfoBase"];
        self.telLb.text = userInfoBase[@"phone"];
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
            
            NSString *username = userInfoBase[@"userName"];
            [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"UserName"];
            self.nameLb.text = username;
        }
        if (NotNilAndNull(userInfoBase[@"userPhoto"])) {
            NSDictionary *userPhoto = userInfoBase[@"userPhoto"];
            NSString *imgUrlStr = [NSString stringWithFormat:ImgLoadUrl,userPhoto[@"location"]];
            [[NSUserDefaults standardUserDefaults]setObject:imgUrlStr forKey:@"ImageUrl"];
            [self.headIv sd_setBackgroundImageWithURL:[NSURL URLWithString:imgUrlStr] forState:UIControlStateNormal];
        }else {
            [self.headIv setBackgroundImage:[UIImage imageNamed:@"bk38"] forState:UIControlStateNormal];
        }
    }
    [LYHelper refreshUserInfo];
    self.headIv.userInteractionEnabled = YES;
}

@end
