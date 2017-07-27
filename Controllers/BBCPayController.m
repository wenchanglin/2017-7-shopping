//
//  BBCPayController.m
//  885logistics
//
//  Created by Blues on 17/3/17.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BBCPayController.h"

@interface BBCPayController ()<UIWebViewDelegate>

@end

@implementation BBCPayController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)createViews {
    
    self.navigationItem.title = @"银联在线支付";

    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f)];
    web.delegate = self;
    if (_webUrl) {
        NSURL *url = [NSURL URLWithString:_webUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [web loadRequest:request];
    }
    [self.view addSubview:web];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
