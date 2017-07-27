//
//  CommentsTCell1.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/20.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "CommentsTCell1.h"
#import "CommentDTO.h"
#import "StarLevelView.h"

@implementation CommentsTCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    self.header.layer.masksToBounds = YES;
    self.header.layer.cornerRadius = 21.f;
    self.replyBt.layer.masksToBounds = YES;
    self.replyBt.layer.cornerRadius = 2.f;
}

- (void)updateViewWithComment:(CommentDTO *)dto {

    if (_myDto != dto) {
        _myDto = dto;
    }
    if (NotNilAndNull(_myDto.userImg)) {
        NSString *url = [NSString stringWithFormat:ImgLoadUrl,_myDto.userImg];
        [self.header sd_setBackgroundImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal];
    }
    self.nickName.text = _myDto.userName;
    [self.starView setStarLevel:[_myDto.quality doubleValue]];
    self.dateLb.text = [LYHelper justDateStringWithInterval:_myDto.createTime dateFM:nil];
    self.contentLb.text = _myDto.content;
    if (_myDto.isCan) {
        self.replyBt.hidden = NO;
    }else {
        self.replyBt.hidden = YES;
    }
}

- (IBAction)replyUser:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(replyUserWithfkOrderId:)]) {
        [self.delegate replyUserWithfkOrderId:_myDto.fkTransId];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
