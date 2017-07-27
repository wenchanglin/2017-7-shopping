//
//  CitiesViewController.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/14.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "CitiesViewController.h"
#import "CVCReusableView.h"
#import "CityCCell.h"
#import "CityModel.h"


@interface CitiesViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,CityCCellDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{

}
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *bt;
@property (weak, nonatomic) IBOutlet UITextField *tf;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) NSMutableArray *dataArr1;
@property (nonatomic, strong) NSMutableArray *dataArr2;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *footer;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation CitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)createViews {

    self.navigationItem.title = @"城市设置";
    [self.bt setTitleColor:MainColor forState:UIControlStateNormal];
    self.dataArr = [[NSMutableArray alloc] init];
    self.dataArr1 = [[NSMutableArray alloc] init];
    self.dataArr2 = [[NSMutableArray alloc] init];
    CGFloat ItemW   = (kScreenSize.width - 40.f)/4.f;
    CGFloat height  = 50.f;
    self.layout.itemSize = CGSizeMake(ItemW, height);
    self.layout.minimumLineSpacing = 5.f;
    self.layout.minimumInteritemSpacing = 5.f;
    self.layout.sectionInset = UIEdgeInsetsMake(0, 10.f, 0, 10.f);
    self.layout.headerReferenceSize = CGSizeMake(kScreenSize.width, 40.f);
    [self.collectionView  registerNib:[UINib nibWithNibName:@"CityCCell" bundle:nil] forCellWithReuseIdentifier:@"CityCCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"CVCReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CVCReusableView"];
    [self queryDataFromServer];
}

// 搜搜
- (IBAction)src:(id)sender {
    
    [self.view endEditing:YES];
    
    [self.dataArr removeAllObjects];
    [self.tableView reloadData];
    
    NSString *city = self.tf.text;
    if (IsEmptyStr(city)) {
        [self showMessageForUser:@"输入查询城市"];
        return;
    }
    
    NSDictionary *param = @{@"cName":city};
    [[LYAPIManager sharedInstance] POST:@"transportion/lkCites/queryByAllCName" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            if (NotNilAndNull(result[@"data"])) {
             
                NSDictionary *data = result[@"data"];
                CityModel *model = [[CityModel alloc] init];
                model.supCity = data[@"city"];
                model.isMine = @"NO";
                [self.dataArr addObject:model];
            }
        }
        if (self.dataArr.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view addSubview:self.tableView];
                [self.tableView reloadData];
            });
        }else {
            [LYAPIManager showMessageForUser:@"未查询到该城市"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    
    }];
}

- (void)queryDataFromServer {
    

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *param = @{@"fkDriverId":[LYHelper getCurrentUserID]};
    
    [[LYAPIManager sharedInstance] POST:@"transportion/driverCity/queryDriverSupCity" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            if (NotNilAndNull(result[@"data"])) {
                NSDictionary *data = result[@"data"];
                if (NotNilAndNull(data[@"iData"])) {
                    NSArray *iData = data[@"iData"];
                    
                    for (NSDictionary *city in iData) {
                        
                        CityModel *model = [[CityModel alloc] init];
                        model.cityID = city[@"id"];
                        model.supCity = city[@"supCity"];
                        model.isMine = @"YES";
                        [self.dataArr1 addObject:model];
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) { }];
    
    NSDictionary *param2 = @{@"uid":[LYHelper getCurrentUserID]};
    [[LYAPIManager sharedInstance] POST:@"transportion/lkCites/queryAllHotCity" parameters:param2 progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            if (NotNilAndNull(result[@"data"])) {
                NSDictionary *data = result[@"data"];
                if (NotNilAndNull(data[@"iData"])) {
                    NSArray *iData = data[@"iData"];
                    
                    for (NSDictionary *city in iData) {
                        CityModel *model = [[CityModel alloc] init];
                        model.cityID = city[@"id"];
                        model.supCity = city[@"city"];
                        model.isMine = @"NO";
                        [self.dataArr2 addObject:model];
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.collectionView reloadData];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.dataArr1.count;
    }else {
        return self.dataArr2.count;
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    CityCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CityCCell" forIndexPath:indexPath];
    CityModel *model = nil;
    if (indexPath.section == 0) {
        model = [self.dataArr1 objectAtIndex:indexPath.row];
    }else {
        model = [self.dataArr2 objectAtIndex:indexPath.row];
    }
    cell.delegate = self;
    [cell updateViewWithCity:model];
    return cell;
}

- (void)deleteCityModel:(CityModel *)model {

    if ([self.dataArr1 containsObject:model]) {
        
        NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID],
                                @"city":model.supCity
                                };
        NSIndexPath *index = [NSIndexPath indexPathForRow:[self.dataArr1 indexOfObject:model] inSection:0];
        [self.dataArr1 removeObject:model];
        [self.collectionView deleteItemsAtIndexPaths:@[index]];
    
        [[LYAPIManager sharedInstance] POST:@"transportion/driverCity/delDriverSupCity" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) { }];
    }
}

- (void)moreCityModel:(CityModel *)model {
    
    if (![self isMineCity:model]) {
        
        NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID],
                                @"city":model.supCity
                                };
        model.isMine = @"YES";
        NSIndexPath *index = [NSIndexPath indexPathForRow:self.dataArr1.count inSection:0];
        [self.dataArr1 addObject:model];
        [self.collectionView insertItemsAtIndexPaths:@[index]];
        [[LYAPIManager sharedInstance] POST:@"transportion/driverCity/addDriverSupCity" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) { }];
    }
}

- (BOOL)isMineCity:(CityModel *)model {
    BOOL rat = NO;
    for (CityModel *tmp in self.dataArr1) {
        if ([tmp.supCity isEqualToString:model.supCity]) {
            rat = YES;
        }
    }
    return rat;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    CVCReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CVCReusableView" forIndexPath:indexPath];
    NSArray *titles = @[@"已选接单城市",@"热门城市"];
    view.tLb.text = [titles objectAtIndex:indexPath.section];
    return view;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (UITableView *)tableView {

    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50.f, kScreenSize.width, kScreenSize.height - 50.f - 64.f) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = self.footer;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tabCell"];
    }
    return _tableView;
}

- (UIView *)footer {

    if (!_footer) {
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 50)];
        _footer.backgroundColor = [UIColor clearColor];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 1)];
        line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.f, 1.f, kScreenSize.width, 49.f)];
        [backBtn setTitle:@"返回" forState:UIControlStateNormal];
        [backBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        backBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
        [backBtn addTarget:self action:@selector(cancelFromSearchResult) forControlEvents:UIControlEventTouchUpInside];
        [_footer addSubview:backBtn];
        [_footer addSubview:line];
    }
    return _footer;
}

- (void)cancelFromSearchResult {
    [self.tableView removeFromSuperview];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tabCell" forIndexPath:indexPath];
    CityModel *model = [self.dataArr objectAtIndex:indexPath.row];
    cell.textLabel.text = model.supCity;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CityModel *model = [self.dataArr objectAtIndex:indexPath.row];
    [self moreCityModel:model];
    [self.tableView removeFromSuperview];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
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
