//
//  TBViewController.m
//  CustomFurniture
//
//  Created by Blues on 16/10/8.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "TBViewController.h"
#import "HomeViewController.h"
#import "BBSViewController.h"
#import "MyOrdersController.h"
#import "MineViewController.h"
#import "ChatListViewController.h"
#import "FriendsViewController.h"

@interface TBViewController ()

@end

@implementation TBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createControllers];
}

- (void)createControllers {
    
    [self addChildVc:[[HomeViewController alloc] init] navTitle:nil tabTitle:@"首页" image:@"tab1" selectedImage:@"tab1_press"];
    
    [self addChildVc:[[BBSViewController alloc] init] navTitle:@"885社区" tabTitle:@"885社区" image:@"tab2" selectedImage:@"tab2_press"];
    
    [self addChildVc:[[MyOrdersController alloc] init] navTitle:@"我的订单" tabTitle:@"我的订单" image:@"tab3" selectedImage:@"tab3_press"];
    
    [self addChildVc:[[ChatListViewController alloc] init] navTitle:@"我的好友" tabTitle:@"我的好友" image:@"tab4" selectedImage:@"tab4_press"];
    
    //[self addChildVc:[[FriendsViewController alloc] init] navTitle:@"我的好友" tabTitle:@"我的好友" image:@"tab4" selectedImage:@"tab4_press"];
    
    [self addChildVc:[[MineViewController alloc] init] navTitle:nil tabTitle:@"个人中心" image:@"tab5" selectedImage:@"tab5_press"];
}


- (void)addChildVc:(UIViewController *)childVc navTitle:(NSString *)nTitle tabTitle:(NSString *)tTitle image:(NSString *)image selectedImage:(NSString *)selectedImage {

// 为子控制器包装导航控制器
    UINavigationController *naVc = [[UINavigationController alloc] initWithRootViewController:childVc];
    if (tTitle) {
        childVc.tabBarItem.title = tTitle;
    }
    if (nTitle) {
        childVc.navigationItem.title = nTitle;
    }
// 设置子控制器的tabBarItem图片 title
    childVc.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
// 设置文字的样式
    [childVc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]} forState:UIControlStateNormal];
    [childVc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:MainColor} forState:UIControlStateSelected];
// 这句代码会自动加载主页，消息，发现，我四个控制器的view，但是view要在我们用的时候去提前加载
    
    [self addChildViewController:naVc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
