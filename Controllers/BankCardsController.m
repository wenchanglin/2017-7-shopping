//
//  BankCardsController.m
//  885logistics
//
//  Created by Blues on 17/1/19.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BankCardsController.h"
#import "MoreCardController.h"
#import "BankTCell.h"
#import "BCardsModel.h"


@interface BankCardsController ()<UITableViewDelegate,UITableViewDataSource,BankTCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation BankCardsController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self postUrlCardsListReload:YES];
}

- (void)postUrlCardsListReload:(BOOL)reload {

    if (reload) {
        [self.dataArr removeAllObjects];
        [self.tableView reloadData];
    }
 
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID]};
    [[LYAPIManager sharedInstance] POST:@"transportion/bank/queryUserAllBank" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"____%@___",result);
        
        if([result[@"errcode"] integerValue] == 0) {
            
            if (NotNilAndNull(result[@"data"])) {
                NSDictionary *data = result[@"data"];
                if (NotNilAndNull(data[@"iData"])) {
                    NSArray *iData = data[@"iData"];
                    for (NSDictionary *bKCard in iData) {
                        BCardsModel *model = [[BCardsModel alloc] init];
                        
                        model.fkCardID = bKCard[@"id"];
                        [model setValuesForKeysWithDictionary:bKCard];
                        
                        if (NotNilAndNull(bKCard[@"transInfoBank"])) {
                         
                            NSDictionary *bank = bKCard[@"transInfoBank"];
                            
                            if (NotNilAndNull(bank[@"bankPhoto"])) {
                                
                                NSDictionary *photo = bank[@"bankPhoto"];
                                if (NotNilAndNull(photo[@"iData"])) {
                                    NSArray *imgs = photo[@"iData"];
                                    if (imgs.count) {
                                        NSDictionary *imgDict = imgs.firstObject;
                                        model.imgUrl = imgDict[@"location"];
                                    }
                                }
                            }
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
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }];
}

- (void)createViews {
    
    self.navigationItem.title = @"银行卡";
    
    [self createNavItems];
    
    self.dataArr = [[NSMutableArray alloc] init];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BankTCell" bundle:nil] forCellReuseIdentifier:@"BankTCell"];
    
    [self.view addSubview:self.tableView];
}

- (void)createNavItems {

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(moreBankCard)];
    item.tintColor = [UIColor whiteColor];
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[item];
}

- (void)moreBankCard {
    
    MoreCardController *more = [[MoreCardController alloc] init];
    [more addPopItem];
    [self.navigationController pushViewController:more animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BankTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BankTCell" forIndexPath:indexPath];
    BCardsModel *model = [self.dataArr objectAtIndex:indexPath.row];
    cell.delegate = self;
    [cell updateViewWith:model];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)deleteBankCardBy:(BCardsModel *)model {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定删除该银行卡?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary *param = @{@"usrbid":model.fkCardID};
        
        [[LYAPIManager sharedInstance] POST:@"transportion/bank/delUserBankCard" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            if ([result[@"errcode"] integerValue] == 0) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.tableView beginUpdates];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.dataArr indexOfObject:model] inSection:0];
                    [self.dataArr removeObjectAtIndex:indexPath.row];
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView endUpdates];
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
    }];
    UIAlertAction *alertAC = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // do nothing
    }];
    [alert addAction:alertAction];
    [alert addAction:alertAC];
    [self presentViewController:alert animated:YES completion:nil];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kScreenSize.width/3.f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
