//
//  PostTCell1.h
//  885logistics
//
//  Created by Blues on 17/1/10.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostModel;

@interface PostTCell1 : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, weak) BaseViewController *lifeVC;
@property (weak, nonatomic) IBOutlet UIButton *header;
@property (weak, nonatomic) IBOutlet UILabel *nameLb;
@property (weak, nonatomic) IBOutlet UILabel *typeLb;
@property (weak, nonatomic) IBOutlet LYButton *deleteBt;
@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *contentLb;
@property (weak, nonatomic) IBOutlet UIView *bBk;
@property (weak, nonatomic) IBOutlet UILabel *dateLb;
@property (weak, nonatomic) IBOutlet UIButton *replyBt;
@property (weak, nonatomic) IBOutlet UICollectionView *imgView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, strong) PostModel *model;


- (void)paddingDataWith:(PostModel *)model;

@end
