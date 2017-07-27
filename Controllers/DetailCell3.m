//
//  DetailCell3.m
//  885logistics
//
//  Created by Blues on 17/2/13.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "DetailCell3.h"
#import "PostModel.h"

@implementation DetailCell3

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.header.layer.masksToBounds = YES;
    self.header.layer.cornerRadius = 21.f;
}

- (void)paddingDataWith3:(PostModel *)model {

    if (_model != model) {
        _model = model;
    }
    if (NotNilAndNull(_model.userImgUrl)) {
        if (_model.userImgUrl.length) {
            NSString *urlStr = [NSString stringWithFormat:ImgLoadUrl,_model.userImgUrl];
            [self.header sd_setBackgroundImageWithURL:[NSURL URLWithString:urlStr] forState:UIControlStateNormal];
        }
    }
    if (NotNilAndNull(_model.videoImageUrl)) {
        if (_model.videoImageUrl.length) {
            NSString *videoImg = [NSString stringWithFormat:ImgLoadUrl,_model.videoImageUrl];
            [self.videoIv sd_setImageWithURL:[NSURL URLWithString:videoImg]];
        }
    }
    self.nameLb.text = _model.userName;
    if ([model.userType isEqualToString:@"employ"]) {
        self.typeLb.text = @"【普通用户】";
        self.nameLb.textColor = MainYellowColor;
    }else {
        self.typeLb.text = @"【司机】";
        self.nameLb.textColor = MainColor;
    }
    self.titleLb.text = _model.title;
    self.contentLb.text = _model.content;
    self.dateLb.text = [LYHelper justDateStringWithInterval:_model.createTime];
}
- (IBAction)paly:(id)sender {
    if (!_model) {
        return;
    }
    [self.lifeVC playVideoWithUrlString:_model.videoUrl];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
