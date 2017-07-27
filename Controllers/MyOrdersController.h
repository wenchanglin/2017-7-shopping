//
//  MyOrdersController.h
//  885logistics
//
//  Created by Blues on 17/1/3.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseViewController.h"

@interface MyOrdersController : BaseViewController

@property (nonatomic, strong) NSString *state;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArr;


@end
