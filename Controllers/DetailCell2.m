//
//  DetailCell2.m
//  885logistics
//
//  Created by Blues on 17/2/13.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "DetailCell2.h"
#import "PostModel.h"

@implementation DetailCell2


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.moreView bringSubviewToFront:self.leView];
    self.header.layer.masksToBounds = YES;
    self.header.layer.cornerRadius = 21.f;
}

- (void)paddingDataWith2:(PostModel *)model cellType:(NSInteger)type{
    if (_model != model) {
        _model = model;
    }
    if (NotNilAndNull(_model.userImgUrl)) {
        if (_model.userImgUrl.length) {
            NSString *urlStr = [NSString stringWithFormat:ImgLoadUrl,_model.userImgUrl];
            [self.header sd_setBackgroundImageWithURL:[NSURL URLWithString:urlStr] forState:UIControlStateNormal];
        }
    }
    self.nameLb.text = _model.userName;
    if ([_model.userType isEqualToString:@"employ"]) {
        self.typeLb.text = @"【普通用户】";
        self.nameLb.textColor = MainYellowColor;
    }else {
        self.typeLb.text = @"【司机】";
        self.nameLb.textColor = MainColor;
    }
    if (type == 2) {
        self.titleLb.text = _model.content;
        self.contentLb.text = @"";
    }else if (type == 1){
        self.titleLb.text = _model.title;
        self.contentLb.text = _model.content;
    }
    self.dateLb.text = [LYHelper justDateStringWithInterval:_model.createTime];
}

// 举报 1
- (IBAction)report1Clicked:(id)sender {
    [self.lifeVC reportPostWithPostID:_model];
}

// 下拉视图
- (IBAction)moreClicked:(id)sender {
    self.moreView.hidden = NO;
}
// 收起下拉
- (IBAction)hideClicked:(id)sender {
    self.moreView.hidden = YES;
}
// 回复
- (IBAction)replyClicked:(id)sender {
    [self.lifeVC replyPostWithPostID:_model];
    self.moreView.hidden = YES;
}
// 举报 2
- (IBAction)report2Ciicked:(id)sender {
    [self.lifeVC reportPostWithPostID:_model];
    self.moreView.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
