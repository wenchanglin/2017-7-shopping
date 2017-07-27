//
//  InsuranceTCell.h
//  885logistics
//
//  Created by Blues on 17/1/16.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SecureDTO;

@protocol InsuranceTCellDelegate <NSObject>

- (void)deleteCellBySecureDTO:(SecureDTO *)dto;

@end

@interface InsuranceTCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *typeLb;
@property (weak, nonatomic) IBOutlet UILabel *rateLb;
@property (weak, nonatomic) IBOutlet UILabel *nameLb;
@property (weak, nonatomic) IBOutlet UITextField *quantity1;
@property (weak, nonatomic) IBOutlet UITextField *quantity2;
@property (weak, nonatomic) IBOutlet UILabel *singleP;
@property (weak, nonatomic) IBOutlet UILabel *allp;
@property (weak, nonatomic) IBOutlet UILabel *insuranceLb;
@property (weak, nonatomic) IBOutlet UIView *deleteBk;
@property (weak, nonatomic) IBOutlet UIButton *deleteBt;

@property (nonatomic, strong) SecureDTO *sDto;

@property (nonatomic, weak) id<InsuranceTCellDelegate> delegate;

- (void)loadDataFromSecureDTO:(SecureDTO *)dto;

@end
