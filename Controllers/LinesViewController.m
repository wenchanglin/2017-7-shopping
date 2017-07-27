//
//  LinesViewController.m
//  LogisticsDriver
//
//  Created by Blues on 17/1/23.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "LinesViewController.h"
#import "AllLinesController.h"
#import "LineTCell.h"
#import "LineModel.h"

@interface LinesViewController ()<UITableViewDataSource,UITableViewDelegate,LineTCellDelegate>{
    
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, assign) NSInteger page;

@end

@implementation LinesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryDataFromServerReload:YES];
}

- (void)createViews {
    
    self.navigationItem.title = @"我的专线";
    self.dataArr = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(moreLines)];
    item.tintColor = [UIColor whiteColor];
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[item];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"LineTCell" bundle:nil] forCellReuseIdentifier:@"LineTCell"];
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


- (void)moreLines {
    
    AllLinesController *allLine = [[AllLinesController alloc] init];
    [allLine addPopItem];
    [self.navigationController pushViewController:allLine animated:YES];
}

- (void)queryDataFromServerReload:(BOOL)reload {

    if (reload) {
        [self.dataArr removeAllObjects];
        [self.tableView reloadData];
    }

    NSDictionary *param = @{@"fkDriverId":[LYHelper getCurrentUserID],
                            @"page":@(self.page),
                            @"limit":@"8"
                            };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[LYAPIManager sharedInstance] POST:@"transportion/userDriverLine/queryDriverLine" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            if (NotNilAndNull(result[@"data"])) {
                NSDictionary *data = result[@"data"];
                if (NotNilAndNull(data[@"iData"])) {
                    NSArray *iData = data[@"iData"];
                    for (NSDictionary *dict in iData) {
                        
                        LineModel *model = [[LineModel alloc] init];
                        model.fkLineId = dict[@"transLineId"];
                        [model setValuesForKeysWithDictionary:dict];
                        if (NotNilAndNull(dict[@"transInfoLine"])) {
                            NSDictionary *tsLine = dict[@"transInfoLine"];
                            [model setValuesForKeysWithDictionary:tsLine];
                        }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LineTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LineTCell" forIndexPath:indexPath];
    LineModel *model = [self.dataArr objectAtIndex:indexPath.row];
    [cell updateViewWithLine:model];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)deleteLineWithLineID:(LineModel *)line {

    if (!line) {
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定删除该专线?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSDictionary *param = @{@"fkDriverId":[LYHelper getCurrentUserID],
                                @"dlid":line.fkLineId
                                };
        NSLog(@"___%@",param);
        
        [[LYAPIManager sharedInstance] POST:@"transportion/userDriverLine/delDriverLine" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            [LYAPIManager showMessageForUser:result[@"msg"]];
            
            if ([result[@"errcode"] integerValue] == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView beginUpdates];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.dataArr indexOfObject:line] inSection:0];
                    [self.dataArr removeObjectAtIndex:indexPath.row];
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView endUpdates];
                });
            }
        } failure:nil];
    }];
    UIAlertAction *alertB = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:alertA];
    [alert addAction:alertB];
    [self presentViewController:alert animated:YES completion:^{}];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 175.f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
