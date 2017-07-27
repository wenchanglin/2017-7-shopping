//
//  ReleaseView.h
//  885logistics
//
//  Created by Blues on 17/1/5.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReleaseView : UIView<UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataArr1;
@property (nonatomic, strong) NSArray *dataArr2;

@property (weak, nonatomic) IBOutlet UIView *bk1;
@property (weak, nonatomic) IBOutlet UITableView *tabView;
@property (weak, nonatomic) IBOutlet UIButton *bkBt;


@end
