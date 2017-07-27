//
//  RechargeController.m
//  885logistics
//
//  Created by Blues on 17/1/19.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "RechargeController.h"
#import "BBCPayController.h"

@interface RechargeController ()

@property (weak, nonatomic) IBOutlet UILabel *balanceLb;
@property (weak, nonatomic) IBOutlet UITextField *rechargeTf;
@property (weak, nonatomic) IBOutlet UIButton *sureBt;

@end

@implementation RechargeController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)createViews {
    
    self.navigationItem.title = @"充值";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self postUrlCheckBalance];
}

- (void)postUrlCheckBalance {
    
    NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID]};
    
    [[LYAPIManager sharedInstance] POST:@"transportion/account/queryMyBalance" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        //NSLog(@"_余额__%@",result);
        if ([result[@"errcode"] integerValue] == 0) {
            NSDictionary *data = result[@"data"];
            self.balanceLb.text = [NSString stringWithFormat:@"2.0元"];//[data[@"balance"] floatValue]];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (IBAction)sureClicked:(UIButton *)sender {
    [self.view endEditing:YES];
    
    NSString *recharge = self.rechargeTf.text;
    if ([recharge floatValue] == 0.00) {
        [self showMessageForUser:@"请输入充值金额"];
        return;
    }
    if ([recharge doubleValue] > 2000.00) {
        [self showMessageForUser:@"每次最高充值2000.00元"];
        return;
    }
    
    NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID],
                            @"m":recharge
                            };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[LYAPIManager sharedInstance] POST:@"transportion/account/addAccountMoney" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];

        if ([result[@"errcode"] integerValue] == 0) {
            
            if (NotNilAndNull(result[@"data"])) {
             
                NSString *dataStr = result[@"data"];
                NSLog(@"we:%@",dataStr);
                NSArray *array = [dataStr componentsSeparatedByString:@"\'"];
                if (array.count > 1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        BBCPayController *bbc = [[BBCPayController alloc] init];
                        [bbc addPopItem];
                        bbc.webUrl = [array objectAtIndex:1];
                        [self.navigationController pushViewController:bbc animated:YES];
                    });
                }
            }
        }
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
        
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
