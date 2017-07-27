//
//  ReplyCell.h
//  LogisticsDriver
//
//  Created by Blues on 17/3/20.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommentDTO;

@interface ReplyCell : UITableViewCell <UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *stcLb;
@property (weak, nonatomic) IBOutlet UILabel *contentLb;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (weak, nonatomic) IBOutlet UICollectionView *imgView;

@property (nonatomic, strong) CommentDTO *myDto;

- (void)updateViewWithComment:(CommentDTO *)dto;

@end
