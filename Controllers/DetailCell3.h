//
//  DetailCell3.h
//  885logistics
//
//  Created by Blues on 17/2/13.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostModel;

@interface DetailCell3 : UITableViewCell

@property (nonatomic, weak) BaseViewController *lifeVC;

@property (weak, nonatomic) IBOutlet UIButton *header;
@property (weak, nonatomic) IBOutlet UILabel *nameLb;
@property (weak, nonatomic) IBOutlet UILabel *typeLb;
@property (weak, nonatomic) IBOutlet UILabel *titleLb;
@property (weak, nonatomic) IBOutlet UILabel *contentLb;
@property (weak, nonatomic) IBOutlet UILabel *dateLb;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UIButton *playBt;
@property (weak, nonatomic) IBOutlet UIImageView *videoIv;
@property (weak, nonatomic) IBOutlet UIImageView *palyIv;

@property (nonatomic, strong) PostModel *model;

- (void)paddingDataWith3:(PostModel *)model;

@end
