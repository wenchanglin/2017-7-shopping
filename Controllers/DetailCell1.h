//
//  DetailCell1.h
//  885logistics
//
//  Created by Blues on 17/2/13.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostModel;
@interface DetailCell1 : UITableViewCell<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, weak) BaseViewController *lifeVC;

@property (weak, nonatomic) IBOutlet UIButton *header;
@property (weak, nonatomic) IBOutlet UILabel *nameLb;
@property (weak, nonatomic) IBOutlet UILabel *typeLb;
@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *contentLb;
@property (weak, nonatomic) IBOutlet UILabel *dateLb;
@property (weak, nonatomic) IBOutlet UICollectionView *imgView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) NSMutableArray *dataArr;

@property (weak, nonatomic) IBOutlet UIButton *reportBt1;
@property (weak, nonatomic) IBOutlet LYButton *moreBt;
@property (weak, nonatomic) IBOutlet UIView *moreView;
@property (weak, nonatomic) IBOutlet UIView *leView;
@property (weak, nonatomic) IBOutlet UIButton *hideBt;
@property (weak, nonatomic) IBOutlet UIButton *replyBt;
@property (weak, nonatomic) IBOutlet UIButton *reportbt2;

@property (nonatomic, strong) PostModel *model;

- (void)paddingDataWith1:(PostModel *)model cellType:(NSInteger)type;

@end
