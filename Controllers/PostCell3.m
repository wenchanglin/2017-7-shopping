//
//  PostCell3.m
//  885logistics
//
//  Created by Blues on 17/2/9.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "PostCell3.h"
#import "PostModel.h"
#import "ReplyPostController.h"


@implementation PostCell3

- (void)awakeFromNib {
    [super awakeFromNib];
    self.header.layer.masksToBounds = YES;
    self.header.layer.cornerRadius = 21.f;
    [self.videoView bringSubviewToFront:self.videop];
}

- (void)paddingVideoDataWith:(PostModel *)model {
    
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
            NSString *videoImgUrl = [NSString stringWithFormat:ImgLoadUrl,_model.videoImageUrl];
            [self.videoIv sd_setImageWithURL:[NSURL URLWithString:videoImgUrl]];
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
    self.titleLb.text = _model.title;
    self.contentLb.text = _model.content;
    self.dateLb.text = [LYHelper justDateStringWithInterval:_model.createTime];
    [self.replyBt setTitle:[_model.fkEvaNum stringValue] forState:UIControlStateNormal];
}

// 删除
- (IBAction)deleteClicked:(UIButton *)sender {
    [self.lifeVC deletePostWithPostID:_model];
}

//播放视频
- (IBAction)playVideo:(UIButton *)sender {
    if (!_model) {
        return;
    }
    [self.lifeVC playVideoWithUrlString:_model.videoUrl];
}

// 评论
- (IBAction)commentClicked:(id)sender {
 
    if (!_model) {
        return;
    }
    ReplyPostController *reply = [[ReplyPostController alloc] init];
    [reply addPopItem];
    reply.fkPostId = _model.fkPostID;
    reply.model = _model;
    [self.lifeVC.navigationController pushViewController:reply animated:YES];
}

// 举报
- (IBAction)reportCilcked:(id)sender {
    
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
