//
//  AllLinesController.m
//  LogisticsDriver
//
//  Created by Blues on 17/1/23.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "AllLinesController.h"
#import "ALineTCell.h"
#import "LineModel.h"

@interface AllLinesController ()<UITableViewDataSource,UITableViewDelegate,ALineTCellDelegate>{
    
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, assign) NSInteger page;

@end

@implementation AllLinesController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initData {
   
    self.page = 0;
    self.dataArr = [[NSMutableArray alloc] init];
    [self queryDataFromServerReload:NO];
}

- (void)createViews {
    
    self.navigationItem.title = @"添加专线";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ALineTCell" bundle:nil] forCellReuseIdentifier:@"ALineTCell"];
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

    NSDictionary *param = @{@"page":@(self.page),
                            @"limit":@"8"
                            };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[LYAPIManager sharedInstance] POST:@"transportion/transLine/queryTransLineF" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            if (NotNilAndNull(result[@"data"])) {
                NSDictionary *data = result[@"data"];
                if (NotNilAndNull(data[@"iData"])) {
                    NSArray *iData = data[@"iData"];
                    for (NSDictionary *dict in iData) {
                        
                        LineModel *model = [[LineModel alloc] init];
                        model.fkLineId = dict[@"id"];
                        [model setValuesForKeysWithDictionary:dict];
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
            [self.tableView.mj_footer endRefreshing];
        });
    }];
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ALineTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ALineTCell" forIndexPath:indexPath];
    LineModel *model = [self.dataArr objectAtIndex:indexPath.row];
    [cell updateViewWithLine:model];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)moreLineWithLineID:(LineModel *)line {
    
    if (!line) {
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定添加该专线?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSDictionary *param = @{@"fkDriverId":[LYHelper getCurrentUserID],
                                @"transLineId":line.fkLineId
                                };
        [[LYAPIManager sharedInstance] POST:@"transportion/userDriverLine/addDriverLine" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            [LYAPIManager showMessageForUser:result[@"msg"]];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
    }];
    UIAlertAction *alertAC = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // do nothing
    }];
    [alert addAction:alertAction];
    [alert addAction:alertAC];
    [self presentViewController:alert animated:YES completion:^{}];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 175.f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
