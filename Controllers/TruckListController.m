//
//  TruckListController.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/6.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "TruckListController.h"
#import "CarTypeModel.h"
#import "CarTypeCell.h"
#import "TLSearchCell.h"

@interface TruckListController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate> {

}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) TLSearchCell *header;
@property (nonatomic, strong) UIView *footer;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) CarTypeModel *model;

@end

@implementation TruckListController

- (instancetype)initWithRTTruckBlock:(RTTruckBlock)myblock {
    self = [super init];
    if (self) {
        _myBlock = myblock;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)createViews {
    
    self.dataArr = [[NSMutableArray alloc] init];
    self.navigationItem.title = @"车辆信息";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(completeMine)];
    right.tintColor = [UIColor whiteColor];
    [right setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[right];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = self.header;
    self.tableView.tableFooterView = self.footer;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"CarTypeCell" bundle:nil] forCellReuseIdentifier:@"CarTypeCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self queryDataFromServerReload:NO];
}


- (void)completeMine {

    if (self.myBlock && _model) {
        self.myBlock(_model);
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (TLSearchCell *)header {

    if (!_header) {
        _header = [[NSBundle mainBundle] loadNibNamed:@"TLSearchCell" owner:nil options:nil].lastObject;
        _header.frame = CGRectMake(0, 0, kScreenSize.width, 46.f);
        [_header.srcBt addTarget:self action:@selector(searchTruck) forControlEvents:UIControlEventTouchUpInside];
        _header.srcTf.delegate = self;
    }
    return _header;
}

- (void)searchTruck {

    [self.view endEditing:YES];
    //NSString *text = self.header.srcTf.text;
    
    [self queryDataFromServerReload:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:1 animations:^{
        self.header.placeView.alpha = 0.f;
    }];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {

    if (textField.text.length == 0) {
        [UIView animateWithDuration:2 animations:^{
           self.header.placeView.alpha = 1.f;
        }];
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (void)queryDataFromServerReload:(BOOL)reload {

    if (reload) {
        [self.dataArr removeAllObjects];
        [self.tableView reloadData];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[LYAPIManager sharedInstance] POST:@"transportion/truckModel/queryAll" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            NSDictionary *data = result[@"data"];
            
            if (NotNilAndNull(data[@"iData"])) {
                NSArray *iData = data[@"iData"];
                
                for (NSDictionary *truck in iData) {
                    
                    CarTypeModel *model = [[CarTypeModel alloc] init];
                    [model setValuesForKeysWithDictionary:truck];
                    
                    model.modelWeight = [NSString stringWithFormat:@"%@kg",truck[@"modelWeight"]];
                    model.CarID = truck[@"id"];
                    model.isNow = @"0";
                    [self.dataArr addObject:model];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CarTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CarTypeCell" forIndexPath:indexPath];
    CarTypeModel *model = [self.dataArr objectAtIndex:indexPath.row];
    cell.nameLb.text = model.carModel;
    cell.sizeLb.text = model.modelSize;
    cell.weightLb.text = model.modelWeight;
    if ([model.isNow integerValue] == 1) {
        cell.markIv.hidden = NO;
    }else {
        cell.markIv.hidden = YES;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.view endEditing:YES];
    CarTypeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    CarTypeModel *model = [self.dataArr objectAtIndex:indexPath.row];
    model.isNow = @"1";
    cell.markIv.hidden = NO;
    
    self.model = model;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CarTypeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    CarTypeModel *model = [self.dataArr objectAtIndex:indexPath.row];
    model.isNow = @"0";
    cell.markIv.hidden = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.f;
}

- (UIView *)footer {
    
    if (!_footer) {
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 1.f)];
        _footer.backgroundColor = [UIColor clearColor];
    }
    return _footer;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
