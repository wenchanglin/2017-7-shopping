//
//  RecoverViewController.m
//  CustomFurniture
//
//  Created by Blues on 16/10/19.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "RecoverViewController.h"

@interface RecoverViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *bkView;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *regCode;
@property (weak, nonatomic) IBOutlet UITextField *ps1;
@property (weak, nonatomic) IBOutlet UITextField *ps2;
@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIButton *regBtn;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (nonatomic, weak) UITextField *perview;

@end

@implementation RecoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
- (void)createViews {
    
    [self registerNotification];
    self.navigationItem.title = @"密码找回";
    self.bkView.layer.masksToBounds = YES;
    self.bkView.layer.cornerRadius = 3.f;
    self.bkView.layer.borderColor = LGrayColor.CGColor;
    self.bkView.layer.borderWidth = 0.8f;
}

- (IBAction)regCodeClicked:(UIButton *)sender {
    
    NSString *telNumber = [self.phone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // [--- 验证 ------]
    if (![WUtils checkTelNumber:telNumber]) {
        [LYAPIManager showMessageForUser:@"手机号格式有误"];
        return;
    }
    [[LYAPIManager sharedInstance] POST:@"transportion/sms/sendPhoneValidCode" parameters:@{@"phone":telNumber} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            [LYAPIManager showMessageForUser:result[@"msg"]];
            
            if ([result[@"errcode"] integerValue] == 0) {
                
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeSecondsAction) userInfo:nil repeats:YES];
                self.regBtn.userInteractionEnabled = NO;
                self.regBtn.selected = YES;
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) { }];
}

- (void)changeSecondsAction {
    
    static int second = 60;
    if (second > 1) {
        
        second--;
        
        NSString *title = [NSString stringWithFormat:@"%ds", second];
        self.regBtn.titleLabel.text = title;
        [self.regBtn setTitle:title forState:UIControlStateNormal];
        
    }else{
        
        [self.timer invalidate];    //停止定时器
        self.timer = nil;
        [self.regBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.regBtn.enabled = YES;
        self.regBtn.userInteractionEnabled = YES;
        self.regBtn.selected = NO;
        second = 60;
    }
}

//确定
- (IBAction)sureClicked:(UIButton *)sender {
    
    NSString *telNumber = [self.phone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password1 = [self.ps1.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password2 = [self.ps2.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *verificationCode = [self.regCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (![WUtils checkTelNumber:telNumber]) {         // 用户名不匹配 进行提示
        [self showMessageForUser:@"手机号格式有误！"];
        return;
    }
    
    if (![WUtils checkPassword:password1]) {         // 密码格式不匹配， 进行提示
        [self showMessageForUser:@"密码格式有误(6~18位数字和字母组合)"];
        return;
    }
    
    if (![password1 isEqualToString:password2]) {
        [self showMessageForUser:@"两次密码输入不一致"];
        return;
    }
    
    if (verificationCode.length == 0) {
        [self showMessageForUser:@"请输入验证码"];
        return;
    }
    
    NSDictionary *param = @{@"phone":telNumber,
                            @"newPwd":password1,
                            @"validCode":verificationCode,
                            };
    
    [[LYAPIManager sharedInstance] POST:@"transportion/base/forgetPwd" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (NotNilAndNull(result[@"msg"])) {
            NSString *msg = result[@"msg"];
            if (msg.length) {
                [LYAPIManager showMessageForUser:msg];
            }
        }
        if ([result[@"errcode"] integerValue] == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    
    }];
}

#pragma mark - UITextFiledDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.perview = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.perview endEditing:YES];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)registerNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)keyboardWillShow:(NSNotification *) notification{
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGRect r = [self.perview.superview convertRect:self.perview.frame toView:self.view];
    CGFloat bottom = self.view.bounds.size.height - r.size.height - r.origin.y - 55.f;
    if (bottom < keyboardRect.size.height) {
        NSString *animationDurationString = userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration = [animationDurationString doubleValue];
        [UIView animateWithDuration:animationDuration animations:^{
            self.view.frame = CGRectMake(0, bottom - keyboardRect.size.height , kScreenSize.width, kScreenSize.height - 64.f);
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *) notification {
    
    NSDictionary *userInfo = notification.userInfo;
    NSValue *animatinDurationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animatinDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration animations:^{
        self.view.frame = CGRectMake(0, 64.f, kScreenSize.width, kScreenSize.height - 64.f);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
