//
//  MyOrdersController.m
//  885logistics
//
//  Created by Blues on 17/1/3.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "MyOrdersController.h"
#import "OrderDetailController.h"
#import "MOTCell.h"
#import "OrderModel.h"

@interface MyOrdersController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView *stateView;
@property (nonatomic, assign) NSInteger reloadState;
@property (nonatomic, strong) UILabel *msglabel;
@property (nonatomic, assign) NSInteger page;

@end

@implementation MyOrdersController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryDataFromServerReload:YES];
}

- (void)initData {
    
    self.view.frame = CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f);
    self.state = @"待处理";
    self.dataArr = [[NSMutableArray alloc] init];
}


- (void)queryDataFromServerReload:(BOOL)reload {
    
    if (reload) {
         self.page = 0;
        [self.dataArr removeAllObjects];
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
     NSDictionary *param = @{@"fkDriverId":[LYHelper getCurrentUserID],
                            @"status":_state,
                            @"page":@(_page),
                            @"limit":@"10"
                            };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[LYAPIManager sharedInstance] POST:@"transportion/transOrderInfo/queryTorder" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([result[@"errcode"] integerValue] == 0) {
            
            if (NotNilAndNull(result[@"data"])) {
                
                NSDictionary *data = result[@"data"];
                
                if (NotNilAndNull(data[@"iData"])) {
        
                     NSArray *iData = data[@"iData"];
                    
                    for (NSDictionary *Odict in iData) {
                        
                        OrderModel *model = [[OrderModel alloc] init];
                        
                        if (NotNilAndNull(Odict[@"userAddress"])) {
                            
                            NSDictionary *userAddress = Odict[@"userAddress"];
                            
                            if (NotNilAndNull(userAddress[@"shipper"])) {
                                
                                NSDictionary *fUser = userAddress[@"shipper"];
                                model.fUserName = fUser[@"userName"];
                                model.fTel = fUser[@"tel"];
                                model.fAreas = fUser[@"areas"];
                                model.fDetail = fUser[@"detail"];
                                model.fAddress = [model.fAreas stringByAppendingString:model.fDetail];
                            }
                            
                            if (NotNilAndNull(userAddress[@"addressee"])) {
                                NSDictionary *sUser = userAddress[@"addressee"];
                                model.sUserName = sUser[@"userName"];
                                model.sTel = sUser[@"tel"];
                                model.sAreas = sUser[@"areas"];
                                model.sDetail = sUser[@"detail"];
                                model.sAddress = [model.sAreas stringByAppendingString:model.sDetail];
                            }
                        }
                        if (NotNilAndNull(Odict[@"transClass"])) {
                            NSDictionary *truck = Odict[@"transClass"];
                            model.modelType = truck[@"transClass"];
                        }
                        if (NotNilAndNull(Odict[@"truckModel"])) {
                            NSDictionary *truckModel = Odict[@"truckModel"];
                            [model setValuesForKeysWithDictionary:truckModel];
                        }
                         model.fkOrderId = Odict[@"id"];
                        [model setValuesForKeysWithDictionary:Odict];
                        
                        [self.dataArr addObject:model];
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        });
    }];
}


- (void)createViews {
    
    self.navigationItem.title = @"我的订单";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.stateView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40.f, kScreenSize.width, kScreenSize.height - 104.f - 50.f) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MOTCell" bundle:nil] forCellReuseIdentifier:@"MOTCell"];
    [self.view addSubview:self.tableView];
    
    MJRefreshNormalHeader *mjHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 0;
        [self queryDataFromServerReload:YES];
    }];
    self.tableView.mj_header = mjHeader;
    MJRefreshBackNormalFooter *mjFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        self.page ++;
        [self queryDataFromServerReload:NO];
    }];
    self.tableView.mj_footer = mjFooter;
}


- (UIView *)stateView {
    
    NSArray *titles = @[@"待接单",@"待运输",@"运输中",@"已完成"];
    CGFloat width = kScreenSize.width/titles.count;
    CGFloat height = 40.f;
    
    NSInteger state = 0;
    state = 0;
    
    if (!_stateView) {
        
        _stateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.f, kScreenSize.width, height)];
        _stateView.userInteractionEnabled = YES;
        _stateView.backgroundColor = [UIColor whiteColor];
        
        for (NSInteger i = 0; i < titles.count; i ++) {
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(width * i, 0, width, height)];
            view.backgroundColor = [UIColor whiteColor];
            
            UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(3, height-1, width - 6.f, 1)];
            iv.image = [UIImage imageNamed:@"bhline6"];
            iv.tag = 260 + i;
            iv.hidden = YES;
            [view addSubview:iv];
            
            
            [_stateView addSubview:view];
            
            UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height-1)];
            bt.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
            [bt setTitle:titles[i] forState:UIControlStateNormal];
            [bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [bt setTitleColor:MainColor forState:UIControlStateSelected];
            bt.userInteractionEnabled = YES;
            bt.selected = NO;
            bt.enabled = YES;
            bt.tag = 160 + i;
            [bt addTarget:self action:@selector(toReloadOrders:) forControlEvents:UIControlEventTouchUpInside];
            if (i == state) {
                bt.selected = YES;
                iv.hidden = NO;
                self.reloadState = 160 + i;
            }
            [view addSubview:bt];
        }
    }
    
    return _stateView;
}

- (void)toReloadOrders:(UIButton *)sender {

    NSInteger btag = sender.tag;
    sender.selected = YES;

    if (self.reloadState != btag) {
        
         self.page = 0;
        UIButton *last = (UIButton *)[self.stateView viewWithTag:self.reloadState];
        UIImageView *lastIV = (UIImageView *)[self.stateView viewWithTag:(self.reloadState + 100)];
        last.selected = NO;
        lastIV.hidden = YES;
        
        UIImageView *currentIV = (UIImageView *)[self.stateView viewWithTag:btag+100];
        currentIV.hidden = NO;
        
        if (btag == 160) {
            self.state = @"待处理";
        }else if (btag == 161){
            self.state = @"待运输";
        }else if (btag == 162){
            self.state = @"运输中";
        }else if (btag == 163){
            self.state = @"已完成";
        }
        [self queryDataFromServerReload:YES];
    }
    self.reloadState = sender.tag;
}


#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MOTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MOTCell" forIndexPath:indexPath];
    OrderModel *model = [self.dataArr objectAtIndex:indexPath.row];
    cell.home = self;
    [cell updateViewWithOModel:model];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OrderModel *model = [self.dataArr objectAtIndex:indexPath.row];
    OrderDetailController *detail = [[OrderDetailController alloc] init];
    [detail addPopItem];
    detail.model = model;
    detail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detail animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 180.f;
}

- (UILabel *)msglabel {
    
    if (!_msglabel) {
        
        _msglabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 30.f)];
        _msglabel.text = @"您没有相关的订单～";
        _msglabel.textColor = [UIColor lightGrayColor];
        _msglabel.font = [UIFont systemFontOfSize:16.f];
        _msglabel.center = self.view.center;
        _msglabel.textAlignment = NSTextAlignmentCenter;
    }
    return _msglabel;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
