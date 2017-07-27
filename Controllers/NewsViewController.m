//
//  NewsViewController.m
//  885logistics
//
//  Created by Blues on 17/1/9.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "NewsViewController.h"
#import "BBSDetailController.h"
#import "NewsTCell2.h"
#import "NewsModel.h"

@interface NewsViewController ()<UITableViewDelegate,UITableViewDataSource>{

}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIView *footer;
@property (nonatomic, assign) NSInteger page;

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)initData {
    
    self.page = 0;
    self.dataArr = [[NSMutableArray alloc] init];
    
    [self queryDataFromServerReload:NO];
}

- (void)createViews {
    self.navigationItem.title = @"消息中心";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = self.footer;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"NewsTCell2" bundle:nil] forCellReuseIdentifier:@"NewsTCell2"];
    
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
    
    NSDictionary *param = @{@"userId":[LYHelper getCurrentUserID],
                            @"page":@(self.page),
                            @"limit":@"10"
                            };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[LYAPIManager sharedInstance] POST:@"transportion/messageCenter/querySysMessageList" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            NSDictionary *data = result[@"data"];
            if (NotNilAndNull(data[@"iData"])) {
                NSArray *iData = data[@"iData"];
                for (NSDictionary *msg in iData) {
                    
                    NewsModel *model = [[NewsModel alloc] init];
                    model.fkMsgId = msg[@"id"];
                    [model setValuesForKeysWithDictionary:msg];
                    if (NotNilAndNull(msg[@"customized"])) {
                        model.content = [model.content stringByAppendingString:msg[@"customized"]];
                    }
                    NSLog(@"___%@___%@",msg[@"type"],msg[@"msgOption"]);
                    
                    [self.dataArr addObject:model];
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
    return  self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewsTCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsTCell2" forIndexPath:indexPath];
    NewsModel *model = [self.dataArr objectAtIndex:indexPath.row];
    [cell paddingMsgDetail:model];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewsModel *model = [self.dataArr objectAtIndex:indexPath.row];
    if ([model.type isEqualToString:@"帖子_回复"]) {
        
        if (NotNilAndNull(model.fkForumId)) {
            
            BBSDetailController *detail = [[BBSDetailController alloc] init];
            detail.postID = model.fkForumId;
            [detail addPopItem];
            [self.navigationController pushViewController:detail animated:YES];
        }
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NewsModel *model = [self.dataArr objectAtIndex:indexPath.row];
    if ([model.type isEqualToString:@"申请加友"]) {
        return 106.f;
    }
    return 78.f;
}

//编辑样式(delete)
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (NSArray<UITableViewRowAction *>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak typeof(self) wSelf = self;
    
    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"删除");
        
        NewsModel *model = [self.dataArr objectAtIndex:indexPath.row];
        
        NSDictionary *param = @{@"sysId":model.fkMsgId};
        
        [[LYAPIManager sharedInstance] POST:@"transportion/messageCenter/deleteSysMessage" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSDictionary *reslut = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            [LYAPIManager showMessageForUser:reslut[@"msg"]];
            
            if ([reslut[@"errcode"] integerValue] == 0) {
                
                [wSelf.dataArr removeObject:model];
                // Delete the row from the data source.
                [wSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [wSelf.tableView reloadData];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
    }];
    rowAction.backgroundColor = [UIColor lightGrayColor];
    NSArray *arr = @[rowAction];
    return arr;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void)viewWillLayoutSubviews {
    
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - getter
- (UIView *)footer {

    if (!_footer) {
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 1.f)];
        _footer.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _footer;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
