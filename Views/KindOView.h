//
//  KindOView.h
//  LogisticsDriver
//
//  Created by Blues on 17/1/24.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol KindOViewDelegate <NSObject>

- (void)filterOrderType:(NSString *)type text:(NSString *)text;

@end

@interface KindOView : UIView <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *bk;
@property (weak, nonatomic) IBOutlet UIButton *disBt;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, weak) id<KindOViewDelegate> delegte;

@end
