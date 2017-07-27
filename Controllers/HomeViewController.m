//
//  HomeViewController.m
//  LogisticsDriver
//
//  Created by Blues on 17/1/22.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeDetailController.h"
#import "NewsViewController.h"
#import "CLLocation+Sino.h"
#import "KindOView.h"
#import "OrderModel.h"
#import "HomeOCell.h"
#import "HVSrcView.h"
#import "LctItem.h"
#import "SupplementView.h"
#import "CompleteVController.h"


@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource,KindOViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UIView *tlView;
@property (nonatomic, strong) UIButton *tlBt;
@property (nonatomic, weak)   KindOView *kindView;
@property (nonatomic, weak)   HVSrcView *header;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) BOOL isSpecialLine;
@property (nonatomic, strong) LctItem *lctItem;
@property (nonatomic, strong) UIButton *workButton;
@property (nonatomic, weak) SupplementView *supView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryMyStatus];
}

- (void)initData {
    
    self.page           = 0;
    self.type           = @"";
    self.dataArr        = [[NSMutableArray alloc] init];
    self.isSpecialLine  = NO;
    [self checkNowWorkStatus];
    [JPUSHService setTags:nil alias:[LYHelper getCurrentUserID] fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
        NSLog(@"_JPushIsSuccess_____%d",iResCode);
    }];
}

- (void)createViews {
    
    [self createNavItems];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f - 49.f) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeOCell" bundle:nil] forCellReuseIdentifier:@"HomeOCell"];
    
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
    
    [self.view addSubview:self.workButton];
    
    [self queryDataFromServerReload:NO];
}

- (LctItem *)lctItem {
    if (!_lctItem) {
        _lctItem = [[LctItem alloc] initWithFrame:CGRectMake(0, 0, 80.f, 40.f)];
    }
    return _lctItem;
}

- (HVSrcView *)header {
    
    if (!_header) {
        _header = [[NSBundle mainBundle]loadNibNamed:@"HVSrcView" owner:nil options:nil].lastObject;
        _header.frame = CGRectMake(0, 0, kScreenSize.width, 46.f);
        [_header.srcBt addTarget:self action:@selector(serchSepicalLine) forControlEvents:UIControlEventTouchUpInside];
        _header.srcTf.delegate = self;
    }
    return _header;
}

- (void)serchSepicalLine {


}


- (SupplementView *)supView {

    if (!_supView) {
        _supView = [[NSBundle mainBundle] loadNibNamed:@"SupplementView" owner:nil options:nil].lastObject;
        _supView.frame = CGRectMake(0, 0, kScreenSize.width, 180.f);
        CGPoint point = self.view.center;
        _supView.center = CGPointMake(point.x, point.y - 64.f);
        [_supView.okBt addTarget:self action:@selector(completeMyInfo) forControlEvents:UIControlEventTouchUpInside];
    }
    return _supView;
}

- (void)completeMyInfo {

    CompleteVController *complete = [[CompleteVController alloc] init];
    [complete addPopItem];
    complete.fkId = [LYHelper getCurrentUserID];
    complete.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:complete animated:YES];
}


- (UIView *)tlView {

    if (!_tlView) {
        
        _tlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 135.f, 35.f)];
        _tlView.backgroundColor = [UIColor clearColor];
        _tlBt = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 0, 135.f,35.f)];
        [_tlBt addTarget:self action:@selector(changeOrderType:) forControlEvents:UIControlEventTouchUpInside];
        [_tlBt setTitle:@"全部订单" forState:UIControlStateNormal];
        [_tlBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _tlBt.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        [_tlBt setImage:[UIImage imageNamed:@"go_bottom_white"] forState:UIControlStateNormal];
        [_tlBt setImage:[UIImage imageNamed:@"go_top_white"] forState:UIControlStateSelected];
        [_tlBt setImageEdgeInsets:UIEdgeInsetsMake(0, 82.f, 0, 0)];
        [_tlBt setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30.f)];
        [_tlView addSubview:_tlBt];
    }
    return _tlView;
}

- (void)changeOrderType:(UIButton *)sender {
    sender.selected = YES;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.kindView];
}

- (void)createNavItems {
    
    self.navigationItem.titleView = self.tlView;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIImage *img = [[UIImage imageNamed:@"news1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStyleDone target:self action:@selector(toggleNewsController)];
    self.navigationItem.rightBarButtonItems = @[item];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:self.lctItem];
    self.navigationItem.leftBarButtonItems = @[left];
}

- (void)toggleNewsController {
    
    NewsViewController *news = [[NewsViewController alloc] init];
    [news addPopItem];
    news.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:news animated:YES];
}

#pragma mark - KindOView
- (KindOView *)kindView {
    
    if (!_kindView) {
        
        _kindView = [[NSBundle mainBundle] loadNibNamed:@"KindOView" owner:nil options:nil].lastObject;
        _kindView.frame = CGRectMake(0, 0, kScreenSize.width, kScreenSize.height);
        [_kindView.disBt addTarget:self action:@selector(hideKindView) forControlEvents:UIControlEventTouchUpInside];
        _kindView.delegte = self;
    }
    return _kindView;
}

- (void)filterOrderType:(NSString *)type text:(NSString *)text{
    
    if (![type isEqualToString:_type]) {
        
        if ([type isEqualToString:@"1"]) {
            _tableView.tableHeaderView = self.header;
        }else {
            _tableView.tableHeaderView = nil;
        }
        _type = type;
        [_tlBt setTitle:text forState:UIControlStateNormal];
        [self queryDataFromServerReload:YES];
    }
}

- (void)hideKindView {
    [self.kindView removeFromSuperview];
     self.tlBt.selected = NO;
}


- (void)queryMyStatus {

    NSDictionary *param = @{@"fkDriverId":[LYHelper getCurrentUserID],
                            @"c":[LYHelper getCurrentCityName],
                            @"type":@"1",
                            @"page":@"0",
                            @"limit":@"5",
                            };
    [[LYAPIManager sharedInstance] POST:@"transportion/transOrderInfo/queryTransOrderByPC" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSInteger errocde = [result[@"errcode"] integerValue];
        if (errocde == 100)
        {
            // 待审核
            dispatch_async(dispatch_get_main_queue(), ^{
                self.supView.msgLb.text = @"您的资料待审核中，系统将于2个工作日内反馈审核结果。";
                self.supView.okBt.hidden = YES;
                [self.view addSubview:self.supView];
            });
        }
        else if (errocde == 500)
        {
            // 待完善
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view addSubview:self.supView];
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

    }];
}

- (void)queryDataFromServerReload:(BOOL)reload {
    
    if (reload) {
        [self.dataArr removeAllObjects];
        [self.tableView reloadData];
    }
    
    NSDictionary *param = @{@"fkDriverId":[LYHelper getCurrentUserID],
                            @"c":[LYHelper getCurrentCityName],
                            @"type":self.type,
                            @"page":@(self.page),
                            @"limit":@"10",
                            };
    NSLog(@"————首页订单————%@",param);
    
    [[LYAPIManager sharedInstance] POST:@"transportion/transOrderInfo/queryTransOrderByPC" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSInteger errocde = [result[@"errcode"] integerValue];
        
        if (errocde == 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.supView removeFromSuperview];
            });
        
            if (NotNilAndNull(result[@"data"])) {
                
                NSDictionary *data = result[@"data"];
                
                if (NotNilAndNull(data[@"iData"])) {
                    
                    NSArray *iData = data[@"iData"];
                    
                    for (NSDictionary *Odict in iData) {
                        
                        // NSLog(@"_____%@",Odict[@"wayLong"]);

                        OrderModel *model = [[OrderModel alloc] init];
                        
                        if (NotNilAndNull(Odict[@"userInfoEmploy"])) {
                            NSDictionary *employ = Odict[@"userInfoEmploy"];
                            model.employCompany = @"";
                            model.employName = @"";
                            model.employSex = @"";
                            if (NotNilAndNull(employ[@"companyName"])) {
                                model.employCompany = employ[@"companyName"];
                            }
                            if (NotNilAndNull(employ[@"sex"])) {
                                model.employSex = employ[@"sex"];
                            }
                            if (NotNilAndNull(employ[@"userInfoBase"])) {
                                NSDictionary *userIfBS = employ[@"userInfoBase"];
                                model.employName = userIfBS[@"userName"];
                                model.employTel = userIfBS[@"phone"];
                                if (NotNilAndNull(userIfBS[@"userPhoto"])) {
                                    NSDictionary *photo = userIfBS[@"userPhoto"];
                                    model.employImg = photo[@"location"];
                                }
                                if (NotNilAndNull(userIfBS[@"phone"])) {
                                    model.employTel = userIfBS[@"phone"];
                                }
                            }
                        }
                        
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
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        });
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    HomeOCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeOCell"];
    OrderModel *model = [self.dataArr objectAtIndex:indexPath.row];
    [cell updateViewWithOModel:model];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 137.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    
    HomeDetailController *detail = [[HomeDetailController alloc] init];
    detail.hidesBottomBarWhenPushed = YES;
    [detail addPopItem];
    detail.model = [self.dataArr objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - WrokStatus

- (void)checkNowWorkStatus {
    
    NSDictionary *param = @{@"fkDriverId":[LYHelper getCurrentUserID]};

    [[LYAPIManager sharedInstance] POST:@"transportion/driver/queryWorkStatus" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([result[@"data"] integerValue] == 1) {
                    self.workButton.selected = YES;
                }
            });
        }
    } failure:nil];
}

- (UIButton *)workButton {

    if (!_workButton) {
        
        _workButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenSize.width/2.f - 36.f, kScreenSize.height - 75.f - 64.f - 49.f, 72.f, 72.f)];
        [_workButton setBackgroundImage:[UIImage imageNamed:@"hv_status_on"] forState:UIControlStateSelected];
        [_workButton setBackgroundImage:[UIImage imageNamed:@"hv_status_close"] forState:UIControlStateNormal];
        [_workButton addTarget:self action:@selector(closeOrOnWork:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _workButton;
}

- (void)closeOrOnWork:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    NSString *status = nil;
    if (sender.isSelected) {
         status = @"1";
        [[NSUserDefaults standardUserDefaults] setObject:@"ON" forKey:@"Status"];
    }else {
         status = @"0";
        [[NSUserDefaults standardUserDefaults] setObject:@"CLOSE" forKey:@"Status"];
    }
    
    NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID],
                            @"workStatus":status
                            };
    [[LYAPIManager sharedInstance] POST:@"/transportion/driver/updateWorkStatus" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        [LYAPIManager showMessageForUser:result[@"msg"]];
        
    } failure:nil];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
