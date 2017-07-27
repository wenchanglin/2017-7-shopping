//
//  BankTCell.h
//  885logistics
//
//  Created by Blues on 17/1/19.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCardsModel;

@protocol BankTCellDelegate <NSObject>

- (void)deleteBankCardBy:(BCardsModel *)model;

@end

@interface BankTCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *bankIv;
@property (weak, nonatomic) IBOutlet UILabel *bankName;
@property (weak, nonatomic) IBOutlet UILabel *carType;
@property (weak, nonatomic) IBOutlet UILabel *numberLb;
@property (weak, nonatomic) IBOutlet UIButton *deleteBt;

@property (nonatomic, weak) id<BankTCellDelegate> delegate;

@property (nonatomic, strong) BCardsModel *myModel;

- (void)updateViewWith:(BCardsModel *)model;

@end
