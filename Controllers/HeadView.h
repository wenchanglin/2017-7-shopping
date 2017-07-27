//
//  HeadView.h
//  Daup
//
//  Created by Blues on 16/5/20.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeadView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *nameLb;
@property (weak, nonatomic) IBOutlet UIButton *headIv;
@property (weak, nonatomic) IBOutlet UIImageView *sexIv;
@property (weak, nonatomic) IBOutlet UILabel *companyNameLb;
@property (weak, nonatomic) IBOutlet UILabel *telLb;
@property (weak, nonatomic) IBOutlet UIImageView *isVia;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

- (void)fillMyInformationWith:(NSDictionary *)data;


@end
