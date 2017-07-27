//
//  InsuranceListController.m
//  885logistics
//
//  Created by Blues on 17/1/20.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "InsuranceListController.h"
#import "InsuranceTCell.h"
#import "SecureDTO.h"

@interface InsuranceListController ()<UITableViewDelegate,UITableViewDataSource>{

}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIView *footer;

@end

@implementation InsuranceListController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)createViews {

    self.navigationItem.title = @"货物保险清单";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.dataArr = [[NSMutableArray alloc] init];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0.f, kScreenSize.width, kScreenSize.height - 64.f) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.tableFooterView = self.footer;
    [self.tableView registerNib:[UINib nibWithNibName:@"InsuranceTCell" bundle:nil] forCellReuseIdentifier:@"InsuranceTCell"];
    self.tableView.separatorColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    [self queryDataFromServer];
}

- (void)queryDataFromServer {

    if (!_fkOrderId) {
        return;
    }
    NSDictionary *param = @{@"toId":_fkOrderId};
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[LYAPIManager sharedInstance] POST:@"transportion/goodPolicy/queryGoodPolicyAll" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            if (NotNilAndNull(result[@"data"])) {
                
                NSDictionary *data = result[@"data"];
                if (NotNilAndNull(data[@"iData"])) {
                    
                    NSArray *iData = data[@"iData"];
                    for (NSDictionary *dict in iData) {
                        
                        SecureDTO *scDto = [[SecureDTO alloc] init];
                        [scDto setValuesForKeysWithDictionary:dict];
                        scDto.fkSecureId = dict[@"id"];
                        [self.dataArr addObject:scDto];
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


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InsuranceTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InsuranceTCell" forIndexPath:indexPath];
    cell.deleteBk.hidden = YES;
    SecureDTO *dto = [self.dataArr objectAtIndex:indexPath.row];
    [cell loadDataFromSecureDTO:dto];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 260.f;
}


- (UIView *)footer {
    if (!_footer) {
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 10.f)];
        _footer.backgroundColor = [UIColor clearColor];
    }
    return _footer;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
