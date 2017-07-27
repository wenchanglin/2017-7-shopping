//
//  MineViewController.m
//  885logistics
//
//  Created by Blues on 17/1/3.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "MineViewController.h"
#import "AccountController.h"
#import "CouponVController.h"
#import "CommentsController.h"
#import "PostsViewController.h"
#import "ManageLinesController.h"
#import "NewsViewController.h"
#import "ShareController.h"
#import "SystemSetController.h"
#import "MyVController.h"
#import "HeadView.h"
#import "MineModel.h"



@interface MineViewController ()<UITableViewDataSource,UITableViewDelegate> {

}
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, strong) UIImageView *bkIV;//拉伸视图

@property (nonatomic, weak) HeadView *headView;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self getUserInformation];
}

- (void)initData {
    
    self.dataArr = [NSMutableArray new];

    NSArray *titles = @[@"我的账户",@"抵金券",@"客户评价",@"我的帖子",@"营运设置",@"消息中心",@"分享885",@"系统设置"];
    
    for (NSInteger i = 0; i < titles.count; i ++) {
        
        MineModel *model = [[MineModel alloc] init];
        
        model.titleName = titles[i];
        model.imgName = [NSString stringWithFormat:@"mine%ld",i+1];
        
        [self.dataArr addObject:model];
    }
}

- (void)getUserInformation {
    
    NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID]};
    [[LYAPIManager sharedInstance] POST:@"/transportion/driver/queryDriverDetail" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            if (NotNilAndNull(result[@"data"])) {
                [self.headView fillMyInformationWith:result[@"data"]];
            }
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) { }];
}

- (void)createViews {
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.view addSubview:self.bkIV];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 50.f) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = self.headView;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tabCell"];
    
    [self.view addSubview:self.tableView];
}

#pragma mark - getter

- (UIImageView *)bkIV {
    
    if (!_bkIV) {
        _bkIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 180.f)];
        _bkIV.image = [UIImage imageNamed:@"bk39"];
    }
    return _bkIV;
}

- (HeadView *)headView {

    if (!_headView) {
        _headView = [[NSBundle mainBundle]loadNibNamed:@"HeadView" owner:nil options:nil].lastObject;
        _headView.frame = CGRectMake(0, 0, kScreenSize.width, 180.f);
        [_headView.headIv addTarget:self action:@selector(editMyInformation:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _headView;
}


#pragma mark - StretchImageView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat yOffSet = scrollView.contentOffset.y;
    
    if (yOffSet < 0.f) {
        
        CGRect frame = self.bkIV.frame;
        frame.origin.x = yOffSet;
        frame.origin.y = yOffSet;
        frame.size.width = kScreenSize.width + fabs(yOffSet)*2;
        frame.size.height = 180.f + fabs(yOffSet)*2;
        self.bkIV.frame = frame;
  
    }else {

        CGRect frame = self.bkIV.frame;
        frame.origin.y = - yOffSet;
        frame.origin.x = 0;
        frame.size.width = kScreenSize.width;
        frame.size.height = 180.f;
        self.bkIV.frame = frame;
    }
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tabCell" forIndexPath:indexPath];
    MineModel *model = [self.dataArr  objectAtIndex:indexPath.section];
    cell.textLabel.text = model.titleName;
    cell.imageView.image = [UIImage imageNamed:model.imgName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 6.f;
}

- (void)editMyInformation:(UIButton *)sender {

    MyVController *myVC = [[MyVController alloc] init];
    myVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myVC animated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    BaseViewController *controller = nil;
    
    if (indexPath.section == 0) {

        controller = [[AccountController alloc] init];
        
    }else if(indexPath.section == 1){
        
        controller = [[CouponVController alloc] init];
     
    }else if (indexPath.section == 2){

        controller = [[CommentsController alloc] init];
        
    }else if (indexPath.section == 3){

        controller = [[PostsViewController alloc] init];

    }else if (indexPath.section == 4){
        
        controller = [[ManageLinesController alloc] init];
        
    }else if (indexPath.section == 5){
        
        controller = [[NewsViewController alloc] init];

    }else if (indexPath.section == 6){

        controller = [[ShareController alloc] init];
        
    }else if (indexPath.section == 7){

        controller = [[SystemSetController alloc] init];
    }
    
    if (NotNilAndNull(controller)) {
        
        [controller addPopItem];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
