//
//  DrawViewController.m
//  CustomFurniture
//
//  Created by Blues on 16/11/15.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "DrawViewController.h"
#import "BankListController.h"
#import "HaveCardsController.h"
#import "DrawTopView.h"
#import "DrawBView.h"
#import "BCardsModel.h"


@interface DrawViewController ()<UITextFieldDelegate,HaveCardsControllerDelegate> {

}
@property (nonatomic, weak) DrawTopView *topView;
@property (nonatomic, weak) DrawBView *bankView;
@property (nonatomic, strong) UIButton *sureBtn;
@property (nonatomic, weak) UIView *perview;
@property (nonatomic, strong) NSString *bankName;

@end

@implementation DrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initData {
    
    NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID]};
    
    [[LYAPIManager sharedInstance] POST:@"transportion/account/queryMyBalance" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            if (NotNilAndNull(result[@"data"])) {
                NSDictionary *data = result[@"data"];
                self.topView.moneyLb.text = [NSString stringWithFormat:@"¥%.2f",[data[@"balance"] floatValue]];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

}

- (void)createViews {
    
    self.navigationItem.title = @"提现";
    
    [self registerNotification];
    
    self.view.frame = CGRectMake(0, 64.f, kScreenSize.width, kScreenSize.height - 64.f);

    [self.view addSubview:self.topView];
    
    [self.view addSubview:self.bankView];
    
    [self.view addSubview:self.sureBtn];
    
}

- (UIButton *)sureBtn {
    
    CGFloat height1 = (kScreenSize.height - 350.f - 64.f - 32.f)/2.f;
    CGFloat height = 350.f + height1;
    
    if (!_sureBtn) {
        _sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(40.f, height, kScreenSize.width - 80.f, 32.f)];
        [_sureBtn setBackgroundImage:[UIImage imageNamed:@"navtitle"] forState:UIControlStateNormal];
        [_sureBtn setTitle:@"确定提现" forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sureBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
        [_sureBtn addTarget:self action:@selector(drawCash:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}



- (void)drawCash:(UIButton *)sender {
    
    NSString *bankName = self.bankView.bankLb.text;
    if (bankName.length == 0) {
        [self showMessageForUser:@"请选择提现银行"];
        return;
    }
    NSString *bankNum = self.bankView.bankNumTf.text;
    if (bankNum.length == 0) {
        [self showMessageForUser:@"请填写银行卡号"];
        return;
    }
    
    NSString *carkName = self.bankView.cardNameTf.text;
    if (carkName.length == 0) {
        [self showMessageForUser:@"请填写银行卡持有人姓名"];
        return;
    }
    
    NSString *bankWhere = self.bankView.bankNameTf.text;
    if (bankWhere.length == 0) {
        [self showMessageForUser:@"请填写开户行"];
        return;
    }
    
    NSString *phone = self.bankView.phoneTf.text;
    
    if (phone.length == 0) {
        [self showMessageForUser:@"请输入您的联系方式"];
        return;
    }
    
    NSString *much = self.bankView.muchTf.text;
    if (much.length == 0) {
        return;
    }
    NSArray *muchS = [much componentsSeparatedByString:@"."];
    if (muchS.count > 2) {
        [self showMessageForUser:@"请输入有效的提现金额"];
        NSLog(@"##");
        return;
    }
    
    if ([much floatValue] <= 0.00) {
        [self showMessageForUser:@"请输入有效的提现金额"];
        NSLog(@"++");
        return;
    }
    NSString *point = [much substringToIndex:1];
    if ([point isEqualToString:@"."]) {
        [self showMessageForUser:@"请输入有效的提现金额"];
        NSLog(@"__");
        return;
    }
    
    NSDictionary *param1 = @{@"uid":[LYHelper getCurrentUserID],
                             @"cardType":bankName,
                             @"cardNum":bankNum,
                             @"bankOwner":carkName,
                             @"bankOpen":bankWhere,
                             @"m":much
                             };
    NSLog(@"_______%@",param1);
    [[LYAPIManager sharedInstance] POST:@"transportion/account/fallAccountMoney" parameters:param1 progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        [LYAPIManager  showMessageForUser:result[@"msg"]];
        if ([result[@"errcode"] integerValue] == 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (DrawTopView *)topView {

    if (!_topView) {
        _topView = [[NSBundle mainBundle] loadNibNamed:@"DrawTopView" owner:nil options:nil].lastObject;
        _topView.frame = CGRectMake(0, 0.f, kScreenSize.width, 50.f);
    }
    return _topView;
}

- (DrawBView *)bankView {

    if (!_bankView) {
        _bankView = [[NSBundle mainBundle] loadNibNamed:@"DrawBView" owner:nil options:nil].lastObject;
        _bankView.frame = CGRectMake(0, 50.f, kScreenSize.width, 310.f);
        _bankView.bankNumTf.delegate = self;
        _bankView.cardNameTf.delegate = self;
        _bankView.bankNameTf.delegate = self;
        _bankView.muchTf.delegate = self;
        _bankView.phoneTf.delegate = self;
        [_bankView.chooseBt addTarget:self action:@selector(toChooseBank:) forControlEvents:UIControlEventTouchUpInside];
        [_bankView.bt1 addTarget:self action:@selector(chooseHaveCard) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bankView;
}

// 选择银行
- (void)toChooseBank:(UIButton *)sender {
    [self.view endEditing:YES];


    __weak typeof(self) weakSelf = self;
    BankListController *more = [[BankListController alloc]init];
    [more cameGetMy:^(NSString *str) {
        weakSelf.bankView.bankLb.text = str;
    }];
    more.providesPresentationContextTransitionStyle = true;
    more.definesPresentationContext = true;
    more.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    more.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:more animated:YES completion:nil];
}


- (void)chooseHaveCard {
    [self.view endEditing:YES];

    HaveCardsController *have = [[HaveCardsController alloc]init];
    have.delegate = self;
    [have addPopItem];
    [self.navigationController pushViewController:have animated:YES];
}

- (void)updateLastController:(BCardsModel *)model {

    if (!model) {
        return;
    }
    self.bankView.bankLb.text = model.cardType;
    self.bankView.bankNumTf.text = model.cardNum;
    self.bankView.bankNameTf.text = model.bankOpen;
    self.bankView.cardNameTf.text = model.bankOwner;
    self.bankView.phoneTf.text = model.tel;
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
            self.sureBtn.hidden = YES;
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
        self.sureBtn.hidden = NO;
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
