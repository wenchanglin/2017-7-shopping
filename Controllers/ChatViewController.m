//
//  ChatViewController.m
//  885logistics
//
//  Created by Blues on 17/1/11.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "ChatViewController.h"
#import "DetailViewController.h"
#import "AnotherUserController.h"
#import "UserModel.h"

@interface ChatViewController ()

@property (nonatomic, strong) UserModel *usModel;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addPopItem];
    if (NotNilAndNull(_moreDetail)) {
        [self addDetailItem];
    }
    
    
    
    
    
    [self queryUserInformation];
}

- (void)addPopItem {
    
    UIImage *img = [[UIImage imageNamed:@"go_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStyleDone target:self action:@selector(popCurrentView:)];
    self.navigationItem.leftBarButtonItems = @[item];
}

- (void)popCurrentView:(UIBarButtonItem *)item {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)addDetailItem {

    UIImage *img1 = [[UIImage imageNamed:@"nav3"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithImage:img1 style:UIBarButtonItemStyleDone target:self action:@selector(pushCurrentView:)];
    self.navigationItem.rightBarButtonItems = @[item1];
}


//-(void)pluginBoardView:(RCPluginBoardView*)pluginBoardView
//    clickedItemWithTag:(NSInteger)tag {
//
//    if (tag == 2) {
//        NSLog(@"___###___");
//    }
//
//
//}

- (void)queryUserInformation {
    
    NSString *user = self.targetId;
    if (NotNilAndNull(user)) {
        
        NSDictionary *param1 = @{@"uid":user};
        
        [[LYAPIManager sharedInstance] POST:@"transportion/employ/queryEmployDetails" parameters:param1 progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            if ([result[@"errcode"] integerValue] == 0) {
                
                if (NotNilAndNull(result[@"data"])) {
                    NSDictionary *data = result[@"data"];
                    self.usModel = [[UserModel alloc] init];
                    self.usModel.fkUserId = data[@"fkUserId"];
                    if (NotNilAndNull(data[@"userInfoBase"])) {
                        NSDictionary *userInfoBase = data[@"userInfoBase"];
                        self.usModel.userName = userInfoBase[@"userName"];
                        self.navigationItem.title = userInfoBase[@"userName"];
                        self.usModel.roleType = userInfoBase[@"roleType"];
                    }
                }
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
        
        NSDictionary *param2 = @{@"uid":user};
        [[LYAPIManager sharedInstance] POST:@"/transportion/driver/queryDriverDetail" parameters:param2 progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if ([result[@"errcode"] integerValue] == 0) {
                if (NotNilAndNull(result[@"data"])) {
                    NSDictionary *data = result[@"data"];
                    self.usModel = [[UserModel alloc] init];
                    self.usModel.fkUserId = data[@"fkUserId"];
                    if (NotNilAndNull(data[@"userInfoBase"])) {
                        NSDictionary *userInfoBase = data[@"userInfoBase"];
                        self.usModel.userName = userInfoBase[@"userName"];
                        self.navigationItem.title = userInfoBase[@"userName"];
                        self.usModel.roleType = userInfoBase[@"roleType"];
                    }
                }
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) { }];
    }
}


- (void)pushCurrentView:(UIBarButtonItem *)item {
    
    if (!_usModel) {
        return;
    }
    if ([_usModel.fkUserId isEqualToString:[LYHelper getCurrentUserID]]) {
        return;
    }
    
    if ([_usModel.roleType isEqualToString:@"driver"]){
        
        DetailViewController *detail = [[DetailViewController alloc]init];
        [detail addPopItem];
        detail.model = _usModel;
        detail.justBack = @"just";
        [self.navigationController pushViewController:detail animated:YES];
        
    }else {
        
        AnotherUserController *another = [[AnotherUserController alloc] init];
        [another addPopItem];
        another.model = _usModel;
        another.justBack = @"just";
        [self.navigationController pushViewController:another animated:YES];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
