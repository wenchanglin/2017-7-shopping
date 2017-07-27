//
//  CarTypeCell.h
//  LogisticsDriver
//
//  Created by Blues on 17/3/6.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarTypeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bkView;
@property (weak, nonatomic) IBOutlet UIView *sbkView;
@property (weak, nonatomic) IBOutlet UIImageView *bkIv;
@property (weak, nonatomic) IBOutlet UILabel *nameLb;
@property (weak, nonatomic) IBOutlet UILabel *sizeLb;
@property (weak, nonatomic) IBOutlet UILabel *weightLb;
@property (weak, nonatomic) IBOutlet UIImageView *markIv;

@end
