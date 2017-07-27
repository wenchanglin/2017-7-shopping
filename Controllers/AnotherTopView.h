//
//  AnotherTopView.h
//  885logistics
//
//  Created by Blues on 17/3/31.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnotherTopView : UIView

@property (weak, nonatomic) IBOutlet UIView *bk1;
@property (weak, nonatomic) IBOutlet UIImageView *header;
@property (weak, nonatomic) IBOutlet UIImageView *sexIv;
@property (weak, nonatomic) IBOutlet UILabel *nameLb;
@property (weak, nonatomic) IBOutlet UILabel *phoneLb;
@property (weak, nonatomic) IBOutlet UILabel *emailLb;
@property (weak, nonatomic) IBOutlet UIButton *backBt;

@property (weak, nonatomic) IBOutlet UILabel *companyLb;
@property (weak, nonatomic) IBOutlet UILabel *idLb;

- (void)fillMyInformationWith:(NSDictionary *)data;



@end
