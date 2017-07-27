//
//  SystemSetController.m
//  885logistics
//
//  Created by Blues on 17/1/10.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "SystemSetController.h"
#import "UpdatePSController.h"
#import "AboutViewController.h"
#import "GuideViewController.h"
#import "FeedbackController.h"
#import "HelperVController.h"
#import "HelperController.h"

#import "LoginViewController.h"


@interface SystemSetController ()<UITableViewDelegate,UITableViewDataSource> {
    
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *footer;

@property (nonatomic, strong) NSArray *titlesArr;

@property (nonatomic, strong) NSArray *imgsArr;


@end

@implementation SystemSetController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}



- (void)initData {
    
    self.titlesArr = @[@"修改密码",@"关于885",@"运货指南",@"意见反馈",@"客服热线",@"使用帮助"];
    
    self.imgsArr = @[@"system1",@"system2",@"system3",@"system4",@"system5",@"system6"];
}



- (void)createViews {
    
    self.navigationItem.title = @"我的帖子";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = self.footer;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tabCell"];
    
    [self.view addSubview:self.tableView];
}



- (UIView *)footer {

    if (!_footer) {
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 50)];
        _footer.backgroundColor = [UIColor whiteColor];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 50)];
        [btn setTitle:@"退出登录" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
        [btn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(loginOut:) forControlEvents:UIControlEventTouchUpInside];
        
        [_footer addSubview:btn];
    }
    return _footer;

}

- (void)loginOut:(UIButton *)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认退出?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"User"];
        
        LoginViewController *login = [[LoginViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:login];
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window setRootViewController:nav];
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:sure];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titlesArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tabCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.titlesArr objectAtIndex:indexPath.section];
    NSString *imgName = [self.imgsArr objectAtIndex:indexPath.section];
    cell.imageView.image = [UIImage imageNamed:imgName];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 6.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 5) {
        return 10.f;
    }
    return 0.01f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    BaseViewController *controller = nil;
    if (indexPath.section == 0) {
        
        controller = [[UpdatePSController alloc]init];
        
    }else if (indexPath.section == 1){
    
        controller = [[AboutViewController alloc] init];
        
    }else if (indexPath.section == 2){
    
        controller = [[GuideViewController alloc] init];
        
    }else if (indexPath.section == 3){
    
        controller = [[FeedbackController alloc] init];
    
    }else if (indexPath.section == 4){
    
        controller = [[HelperVController alloc] init];
        
    }else if (indexPath.section == 5){
    
        controller = [[HelperController alloc] init];
    }
    
    if (NotNilAndNull(controller)) {
        
        [controller addPopItem];
        [self.navigationController pushViewController:controller animated:YES];
    }
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
