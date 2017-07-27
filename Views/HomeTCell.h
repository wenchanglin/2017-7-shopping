//
//  HomeTCell.h
//  LogisticsDriver
//
//  Created by Blues on 17/1/23.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeTCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *bk1;
@property (weak, nonatomic) IBOutlet UILabel *transpostLb;
@property (weak, nonatomic) IBOutlet UILabel *dateLb;
@property (weak, nonatomic) IBOutlet UIView *instanceView;
@property (weak, nonatomic) IBOutlet UIButton *checkInstance;
@property (weak, nonatomic) IBOutlet UILabel *goodsLb;
@property (weak, nonatomic) IBOutlet UILabel *manyLb;
@property (weak, nonatomic) IBOutlet UILabel *carSizeLb;
@property (weak, nonatomic) IBOutlet UILabel *weightLb;
@property (weak, nonatomic) IBOutlet UILabel *startAddress;
@property (weak, nonatomic) IBOutlet UILabel *endAddress;

@end
