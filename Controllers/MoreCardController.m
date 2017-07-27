//
//  MoreCardController.m
//  885logistics
//
//  Created by Blues on 17/1/19.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "MoreCardController.h"
#import "BankListController.h"

@interface MoreCardController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *bankName;
@property (weak, nonatomic) IBOutlet UITextField *bankNumber;
@property (weak, nonatomic) IBOutlet UITextField *realName;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *bankOpen;
@property (weak, nonatomic) IBOutlet UITextField *verCode;
@property (weak, nonatomic) IBOutlet UIButton *regBt;
@property (nonatomic, weak) UITextField *perview;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation MoreCardController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)createViews {
    
    [self registerNotification];
    
    self.navigationItem.title = @"添加银行卡";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(moreBankCard)];
    item.tintColor = [UIColor whiteColor];
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[item];
}

- (void)moreBankCard {
    
    [self.view endEditing:YES];
    
    NSString *bankName = self.bankName.text;
    if (IsEmptyStr(bankName)) {
        [self showMessageForUser:@"请选择银行"];
        return;
    }
    
    NSString *bankNumber = self.bankNumber.text;
    if (IsEmptyStr(bankNumber)) {
        [self showMessageForUser:@"请输入银行卡号"];
        return;
    }
    if (![WUtils isBankCard:bankNumber]) {
        [self showMessageForUser:@"银行卡号有误"];
        return;
    }
    NSString *realName = self.realName.text;
    if (IsEmptyStr(realName)) {
        [self showMessageForUser:@"请输入真实姓名"];
        return;
    }
    
    NSString *bankOpen = self.bankOpen.text;
    if (IsEmptyStr(bankOpen)) {
        [self showMessageForUser:@"请输入开户行"];
        return;
    }
    
    NSString *phone = self.phone.text;
    if (IsEmptyStr(phone)) {
        [self showMessageForUser:@"请输入手机号"];
        return;
    }
    
    NSString *verCode = self.verCode.text;
    if (IsEmptyStr(verCode)) {
        [self showMessageForUser:@"请输入验证码"];
        return;
    }
    
    NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID],
                            @"cardType":bankName,
                            @"cardNum":bankNumber,
                            @"bankOwner":realName,
                            @"tel":phone,
                            @"bankOpen":bankOpen,
                            @"validCode":verCode
                            };
    
    [[LYAPIManager sharedInstance] POST:@"transportion/bank/addBankCard" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *msg = result[@"msg"];
        if (msg.length) {
            [LYAPIManager showMessageForUser:msg];
        }
        if ([result[@"errcode"] integerValue] == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (IBAction)bankChoose:(UIButton *)sender {
    
    __weak typeof(self) weakSelf = self;
    BankListController *more = [[BankListController alloc]init];
    [more cameGetMy:^(NSString *str) {
        weakSelf.bankName.text = str;
    }];
    more.providesPresentationContextTransitionStyle = true;
    more.definesPresentationContext = true;
    more.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    more.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:more animated:YES completion:nil];
}


- (IBAction)regClicked:(UIButton *)sender {

    NSString *telNumber = [self.phone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![WUtils checkTelNumber:telNumber]) {
        [LYAPIManager showMessageForUser:@"手机号格式有误"];
        return;
    }
    [[LYAPIManager sharedInstance] POST:@"transportion/sms/sendPhoneValidCode" parameters:@{@"phone":telNumber} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *msg = dict[@"msg"];
            if (msg.length) {
                [LYAPIManager showMessageForUser:msg];
            }
            if ([dict[@"errcode"] intValue] == 0) {
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeSecondsAction) userInfo:nil repeats:YES];
                self.regBt.userInteractionEnabled = NO;
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)changeSecondsAction {
    
    static int second = 60;
    if (second > 1) {
        
        second--;
        
        self.regBt.userInteractionEnabled = NO;
        NSString *title = [NSString stringWithFormat:@"%ds", second];
        self.regBt.titleLabel.text = title;
        [self.regBt setTitle:title forState:UIControlStateNormal];
        
    }else{
        
        [self.timer invalidate];    //停止定时器
        [self.regBt setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.regBt.userInteractionEnabled = YES;
        
        second = 60;
    }
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
    [self.perview endEditing:YES];
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
