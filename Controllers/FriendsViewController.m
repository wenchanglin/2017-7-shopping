//
//  FriendsViewController.m
//  885logistics
//
//  Created by Blues on 17/3/31.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "FriendsViewController.h"
#import "DetailViewController.h"
#import "SearchViewController.h"
#import "AnotherUserController.h"
#import "ChatViewController.h"
#import "SearchTCell.h"
#import "UserModel.h"


@interface FriendsViewController ()<UITableViewDelegate,UITableViewDataSource> {

}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIButton *searchBt;
@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UIView *footer;
@property (nonatomic, assign) NSInteger page;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)createViews {
    
     self.page = 0;
    self.dataArr = [[NSMutableArray alloc] init];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = self.header;
    self.tableView.tableFooterView = self.footer;
    [self.tableView  registerNib:[UINib nibWithNibName:@"SearchTCell" bundle:nil] forCellReuseIdentifier:@"SearchTCell"];
    [self.view addSubview:self.tableView];
    
    MJRefreshNormalHeader *mjHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 0;
        [self loadCurrentUserfriendsReload:YES];
    }];
    self.tableView.mj_header = mjHeader;
    MJRefreshBackNormalFooter *mjFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        self.page ++;
        [self loadCurrentUserfriendsReload:NO];
    }];
    self.tableView.mj_footer = mjFooter;
    
    [self loadCurrentUserfriendsReload:NO];
}

- (void)loadCurrentUserfriendsReload:(BOOL)reload {
    
    if (reload) {
        
        [self.dataArr removeAllObjects];
        [self.tableView reloadData];
        
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID],
                            @"page":@(self.page),
                            @"limit":@"15"
                            };
    [[LYAPIManager sharedInstance] POST:@"transportion/user/queryUserFriendByUId" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"_##__%@___",result);
        
        if ([result[@"errcode"] integerValue] == 0) {
            NSDictionary *data = result[@"data"];
            if (NotNilAndNull(data[@"iData"])) {
                
                NSArray *iData = data[@"iData"];
                
                for (NSDictionary *user in iData) {
                    
                    UserModel *model = [[UserModel alloc] init];
                    model.fkUserId = user[@"fkDriverId"];
                    model.phone = user[@"phone"];
                    model.userName = user[@"userName"];
                    model.imageUrl = user[@"userPhotoLocation"];
                    model.roleType = user[@"userIde"];
                    model.remark = user[@"remark"];
                    [self.dataArr addObject:model];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
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
    
    SearchTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTCell" forIndexPath:indexPath];
    UserModel *model = [self.dataArr objectAtIndex:indexPath.row];
    [cell updateViewsWith:model];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    

    UserModel *model = [self.dataArr objectAtIndex:indexPath.row];
    if ([model.fkUserId isEqualToString:[LYHelper getCurrentUserID]]) {
        return;
    }
    ChatViewController *chat = [[ChatViewController alloc] initWithConversationType:ConversationType_PRIVATE targetId:model.fkUserId];
    NSLog(@"___%@__",model.fkUserId);
//    chat.conversationType = ConversationType_PRIVATE;
//    chat.targetId = model.fkUserId;
//    chat.title = model.userName;
//    chat.usModel = model;
    chat.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chat animated:YES];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.f;
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
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kScreenSize.width, 5.f)];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, kScreenSize.width, 1.f)];
        line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_footer addSubview:line];
        _footer.backgroundColor = [UIColor clearColor];
    }
    return _footer;
}


- (UIView *)header {
    
    if (!_header) {
        
        _header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 55.f)];
        _header.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _searchBt = [[UIButton alloc] initWithFrame:CGRectMake(10, 7.f, kScreenSize.width - 20.f, 40.f)];
        [_searchBt setTitle:@"搜索好友姓名" forState:UIControlStateNormal];
        _searchBt.layer.masksToBounds = YES;
        _searchBt.layer.cornerRadius = 1.5f;
        _searchBt.backgroundColor = [UIColor whiteColor];
        [_searchBt setImage:[UIImage imageNamed:@"search_12x12"] forState:UIControlStateNormal];
        _searchBt.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_searchBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_searchBt addTarget:self action:@selector(searchClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_searchBt setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [_header addSubview:_searchBt];
    }
    return _header;
}


- (void)searchClicked:(UIButton *)sender {
    
    SearchViewController *search = [[SearchViewController alloc] init];
    search.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:search animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
