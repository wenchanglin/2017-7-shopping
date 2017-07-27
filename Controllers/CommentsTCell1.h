//
//  CommentsTCell1.h
//  LogisticsDriver
//
//  Created by Blues on 17/3/20.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StarLevelView,CommentDTO;

@protocol CCellDelegate <NSObject>

- (void)replyUserWithfkOrderId:(NSString *)fkOrderId;

@end

@interface CommentsTCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *header;
@property (weak, nonatomic) IBOutlet UILabel *dateLb;
@property (weak, nonatomic) IBOutlet StarLevelView *starView;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UIButton *replyBt;
@property (weak, nonatomic) IBOutlet UILabel *contentLb;

@property (nonatomic, weak) id<CCellDelegate> delegate;

@property (nonatomic, strong) CommentDTO *myDto;

- (void)updateViewWithComment:(CommentDTO *)dto;


@end
