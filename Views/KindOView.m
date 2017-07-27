//
//  KindOView.m
//  LogisticsDriver
//
//  Created by Blues on 17/1/24.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "KindOView.h"
#import "KindOCell.h"
#import "MineModel.h"

@implementation KindOView


- (void)awakeFromNib {

    [super awakeFromNib];
    self.dataArr = [[LYAPIManager sharedInstance] homeArr];
    
    self.bk.layer.shadowColor = [UIColor blackColor].CGColor;
    self.bk.layer.shadowOffset = CGSizeMake(2, 2.f);
    self.bk.layer.shadowOpacity = 0.8f;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.bounces = NO;
    [self.tableView registerNib:[UINib nibWithNibName:@"KindOCell" bundle:nil] forCellReuseIdentifier:@"KindOCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KindOCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KindOCell" forIndexPath:indexPath];
    MineModel *model = [self.dataArr objectAtIndex:indexPath.row];
    [cell.tBt setTitle:model.titleName forState:UIControlStateNormal];
    if ([model.isNow boolValue]) {
        cell.tBt.selected = YES;
    }else {
        cell.tBt.selected = NO;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (MineModel *lmodel in self.dataArr) {
        lmodel.isNow = @"0";
    }
    MineModel *model = [self.dataArr objectAtIndex:indexPath.row];
    model.isNow = @"1";
    
    [self removeFromSuperview];
    
    if (self.delegte && [self.delegte respondsToSelector:@selector(filterOrderType:text:)]) {
        [self.delegte filterOrderType:model.htype text:model.titleName];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
