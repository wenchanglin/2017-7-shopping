//
//  HaveCardsController.m
//  885logistics
//
//  Created by Blues on 17/3/29.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "HaveCardsController.h"
#import "BCardsModel.h"
#import "BankTCell.h"


@interface HaveCardsController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, strong) BCardsModel *model;

@end

@implementation HaveCardsController

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
                        model.isNow = @"0";
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
    
    self.navigationItem.title = @"我的银行卡";
    
    self.dataArr = [[NSMutableArray alloc] init];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BankTCell" bundle:nil] forCellReuseIdentifier:@"BankTCell"];
    
    [self.view addSubview:self.tableView];
    
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(moreBankCard)];
    item.tintColor = [UIColor whiteColor];
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[item];
}

- (void)moreBankCard {
    if (_model) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(updateLastController:)]) {
            [self.delegate updateLastController:_model];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
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
    [cell updateViewWith:model];
    cell.deleteBt.userInteractionEnabled = NO;
    if ([model.isNow integerValue] == 1) {
        [cell.deleteBt setImage:[UIImage imageNamed:@"tick1"] forState:UIControlStateNormal];
    }else {
        [cell.deleteBt setImage:nil forState:UIControlStateNormal];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kScreenSize.width/3.f;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

    BCardsModel *model = [self.dataArr objectAtIndex:indexPath.row];
    model.isNow = @"0";
    BankTCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.deleteBt setImage:nil forState:UIControlStateNormal];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BCardsModel *model = [self.dataArr objectAtIndex:indexPath.row];
    model.isNow = @"1";
    BankTCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.deleteBt setImage:[UIImage imageNamed:@"tick1"] forState:UIControlStateNormal];
    
    self.model = model;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
