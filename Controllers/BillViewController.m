//
//  BillViewController.m
//  CustomFurniture
//
//  Created by Blues on 16/11/15.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "BillViewController.h"
#import "BillTCell.h"
#import "BillModel.h"


@interface BillViewController ()<UITableViewDelegate,UITableViewDataSource> {

}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, assign) NSInteger page;

@end

@implementation BillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initData {
    
    self.navigationItem.title = @"资金明细";

    self.page = 0;
    
    self.dataArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self postUrlForBillReload:NO];
}


- (void)postUrlForBillReload:(BOOL)reload {

    if (reload) {
        
        [self.dataArr removeAllObjects];
        [self.tableView reloadData];
    }
    
    
    NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID],
                            @"page":@(self.page),
                            @"limit":@"15"
                            };
    
    [[LYAPIManager sharedInstance] POST:@"transportion/accountCash/querydetail" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        // NSLog(@"%@___",result);
        
        if ([result[@"errcode"] integerValue] == 0) {
            
            NSDictionary *data = result[@"data"];
            
            id idiData = data[@"iData"];
            
            if (NotNilAndNull(idiData)) {
                
                NSArray *iData = data[@"iData"];
                for (NSDictionary *logBill in iData) {
                    
                    BillModel *model = [[BillModel alloc] init];
                    [model setValuesForKeysWithDictionary:logBill];
                    model.fkBillID = logBill[@"id"];
                    
                    [self.dataArr addObject:model];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        });
    }];
}



- (void)createViews {

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BillTCell" bundle:nil] forCellReuseIdentifier:@"BillTCell"];
    [self.view addSubview:self.tableView];
    
    
    MJRefreshNormalHeader *mjHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 0;
        [self postUrlForBillReload:YES];
    }];
    self.tableView.mj_header = mjHeader;
    MJRefreshBackNormalFooter *mjFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        
        self.page ++;
        [self postUrlForBillReload:NO];
    }];
    self.tableView.mj_footer = mjFooter;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    BillTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BillTCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    BillModel *model = [self.dataArr objectAtIndex:indexPath.row];
    
    cell.titleLb.text = model.goal;
    cell.dateLb.text = [LYHelper justDateStringWithInterval:model.createTime];
    cell.statusLb.text = [NSString stringWithFormat:@"(%@)",model.status];
    cell.muchLb.text = [NSString stringWithFormat:@"%.2f",[model.money floatValue]];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 55.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    //[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.baidu.com"]];

}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
