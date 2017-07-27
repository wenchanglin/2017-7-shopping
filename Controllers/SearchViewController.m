//
//  SearchViewController.m
//  CustomFurniture
//
//  Created by Blues on 16/10/9.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "SearchViewController.h"
#import "DetailViewController.h"
#import "AnotherUserController.h"
#import "SearchTCell.h"
#import "UserModel.h"



@interface SearchViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource> {

}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *friendsArr;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) UIView *sectionView0;
@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UILabel *sStrLb;
@property (nonatomic, strong) UIView *footer;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initData {

    self.dataArr    =   [[NSMutableArray alloc] init];
    self.friendsArr =   [[NSMutableArray alloc] init];
    
   // [self loadCurrentUserfriends];
}

- (void)createViews {
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchView];
    self.navigationItem.leftBarButtonItems = @[searchItem];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelDoing:)];
    right.tintColor = [UIColor whiteColor];
    [right setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[right];
    
    [self.searchField becomeFirstResponder];
    
    [self.view addSubview:self.tableView];
}

//- (void)loadCurrentUserfriends {
//    
//    NSString *user = [LYHelper getCurrentUserID];
//    [[LYAPIManager sharedInstance] POST:@"transportion/user/queryUserFriendByUId" parameters:@{@"uid":user} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//        
//        NSLog(@"_##__%@___",result);
//        
//        if ([result[@"errcode"] integerValue] == 0) {
//            NSDictionary *data = result[@"data"];
//            if (NotNilAndNull(data[@"iData"])) {
//                
//                NSArray *iData = data[@"iData"];
//                for (NSDictionary *user in iData) {
//                    
//                    
//                }
//            }
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//    }];
//}

// 开始搜索
- (void)searchMyFriends {
    
    NSString *searchWords = self.searchField.text;
    if (searchWords.length == 0) {
        [self showMessageForUser:@"请输入昵称或手机号"];
        return;
    }
    
    [self.searchField endEditing:YES];
    
    NSDictionary *param = @{@"searchWords":searchWords};
    
    [self.dataArr removeAllObjects];
    [self.tableView reloadData];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[LYAPIManager sharedInstance] POST:@"transportion/base/queryUserByCondition" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"___%@___",result);
        if ([result[@"errcode"] integerValue] == 0) {
            if (NotNilAndNull(result[@"data"])) {
                
                NSDictionary *data = result[@"data"];
                
                if (NotNilAndNull(data[@"iData"])) {
                    
                    NSArray *iData = data[@"iData"];
                    for (NSDictionary *user in iData) {
                        
                        UserModel *model = [[UserModel alloc] init];
                        
                        model.fkUserId = user[@"id"];
                        [model setValuesForKeysWithDictionary:user];
                        if (NotNilAndNull(user[@"userPhoto"])) {
                            NSDictionary *userPhoto = user[@"userPhoto"];
                            model.imageUrl = userPhoto[@"location"];
                        }
                        [self.dataArr addObject:model];
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.tableView reloadData];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
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
    
    if ([model.roleType isEqualToString:@"driver"]){
    
        DetailViewController *detail = [[DetailViewController alloc]init];
        [detail addPopItem];
        detail.model = model;
        [self.navigationController pushViewController:detail animated:YES];
    
    }else {
        
        AnotherUserController *another = [[AnotherUserController alloc] init];
        [another addPopItem];
        another.model = model;
        [self.navigationController pushViewController:another animated:YES];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (section == 0) {
        return self.sectionView0;
    }
    return nil;
}

- (void)cancelDoing:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - UITextfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchField endEditing:YES];
    return YES;
}


#pragma mark - getter
- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //_tableView.tableHeaderView = self.header;
        _tableView.tableFooterView = self.footer;
        [_tableView registerNib:[UINib nibWithNibName:@"SearchTCell" bundle:nil] forCellReuseIdentifier:@"SearchTCell"];
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}


- (UIView *)searchView {
    
    CGFloat height = 33.f;
    CGFloat width = kScreenSize.width - 75.f;
    
    if (!_searchView) {
        _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        _searchView.backgroundColor = [UIColor whiteColor];
        _searchView.layer.masksToBounds = YES;
        _searchView.layer.cornerRadius = 3.f;
        
        _searchField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, width  ,height)];
        _searchField.placeholder = @"用户昵称/手机号码";
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24.f, height)];
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(6.f, 0, 12.f, 12.f)];
        img.image = [UIImage imageNamed:@"search_12x12"];
        img.center = view.center;
        [view addSubview:img];
        _searchField.leftView = view;
        UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 65, height)];
        view2.backgroundColor = [UIColor whiteColor];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, height)];
        [btn setTitle:@"搜索" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
        [btn addTarget:self action:@selector(searchMyFriends) forControlEvents:UIControlEventTouchUpInside];
        [view2 addSubview:btn];
        _searchField.rightView = view2;
        
        _searchField.font = [UIFont systemFontOfSize:15.f];
        _searchField.textColor = [UIColor darkGrayColor];
        _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;//编辑清除
        _searchField.leftViewMode = UITextFieldViewModeAlways;
        _searchField.rightViewMode = UITextFieldViewModeAlways;
        _searchField.returnKeyType = UIReturnKeyDone;
        _searchField.layer.masksToBounds = YES;
        _searchField.layer.cornerRadius = 3.f;
        _searchField.delegate = self;
        
        [_searchView addSubview:_searchField];
    }
    return _searchView;
}


- (UIView *)sectionView0 {

    if (!_sectionView0) {
        _sectionView0 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 40.f)];
        _sectionView0.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(18.f, 10.f, 200, 20.f)];
        lb.text = @"我的好友";
        lb.textColor = [UIColor lightGrayColor];
        lb.textAlignment = NSTextAlignmentLeft;
        lb.font = [UIFont systemFontOfSize:14.f];
        [_sectionView0 addSubview:lb];
    }
    return _sectionView0;
}


- (UIView *)footer {

    if (!_footer) {
        
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 40)];
        _footer.backgroundColor = [UIColor clearColor];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 1.f)];
        line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_footer addSubview:line];
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
        lb.center = _footer.center;
        lb.textAlignment = NSTextAlignmentCenter;
        lb.textColor = [UIColor lightGrayColor];
        lb.text = @"已搜索出全部结果";
        lb.font = [UIFont systemFontOfSize:14.f];
        [_footer addSubview:lb];
    }
    return _footer;
}

//
//- (UIView *)header {
//
//    if (!_header) {
//        
//        _header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 80.f)];
//        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(15.f, 16.f, 47.f, 47.f)];
//        iv.image = [UIImage imageNamed:@"sv_src"];
//        [_header addSubview:iv];
//        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(70.f, 30.f, 50.f, 20.f)];
//        lb.textColor = [UIColor darkGrayColor];
//        lb.text = @"搜索:";
//        lb.textAlignment = NSTextAlignmentLeft;
//        lb.font = [UIFont systemFontOfSize:14.f];
//        [_header addSubview:lb];
//        _sStrLb = [[UILabel alloc] initWithFrame:CGRectMake(120.f, 30.f, kScreenSize.width - 150.f, 20.f)];
//        _sStrLb.textColor = MainColor;
//        _sStrLb.textAlignment = NSTextAlignmentLeft;
//        _sStrLb.font = [UIFont systemFontOfSize:14.f];
//        [_header addSubview:_sStrLb];
//    }
//    return _header;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
