//
//  UserDetailController.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/22.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "UserDetailController.h"
#import "ChatViewController.h"
#import "DetailTopView.h"

@interface UserDetailController ()<UITableViewDelegate,UITableViewDataSource> {
    
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) DetailTopView *header;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSString *userName;

@end

@implementation UserDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)createViews {
    
    self.dataArr = [[NSMutableArray alloc] init];
    self.navigationItem.title = @"详细资料";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableHeaderView = self.header;
    
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tabCell"];
    [self.view addSubview:self.tableView];
    
     _userName = @"";
    
    [self queryDataFromServer];
}

- (void)queryDataFromServer {
    
    if (!_fkUserId) {
        return;
    }
    
    NSDictionary *param = @{@"uid":_fkUserId};
    
    [[LYAPIManager sharedInstance] POST:@"transportion/employ/queryEmployDetails" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            if (NotNilAndNull(result[@"data"])) {
                NSDictionary *data = result[@"data"];
                [self.header detailFromServer:data];
                if (NotNilAndNull(data[@"userInfoBase"])) {
                    NSDictionary *userInfoBase = data[@"userInfoBase"];
                    if (NotNilAndNull(userInfoBase[@"userName"])) {
                        _userName = userInfoBase[@"userName"];
                    }
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) { }];
}

- (DetailTopView *)header {
    
    if (!_header) {
        _header = [[NSBundle mainBundle] loadNibNamed:@"DetailTopView" owner:nil options:nil].lastObject;
        _header.frame = CGRectMake(0, 0, kScreenSize.width, 450);
        [_header.backBt addTarget:self action:@selector(chatWithHim) forControlEvents:UIControlEventTouchUpInside];
    }
    return _header;
}
- (void)chatWithHim {
    
    if (IsNilOrNull(_userName)) {
        _userName = @"";
    }
    ChatViewController *conversationVC = [[ChatViewController alloc]init];
    conversationVC.conversationType = ConversationType_PRIVATE;
    conversationVC.targetId = _fkUserId;
    conversationVC.title = _userName;
    conversationVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:conversationVC animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tabCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


@end
