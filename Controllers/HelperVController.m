//
//  HelperVController.m
//  CustomFurniture
//
//  Created by Blues on 16/10/18.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "HelperVController.h"

@interface HelperVController ()

@end

@implementation HelperVController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)createViews {
    self.navigationItem.title = @"客服热线";
}

//咨询客服
- (IBAction)telClicked:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"联系客服" message:@"拨打热线:4008716885" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *acA = [UIAlertAction actionWithTitle:@"拨打" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://4006617885"]];
    }];
    UIAlertAction *acB = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:acA];
    [alert addAction:acB];
    [self presentViewController:alert animated:YES completion:^{}];


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
