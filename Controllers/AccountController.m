//
//  AccountController.m
//  885logistics
//
//  Created by Blues on 17/1/9.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "AccountController.h"
#import "DrawViewController.h"
#import "BillViewController.h"
#import "BankCardsController.h"
#import "RechargeController.h"
#import "AccountCRView.h"
#import "AccountCCell.h"
#import "MineModel.h"



#define kHeadHeight 180.f

@interface AccountController () <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, weak) AccountCRView *topView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation AccountController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID]};
    [[LYAPIManager sharedInstance] POST:@"transportion/account/queryMyBalance" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            if (NotNilAndNull(result[@"data"])) {
                NSDictionary *data = result[@"data"];
                self.topView.balanceLb.text = [NSString stringWithFormat:@"%.2f",[data[@"balance"] floatValue]];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


- (void)initData {
    
    self.dataArr = [[NSMutableArray alloc] init];
    
    NSArray *titles = @[@"充值",@"提现",@"资金明细",@"银行卡"];
    
    for (NSInteger i = 0; i < titles.count; i ++) {
        
        MineModel *model = [[MineModel alloc] init];
        model.titleName = titles[i];
        model.imgName = [NSString stringWithFormat:@"account%ld",i+1];
        [self.dataArr addObject:model];
    }
}


- (void)createViews {
    
    self.navigationItem.title = @"我的账户";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    CGFloat itemW = (kScreenSize.width - 1)/2.f;
    CGFloat itemH = 65.f;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 1.f;
    layout.minimumLineSpacing = 1.f;
    layout.itemSize = CGSizeMake(itemW, itemH);
    layout.headerReferenceSize = CGSizeMake(kScreenSize.width, kHeadHeight);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 50.f) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"AccountCCell" bundle:nil] forCellWithReuseIdentifier:@"AccountCCell"];

    [self.collectionView registerNib:[UINib nibWithNibName:@"AccountCRView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"AccountCRView"];
    
    [self.view addSubview:self.collectionView];
    
    
  
    

}


#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AccountCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AccountCCell" forIndexPath:indexPath];
    MineModel *model = [self.dataArr objectAtIndex:indexPath.row];
    cell.iv.image = [UIImage imageNamed:model.imgName];
    cell.lb.text = model.titleName;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    AccountCRView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"AccountCRView" forIndexPath:indexPath];
    self.topView = headerView;
    
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BaseViewController *controller = nil;
    if (indexPath.row == 0) {
        controller = [[RechargeController alloc] init];
    }else if(indexPath.row == 1){
        controller = [[DrawViewController alloc] init];
    }else if (indexPath.row == 2){
        controller = [[BillViewController alloc] init];
    }else if (indexPath.row == 3){
        controller = [[BankCardsController alloc] init];
    }
    if (NotNilAndNull(controller)) {
        [controller addPopItem];
        [self.navigationController pushViewController:controller animated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}



@end
