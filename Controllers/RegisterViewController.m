//
//  RegisterViewController.m
//  CustomFurniture
//
//  Created by Blues on 16/10/19.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "RegisterViewController.h"
#import "AgreementController.h"
#import <CoreLocation/CoreLocation.h>
#import "CompleteVController.h"


@interface RegisterViewController ()<UITextFieldDelegate,CLLocationManagerDelegate> {
    
    CLLocationManager *_locationManager;
}

@property (weak, nonatomic) IBOutlet UIView         *bkView;
@property (weak, nonatomic) IBOutlet UITextField    *phone;
@property (weak, nonatomic) IBOutlet UITextField    *regCode;
@property (weak, nonatomic) IBOutlet UITextField    *ps;
@property (weak, nonatomic) IBOutlet UIButton       *regBtn;
@property (weak, nonatomic) IBOutlet UIButton       *agreeBtn;
@property (weak, nonatomic) IBOutlet UIButton       *proBtn;
@property (weak, nonatomic) IBOutlet UIButton       *registerBtn;

@property (nonatomic, weak)   UITextField           *perview;
@property (nonatomic, strong) NSTimer               *timer;
@property (nonatomic, assign) BOOL                  isLocation;
@property (nonatomic, strong) NSString              *province;
@property (nonatomic, strong) NSString              *city;
@property (nonatomic, strong) NSString              *area;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)initData {
    
    self.isLocation = YES;
    [self initializeLocationService];
}

- (void)createViews {
    
    self.navigationItem.title = @"注册";
    [self registerNotification];
    
    self.bkView.layer.masksToBounds = YES;
    self.bkView.layer.cornerRadius = 3.f;
    self.bkView.layer.borderColor = LGrayColor.CGColor;
    self.bkView.layer.borderWidth = 0.8f;
}

- (void)initializeLocationService {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager startUpdatingLocation];
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    if (self.isLocation && newLocation) {
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error){
            if (array.count){
                CLPlacemark *placemark = [array objectAtIndex:0];
                NSString *city = placemark.locality;
                if (!city) {
                    city = placemark.administrativeArea;
                }
                self.city = city;
                self.province = placemark.administrativeArea;
                self.area = placemark.subLocality;
            }else {
                [self showMessageForUser:@"获取不到您的位置信息,暂不能注册"];
            }
        }];
        [manager stopUpdatingLocation];
        self.isLocation = NO;
    }
}

//获取验证码
- (IBAction)regCodeClicked:(UIButton *)sender {
    
    NSString *telNumber = [self.phone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![WUtils checkTelNumber:telNumber]) {  // 用户名不匹配 进行提示
        [self showMessageForUser:@"手机号格式有误"];
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
        
        [self.regBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        self.regBtn.userInteractionEnabled = YES;
        self.regBtn.selected = NO;
        
        second = 60;
    }
}

- (IBAction)agreeClicked:(UIButton *)sender {
    [self.perview endEditing:YES];
    sender.selected = !sender.selected;
}

- (IBAction)checkProtocalCilcked:(UIButton *)sender {

    AgreementController *agree = [[AgreementController alloc] init];
    [agree addPopItem];
    [self.navigationController pushViewController:agree animated:YES];
}

- (IBAction)registerClicked:(UIButton *)sender {
    
    [self.perview endEditing:YES];
    
    NSString *telNumber = [self.phone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.ps.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *verificationCode = [self.regCode.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![WUtils checkTelNumber:telNumber]) {
        [self showMessageForUser:@"手机号格式有误"];
        return;
    }
    
    if (![WUtils checkPassword:password]) {
        [self showMessageForUser:@"密码格式有误(6~18位数字、字母组合)"];
        return;
    }
    
    if ([verificationCode length] == 0) {
        [self showMessageForUser:@"请填写验证码"];
        return;
    }
    if (!self.agreeBtn.selected) {
        [self showMessageForUser:@"请查看用户协议并同意"];
        return;
    }
    
    if (IsNilOrNull(self.province) || IsNilOrNull(self.city) || IsNilOrNull(self.area)) {
        [self showMessageForUser:@"获取不到您的位置信息,暂不能注册"];
        return;
    }
    
    sender.userInteractionEnabled = NO;

    NSDictionary *param = @{@"phone":telNumber,
                            @"validCode":verificationCode,
                            @"pwd":password,
                            @"roleType":@"driver",
                            @"p":self.province,
                            @"c":self.city,
                            @"a":self.area
                            };
    
    [[LYAPIManager sharedInstance] POST:@"transportion/base/register" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"___%@__",result);
        
        NSString *msg = result[@"msg"];
        if (msg.length) {
            [LYAPIManager showMessageForUser:msg];
        }
        self.registerBtn.userInteractionEnabled = YES;
        if ([result[@"errcode"] integerValue] == 0) {
            
            if (NotNilAndNull(result[@"data"])) {
                
                NSDictionary *data = result[@"data"];
                
                dispatch_async(dispatch_get_main_queue(), ^{

                    CompleteVController *complete = [[CompleteVController alloc] init];
                    [complete addPopItem];
                    complete.fkId = data[@"id"];
                    [self.navigationController pushViewController:complete animated:YES];
                });
            }
        }
    } failure:nil];
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
    CGFloat bottom = self.view.bounds.size.height - r.size.height - r.origin.y - 10.f;
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
