//
//  UpdatePSController.m
//  885logistics
//
//  Created by Blues on 17/1/11.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "UpdatePSController.h"

@interface UpdatePSController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *regBt;
@property (weak, nonatomic) IBOutlet UIButton *sureBt;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *verCode;
@property (weak, nonatomic) IBOutlet UITextField *oldPs;
@property (weak, nonatomic) IBOutlet UITextField *nowPs1;
@property (weak, nonatomic) IBOutlet UITextField *nowPs2;
@property (nonatomic, strong) NSTimer               *timer;
@property (nonatomic, weak) UITextField *perview;

@end

@implementation UpdatePSController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)createViews {
    
    self.navigationItem.title = @"修改密码";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self registerNotification];
}


// 获取验证码
- (IBAction)regCodeClicked:(UIButton *)sender {
    
    NSString *telNumber = [self.phone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    // [------ 验证 ------]
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
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];
}

- (void)changeSecondsAction {
    
    static int second = 60;
    
    if (second > 1) {
        
        second--;
        
        NSString *title = [NSString stringWithFormat:@"%ds", second];
        self.regBt.titleLabel.text = title;
        [self.regBt setTitle:title forState:UIControlStateNormal];
        self.regBt.userInteractionEnabled = NO;
        self.regBt.selected = YES;
        
    }else{
        
        [self.timer invalidate];    //停止定时器
        [self.regBt setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.regBt.userInteractionEnabled = YES;
        self.regBt.selected = NO;
        
        second = 60;
    }
}

// 确定
- (IBAction)sureClicked:(UIButton *)sender {

    [self.view endEditing:YES];
    NSString *telNumber = [self.phone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![WUtils checkTelNumber:telNumber]) {
        [self showMessageForUser:@"手机号有误"];
        return;
    }
    NSString *code = [self.verCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (IsEmptyStr(code)) {
        [self showMessageForUser:@"请输入验证码"];
        return;
    }
    NSString *ps1 = [self.oldPs.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *ps2 = [self.nowPs1.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *ps3 = [self.nowPs2.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![WUtils checkPassword:ps2]) {
        [self showMessageForUser:@"新密码格式不正确(6-18位数字和字母组合)"];
        return;
    }
    if (![ps2 isEqualToString:ps3]) {
        [self showMessageForUser:@"两次新密码不一致"];
        return;
    }
    
    NSDictionary *param = @{@"phone":telNumber,
                            @"validCode":code,
                            @"orgPwd":ps1,
                            @"newPwd":ps3
                            };
    [[LYAPIManager sharedInstance] POST:@"transportion/base/updatePwd" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        [LYAPIManager showMessageForUser:result[@"msg"]];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

#pragma mark - UITextFiledDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.perview = textField;
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
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
    // 如果不会被遮挡，不做处理
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
