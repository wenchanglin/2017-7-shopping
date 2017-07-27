//
//  BillTCell.h
//  CustomFurniture
//
//  Created by Blues on 16/11/15.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BillTCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLb;

@property (weak, nonatomic) IBOutlet UILabel *dateLb;

@property (weak, nonatomic) IBOutlet UILabel *muchLb;
@property (weak, nonatomic) IBOutlet UILabel *statusLb;

@end
