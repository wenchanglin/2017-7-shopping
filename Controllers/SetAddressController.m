//
//  SetAddressController.m
//  CustomFurniture
//
//  Created by Blues on 16/11/3.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "SetAddressController.h"
#import "PickPDTController.h"

#import "AddressModel.h"

@interface SetAddressController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *pdt;
@property (weak, nonatomic) IBOutlet UITextField *address;


@property (nonatomic, strong) NSDictionary *pdtCode;

@property (nonatomic, weak) UIView *perview;

@end

@implementation SetAddressController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)createViews {
    
    [self createNavItmes];
    [self registerNotification];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    if (self.model) {
        self.navigationItem.title = @"编辑地址";
    }else {
        self.navigationItem.title = @"添加地址";
    }
}

- (void)createNavItmes {

    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(sureClicked)];
    right.tintColor = [UIColor whiteColor];
    [right setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[right];
}


- (void)sureClicked {
    
    [self.view endEditing:YES];
    
    NSString *name = self.name.text;
    if (name.length == 0) {
        [self showMessageForUser:@"请填写收件人姓名"];
        return;
    }
    
    NSString *phone = self.phone.text;
    if (phone.length == 0) {
        [self showMessageForUser:@"请填写联系电话"];
        return;
    }
    
    NSString *pdt = self.pdt.text;
    if (pdt.length == 0) {
        [self showMessageForUser:@"请选择所在区域"];
        return;
    }
    
    NSString *detail = self.address.text;
    if (detail.length == 0) {
        [self showMessageForUser:@"请填写详细地址"];
        return;
    }
}



- (IBAction)choosePDT:(UIButton *)sender {
    
    PickPDTController *more = [[PickPDTController alloc]init];

    [more cameSetMy:^(NSDictionary *pdt) {
        [self paddingprovince:pdt];
    }];
    
    if (UIDevice.currentDevice.systemVersion.integerValue >= 8){
        //For iOS 8
        more.providesPresentationContextTransitionStyle = true;
        more.definesPresentationContext = true;
        more.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        more.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }else{
        //For iOS 7
        more.modalPresentationStyle = UIModalPresentationCurrentContext;
        more.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    [self presentViewController:more animated:YES completion:^{}];
}

- (void)paddingprovince:(NSDictionary *)pdt {

    if (pdt) {
        self.pdt.text = pdt[@"pdt"];
        self.pdtCode = pdt;
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
    CGFloat bottom = self.view.bounds.size.height - r.size.height - r.origin.y - 10.f;
    // 如果不会被遮挡，不做处理
    if (bottom >= keyboardRect.size.height) {
        return;
    }else{
        // 得到动画时长
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
