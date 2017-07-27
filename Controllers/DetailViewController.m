//
//  DetailViewController.m
//  885logistics
//
//  Created by Blues on 17/1/12.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "DetailViewController.h"
#import "ChatViewController.h"
#import "DetailTopView.h"
#import "ReleaseView.h"
#import "UserModel.h"


@interface DetailViewController ()<UITableViewDelegate,UITableViewDataSource> {

}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) DetailTopView *header;
@property (nonatomic, weak) ReleaseView *leview;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIBarButtonItem *rightItem;


@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initData {
    
    self.dataArr = [[NSMutableArray alloc] init];
    [self queryDataFromServer];
}

- (void)showLeview {
    self.leview.hidden = NO;
}

- (void)createRightItem {
    
    UIImage *img1 = [[UIImage imageNamed:@"nav4"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:img1 style:UIBarButtonItemStyleDone target:self action:@selector(showLeview)];
    self.navigationItem.rightBarButtonItems = @[item];
    
    NSLog(@"__---__----___");
}


- (void)createViews {

    self.navigationItem.title = @"详细资料";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = self.header;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tabCell"];
    //[self.view addSubview:self.tableView];
    // [self.view addSubview:self.leview];
}


- (void)queryDataFromServer {
    
    if (IsNilOrNull(_model.fkUserId)) {
        return;
    }
    NSDictionary *param = @{@"uid":_model.fkUserId};
    
    [[LYAPIManager sharedInstance] POST:@"transportion/driver/queryDriverDetail" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([result[@"errcode"] integerValue] == 0) {
                if (NotNilAndNull(result[@"data"])) {
                    NSDictionary *data = result[@"data"];
                    [self.header detailFromServer:data];
                    [self.view addSubview:self.tableView];
                    [self.view addSubview:self.leview];
                }
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
    [self judgeIsMyFriends];
}


- (void)judgeIsMyFriends {
    if (!_model) {
        return;
    }
    __weak typeof(self) wSelf = self;
    NSDictionary *param = @{@"fkUserId":[LYHelper getCurrentUserID],
                            @"fkDriverId":_model.fkUserId
                            };
    [[LYAPIManager sharedInstance] POST:@"transportion/user/queryOneFriend" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"___%@",result);
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result[@"errcode"] integerValue] == 0) {
                if (NotNilAndNull(result[@"data"])) {
                    NSDictionary *data = result[@"data"];
                    if ([data[@"status"] isEqualToString:@"同意"]) {
                        [wSelf.header.backBt setTitle:@"发消息" forState:UIControlStateNormal];
                        
                        if (NotNilAndNull(_justBack)) {
                            [wSelf.header.backBt addTarget:self action:@selector(justBackLastView) forControlEvents:UIControlEventTouchUpInside];
                        }else {
                            
                            [wSelf.header.backBt addTarget:self action:@selector(chatOther) forControlEvents:UIControlEventTouchUpInside];
                        }
                        [self createRightItem];
                    }else {
                        
                        [wSelf.header.backBt setTitle:@"添加好友" forState:UIControlStateNormal];
                        [wSelf.header.backBt addTarget:self action:@selector(beFriendUs) forControlEvents:UIControlEventTouchUpInside];
                    }
                }else {
                    [wSelf.header.backBt setTitle:@"添加好友" forState:UIControlStateNormal];
                    [wSelf.header.backBt addTarget:self action:@selector(beFriendUs) forControlEvents:UIControlEventTouchUpInside];
                }
            }
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)justBackLastView {

    [self.navigationController popViewControllerAnimated:YES];
}

- (DetailTopView *)header {

    if (!_header) {
        _header = [[NSBundle mainBundle] loadNibNamed:@"DetailTopView" owner:nil options:nil].lastObject;
        _header.frame = CGRectMake(0, 0, kScreenSize.width, 450);
    }
    return _header;
}


- (void)chatOther {

    ChatViewController *conversationVC = [[ChatViewController alloc]init];
    conversationVC.conversationType = ConversationType_PRIVATE;
    conversationVC.targetId = _model.fkUserId;
    conversationVC.title = _model.userName;
    [self.navigationController pushViewController:conversationVC animated:YES];
}


- (void)beFriendUs {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加好友" message:@"您需要发送申请，等对方通过" preferredStyle:UIAlertControllerStyleAlert];
    //__block NSString *placeholder = [NSString stringWithFormat:@"我是%@",]
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        //textField.placeholder = @"我是";
    }];
    UIAlertAction *acA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *textfield = alert.textFields.firstObject;
        NSString *msgtext = textfield.text;
        
        NSDictionary *param = @{@"fkUserId":[LYHelper getCurrentUserID],
                                @"fkDriverId":_model.fkUserId,
                                @"applyIde":@"employ",
                                @"customized":msgtext
                                };
        NSLog(@"______添加好友_%@",param);
        
        [[LYAPIManager sharedInstance] POST:@"transportion/user/addUserFriend" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *msg = result[@"msg"];
            if (msg.length) {
                [LYAPIManager showMessageForUser:msg];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        }];
    }];
    UIAlertAction *acB = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:acB];
    [alert addAction:acA];
    [self presentViewController:alert animated:YES completion:nil];
}





- (ReleaseView *)leview {
    
    if (!_leview) {
        _leview = [[NSBundle mainBundle] loadNibNamed:@"ReleaseView" owner:nil options:nil].lastObject;
        _leview.frame = CGRectMake(0, 0, kScreenSize.width, kScreenSize.height);
        _leview.dataArr1 = @[@"设置备注",@"删除好友"];
        _leview.dataArr2 = @[@"105",@"106"];
        _leview.tabView.tag = 1000;
        _leview.tabView.delegate = self;
        [_leview.bkBt addTarget:self action:@selector(hidLeView:) forControlEvents:UIControlEventTouchUpInside];
        _leview.hidden = YES;
    }
    return _leview;
}

- (void)hidLeView:(UIButton *)sender {
    self.leview.hidden = YES;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == 1000) {
        
        self.leview.hidden = YES;
        if (indexPath.row == 0) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加备注" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                textField.placeholder = @"备注信息";
            }];
            UIAlertAction *acA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                UITextField *textfield = alert.textFields.firstObject;
                NSString *msgtext = textfield.text;
                NSDictionary *param = @{@"remarker":[LYHelper getCurrentUserID],
                                        @"remarked":_model.fkUserId,
                                        @"remarksName":msgtext,
                                        };
                NSLog(@"______添加好友______%@",param);
                
                [[LYAPIManager sharedInstance] POST:@"transportion/user/addRemarks" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                    NSString *msg = result[@"msg"];
                    if (msg.length) {
                        [LYAPIManager showMessageForUser:msg];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                }];
            }];
            UIAlertAction *acB = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
            [alert addAction:acB];
            [alert addAction:acA];
            [self presentViewController:alert animated:YES completion:^{}];
            
            
        }else if (indexPath.row == 1){
            
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除该好友?" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *acA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSDictionary *param = @{@"fkUserId":[LYHelper getCurrentUserID],
                                        @"fkDriverId":_model.fkUserId,
                                        };
                [[LYAPIManager sharedInstance] POST:@"transportion/user/delUserInfoFriend" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                    NSString *msg = result[@"msg"];
                    if (msg.length) {
                        [LYAPIManager showMessageForUser:msg];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                }];
            }];
            UIAlertAction *acB = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
            [alert addAction:acB];
            [alert addAction:acA];
            [self presentViewController:alert animated:YES completion:^{}];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
