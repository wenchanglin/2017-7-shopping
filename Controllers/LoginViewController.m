//
//  LoginViewController.m
//  CustomFurniture
//
//  Created by Blues on 16/10/19.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "LoginViewController.h"
#import "RecoverViewController.h"
#import "RegisterViewController.h"
#import "TBViewController.h"
#import "CompleteVController.h"

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView         *swBk;
@property (weak, nonatomic) IBOutlet UIButton       *bt1;
@property (weak, nonatomic) IBOutlet UIButton       *bt2;
@property (weak, nonatomic) IBOutlet UITextField    *codetf;
@property (weak, nonatomic) IBOutlet UIButton       *verCodeBt;
@property (weak, nonatomic) IBOutlet UITextField    *psTf;
@property (weak, nonatomic) IBOutlet UITextField    *usTf;
@property (weak, nonatomic) IBOutlet UIView         *bk1;
@property (weak, nonatomic) IBOutlet UIView         *codeBk;
@property (weak, nonatomic) IBOutlet UIView         *psBk;
@property (weak, nonatomic) IBOutlet UIButton       *lgBtn;
@property (weak, nonatomic) IBOutlet UIButton       *rgBtn;
@property (weak, nonatomic) IBOutlet UIButton       *rvBtn;
@property (weak, nonatomic) IBOutlet UIButton       *qqBt;
@property (weak, nonatomic) IBOutlet UIButton       *wxBt;
@property (weak, nonatomic) IBOutlet UILabel        *orLb;
@property (weak, nonatomic) IBOutlet UIView         *btBk;
@property (nonatomic, strong) NSTimer               *timer;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)createViews {
    
    self.bk1.layer.masksToBounds = YES;
    self.bk1.layer.cornerRadius = 3.f;
    self.bk1.layer.borderColor = LGrayColor.CGColor;
    self.bk1.layer.borderWidth = 0.8f;
    
    self.orLb.layer.masksToBounds = YES;
    self.orLb.layer.cornerRadius = 22.5f;
    self.orLb.layer.borderColor = [UIColor whiteColor].CGColor;
    self.orLb.layer.borderWidth = 3.5f;
    [self.btBk bringSubviewToFront:self.orLb];
}

//密码登录
- (IBAction)psLogin:(UIButton *)sender {
    if (sender.isSelected) {
        return;
    }
    sender.selected = YES;
    self.bt2.selected = NO;
    [self showViews:YES];
}


//手机验证码登录
- (IBAction)codeLogin:(UIButton *)sender {
    if (sender.isSelected) {
        return;
    }
    sender.selected = YES;
    self.bt1.selected = NO;
    [self showViews:NO];
}

- (void)showViews:(BOOL)psLogin {

    if (psLogin) {
        self.psBk.hidden = NO;
        self.codeBk.hidden = YES;
        self.rgBtn.hidden = NO;
        self.rvBtn.hidden = NO;
        self.btBk.hidden = NO;
        
    }else {
        self.psBk.hidden = YES;
        self.rgBtn.hidden = YES;
        self.rvBtn.hidden = YES;
        self.btBk.hidden = YES;
        self.codeBk.hidden = NO;
    }
}


- (IBAction)sendValidCode:(UIButton *)sender {
    
    NSString *telNumber = [self.usTf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // [--- 验证 ------]
    if (![WUtils checkTelNumber:telNumber]) {  // 用户名不匹配 进行提示
        [self showMessageForUser:@"手机号格式有误"];
        return;
    }
    [[LYAPIManager sharedInstance] POST:@"transportion/sms/sendPhoneValidCode" parameters:@{@"phone":telNumber} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *msg = dict[@"msg"];
            if (msg.length) {
                [self showMessageForUser:msg];
            }
            if ([dict[@"errcode"] intValue] == 0) {
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeSecondsAction) userInfo:nil repeats:YES];
                self.verCodeBt.userInteractionEnabled = NO;
                self.verCodeBt.selected = YES;
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"sm:%@",error);
    }];
}

- (void)changeSecondsAction {
    
    static int second = 60;
    
    if (second > 1) {
        
        second--;
        
        NSString *title = [NSString stringWithFormat:@"%ds", second];
        self.verCodeBt.titleLabel.text = title;
        [self.verCodeBt setTitle:title forState:UIControlStateNormal];
        
    }else{
        
        [self.timer invalidate];    //停止定时器
        [self.verCodeBt setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.verCodeBt.userInteractionEnabled = YES;
        self.verCodeBt.selected = NO;
        
        second = 60;
    }
}


//找回密码
- (IBAction)recoverClicked:(UIButton *)sender {
    
    RecoverViewController *recover = [[RecoverViewController alloc]init];
    [recover addPopItem];
    [self.navigationController pushViewController:recover animated:YES];
}

//登录
- (IBAction)loginClicked:(UIButton *)sender {
    
    [self.view endEditing:YES];
    
    NSString *telNumber = [self.usTf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.psTf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *validCode = [self.codetf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *urlString = nil;
    NSDictionary *param = nil;
    
    // [--- 验证 ------]
    if (![WUtils checkTelNumber:telNumber]) {
        [self showMessageForUser:@"手机号有误"];
        return;
    }
    
    if (self.bt1.isSelected) {
        if (![WUtils checkPassword:password]) {
            [self showMessageForUser:@"密码格式有误(6~18位数字和字母组合)"];
            return;
        }
        param = @{@"phone":telNumber,
                  @"pwd":password,
                  @"ide":@"driver"
                  };
        urlString = @"transportion/base/checkLogin";
        
    }else {
        
        if (validCode.length == 0) {
            [self showMessageForUser:@"请填写验证码"];
            return;
        }
        param = @{@"phone":telNumber,
                  @"validCode":validCode,
                  @"ide":@"driver"
                  };
        urlString = @"transportion/base/checkLoginValidCode";
    }
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[LYAPIManager sharedInstance] POST:urlString parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"se:%@",result);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSInteger errcode = [result[@"errcode"] integerValue];
//        if (errcode == 0) {
//            
//            if (NotNilAndNull(result[@"data"])) {
//                
//                NSDictionary *data = result[@"data"];
//                NSMutableDictionary *mUser = [data mutableCopy];
//                for (NSString *key in [mUser allKeys]) {
//                    if ([mUser[key] isKindOfClass:NSNull.class]) {
//                        [mUser setObject:@"" forKey:key];
//                    }
//                }
//                [[NSUserDefaults standardUserDefaults] setObject:mUser forKey:@"User"];
//                
//                [LYHelper loginRongCloud];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    TBViewController *tbc = [[TBViewController alloc] init];
//                    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//                    [window setRootViewController:tbc];
//                });
//            }
//        }
        //新加的
        TBViewController *tbc = [[TBViewController alloc] init];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window setRootViewController:tbc];
        //到这
        
        /*
        else if ([result[@"errcode"] integerValue] == 500){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CompleteVController *complete = [[CompleteVController alloc] init];
                [complete addPopItem];
                complete.fkId = result[@"msg"];
                [self.navigationController pushViewController:complete animated:YES];
            });
        }
        */
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"sm%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }];
}


- (IBAction)registerClicked:(UIButton *)sender {
    
    RegisterViewController *recover = [[RegisterViewController alloc]init];
    [recover addPopItem];
    [self.navigationController pushViewController:recover animated:YES];
}

#pragma mark - UITextFieldDelegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
