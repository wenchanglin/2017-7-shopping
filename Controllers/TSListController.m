//
//  TSListController.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/9.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "TSListController.h"
#import "KindsModel.h"
#import "ThemeTCell.h"


@interface TSListController ()<UITableViewDelegate,UITableViewDataSource>{
    
}
@property (nonatomic, strong) UIView *footer;
@property (strong, nonatomic)  UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSArray *stateArr;
@property (nonatomic, strong) KindsModel *model;


@end

@implementation TSListController

- (instancetype)initWithRTKindBlock:(RTKindBlock)block {

    self = [super init];
    if (self) {
        _myBlock = block;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)createViews {
    
    self.navigationItem.title = @"运输类型";
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(completeMine)];
    right.tintColor = [UIColor whiteColor];
    [right setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[right];
    
    self.dataArr = [[NSMutableArray alloc] init];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f) style:UITableViewStylePlain];
    
    self.tableView.tableFooterView = self.footer;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ThemeTCell" bundle:nil] forCellReuseIdentifier:@"ThemeTCell"];
    
    [self.view addSubview:self.tableView];
    [self queryTransportTypesFromService];
}

- (void)completeMine {

    if (self.myBlock && self.model) {
        self.myBlock(self.model);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)queryTransportTypesFromService {
    
    [[LYAPIManager sharedInstance] POST:@"transportion/transClass/queryAll" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([result[@"errcode"] integerValue] == 0) {
            if ([result[@"errcode"] integerValue] == 0) {
                NSDictionary *data = result[@"data"];
                if (NotNilAndNull(data[@"iData"])) {
                    NSArray *iData = data[@"iData"];
                    for (NSDictionary *transType in iData) {
                        
                        KindsModel *model = [[KindsModel alloc] init];
                        model.kindID = transType[@"id"];
                        model.text = transType[@"transClass"];
                        model.isNow = @"0";
                        [self.dataArr addObject:model];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                    
                }
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ThemeTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThemeTCell" forIndexPath:indexPath];
    
    KindsModel *model = [self.dataArr objectAtIndex:indexPath.row];
    cell.tLb.text = model.text;
    if ([model.isNow boolValue]) {
        cell.iv.hidden = NO;
    }else {
        cell.iv.hidden = YES;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ThemeTCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    KindsModel *model = [self.dataArr objectAtIndex:indexPath.row];
    model.isNow = @"1";
    cell.iv.hidden = NO;
    
    self.model = model;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ThemeTCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    KindsModel *model = [self.dataArr objectAtIndex:indexPath.row];
    model.isNow = @"0";
    cell.iv.hidden = YES;
}

#pragma mark - getter

- (UIView *)footer {
    if (!_footer) {
        
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0, kScreenSize.width, 1.f)];
        _footer.backgroundColor = [UIColor clearColor];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15.f, 0, kScreenSize.width - 15.f, 1.f)];
        line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_footer addSubview:line];
    }
    return _footer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
