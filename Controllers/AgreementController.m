//
//  AgreementController.m
//  CustomFurniture
//
//  Created by Blues on 16/10/19.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "AgreementController.h"

@interface AgreementController ()

@end

@implementation AgreementController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)createViews {
    
    self.navigationItem.title = @"注册协议";
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f)];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:RegisterHtml_Url]];
    [webView loadRequest:request];
    
    [self.view addSubview:webView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
