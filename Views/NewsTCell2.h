//
//  NewsTCell2.h
//  885logistics
//
//  Created by Blues on 17/1/9.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsModel,NewsViewController;

@interface NewsTCell2 : UITableViewCell

@property (nonatomic, weak) NewsViewController *home;

@property (weak, nonatomic) IBOutlet UIView *bk1;
@property (weak, nonatomic) IBOutlet UIImageView *logoIv;
@property (weak, nonatomic) IBOutlet UILabel *contentLb;
@property (weak, nonatomic) IBOutlet UILabel *dateLb;

@property (weak, nonatomic) IBOutlet UIView *bk2;
@property (weak, nonatomic) IBOutlet UIView *bk3;

@property (weak, nonatomic) IBOutlet UIButton *cancelbt;
@property (weak, nonatomic) IBOutlet UIButton *surebt;

@property (nonatomic, strong) NewsModel *myModel;

- (void)paddingMsgDetail:(NewsModel *)model;




@end
