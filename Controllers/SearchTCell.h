//
//  SearchTCell.h
//  885logistics
//
//  Created by Blues on 17/1/20.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserModel;

@interface SearchTCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iv;
@property (weak, nonatomic) IBOutlet UILabel *nameLb;
@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (nonatomic, strong) UserModel *myModel;

- (void)updateViewsWith:(UserModel *)model;



@end
