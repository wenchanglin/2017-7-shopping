//
//  DetailTopView.h
//  885logistics
//
//  Created by Blues on 17/1/12.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailTopView : UIView

@property (weak, nonatomic) IBOutlet UIView *bk1;
@property (weak, nonatomic) IBOutlet UIImageView *header;
@property (weak, nonatomic) IBOutlet UIImageView *sexIv;
@property (weak, nonatomic) IBOutlet UIImageView *isSafe;
@property (weak, nonatomic) IBOutlet UILabel *nameLb;
@property (weak, nonatomic) IBOutlet UILabel *markLb;
@property (weak, nonatomic) IBOutlet UILabel *companyLb;
@property (weak, nonatomic) IBOutlet UIView *bk2;
@property (weak, nonatomic) IBOutlet UILabel *goodLb;
@property (weak, nonatomic) IBOutlet UILabel *finishedLb;
@property (weak, nonatomic) IBOutlet UILabel *phoneLb;
@property (weak, nonatomic) IBOutlet UILabel *carLb;
@property (weak, nonatomic) IBOutlet UILabel *loadLb;
@property (weak, nonatomic) IBOutlet UILabel *areaLb;

@property (weak, nonatomic) IBOutlet UIButton *backBt;


- (void)detailFromServer:(NSDictionary *)dict;


@end
