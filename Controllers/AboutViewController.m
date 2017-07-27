//
//  AboutViewController.m
//  885logistics
//
//  Created by Blues on 17/1/11.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)createViews {

    self.navigationItem.title = @"巴巴五物流";
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f)];
    NSURL *url = [NSURL URLWithString:AboutHtml_Url];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}



@end
