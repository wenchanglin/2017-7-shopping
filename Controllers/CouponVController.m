//
//  CouponVController.m
//  885logistics
//
//  Created by Blues on 17/1/9.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "CouponVController.h"
#import "CouponTCell.h"
#import "CouponModel.h"


@interface CouponVController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, assign) NSInteger page;

@end

@implementation CouponVController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)initData {
    
    self.page       = 0;
    self.dataArr    = [NSMutableArray new];
    [self queryDataFromServerReload:NO];
}

- (void)createViews {
    
    self.navigationItem.title = @"抵金券";
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CouponTCell" bundle:nil] forCellReuseIdentifier:@"CouponTCell"];
    
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

- (void)queryDataFromServerReload:(BOOL)reload {

    if (reload) {
        [self.dataArr removeAllObjects];
        [self.tableView reloadData];
    }
    
    NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID],
                            @"page":@(self.page),
                            @"limit":@"8"
                            };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[LYAPIManager sharedInstance] POST:@"transportion/userSVoucher/querySVoucherAll" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([result[@"errcode"] integerValue] == 0) {
            
            NSDictionary *data = result[@"data"];
            if (NotNilAndNull(data[@"iData"])) {
                NSArray *iData = data[@"iData"];
                
                for (NSDictionary *coupon in iData) {
                    
                    CouponModel *model = [[CouponModel alloc] init];
                    model.fkCouponId = coupon[@"id"];
                    [model setValuesForKeysWithDictionary:coupon];
                    
                    if (NotNilAndNull(coupon[@"voucher"])) {
                        
                        NSDictionary *voucher = coupon[@"voucher"];
                        [model setValuesForKeysWithDictionary:voucher];
                    }
                    [self.dataArr addObject:model];
                }
            }
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                // Do something...
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.tableView reloadData];
                    [self.tableView.mj_header endRefreshing];
                    [self.tableView.mj_footer endRefreshing];
                });
            });
        }else {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                // Do something...
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.tableView.mj_header endRefreshing];
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                });
            });
        
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            // Do something...
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
            });
        });
    }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CouponTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CouponTCell" forIndexPath:indexPath];
    CouponModel *model = [self.dataArr objectAtIndex:indexPath.row];
    
    cell.couponName.text = model.voucherName;
    cell.muchLb.text = [model.amounts stringValue];
    cell.limitDate.text = [NSString stringWithFormat:@"有效期至%@",model.term];
    cell.otherLb.text = [NSString stringWithFormat:@"%.2f",[model.useRequire floatValue]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kScreenSize.width/3.3f;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
