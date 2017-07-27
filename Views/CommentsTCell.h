//
//  CommentsTCell.h
//  LogisticsDriver
//
//  Created by Blues on 17/1/23.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StarLevelView,CommentDTO;

@protocol CommentsTCellDelegate <NSObject>

- (void)replyUserWithfkOrderId:(NSString *)fkOrderId;

@end


@interface CommentsTCell : UITableViewCell <UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *header;
@property (weak, nonatomic) IBOutlet UILabel *dateLb;
@property (weak, nonatomic) IBOutlet StarLevelView *starView;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UIButton *replyBt;
@property (weak, nonatomic) IBOutlet UILabel *contentLb;
@property (weak, nonatomic) IBOutlet UICollectionView *imgView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;

@property (nonatomic, weak) id<CommentsTCellDelegate> delegate;

@property (nonatomic, strong) CommentDTO *myDto;

- (void)updateViewWithComment:(CommentDTO *)dto;


@end
