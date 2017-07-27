//
//  PostTCell2.m
//  885logistics
//
//  Created by Blues on 17/1/10.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "PostTCell2.h"
#import "PostModel.h"

@implementation PostTCell2

- (void)awakeFromNib {
    [super awakeFromNib];
    self.header.layer.masksToBounds = YES;
    self.header.layer.cornerRadius = 21.f;
}

- (void)paddingDataWith2:(PostModel *)model {
    
    if (_model != model) {
        _model = model;
    }
    if (model.userImgUrl.length) {
        NSString *urlStr = [NSString stringWithFormat:ImgLoadUrl,model.userImgUrl];
        [self.header sd_setBackgroundImageWithURL:[NSURL URLWithString:urlStr] forState:UIControlStateNormal];
    }
    self.nameLb.text = model.userName;
    if ([model.userType isEqualToString:@"employ"]) {
        self.typeLb.text = @"【普通用户】";
        self.nameLb.textColor = MainYellowColor;
    }else {
        self.typeLb.text = @"【司机】";
        self.nameLb.textColor = MainColor;
    }
    self.titleLb.text = model.title;
    self.contentLb.text = model.content;
    self.dateLb.text = [LYHelper justDateStringWithInterval:model.createTime];
    [self.replyBt setTitle:[model.fkEvaNum stringValue] forState:UIControlStateNormal];
}


- (IBAction)deleteClicked:(UIButton *)sender {
    [self.lifeVC deletePostWithPostID:_model];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
