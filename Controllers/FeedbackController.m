//
//  FeedbackController.m
//  CustomFurniture
//
//  Created by Blues on 16/11/14.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "FeedbackController.h"


@interface FeedbackController ()<UITextViewDelegate> {

}

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *msgLb;

@end

@implementation FeedbackController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)createViews {
    
    self.navigationItem.title = @"意见反馈";
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 150.f)];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIView *bk1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 149.f)];
    bk1.backgroundColor = [UIColor whiteColor];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10.f, 0, kScreenSize.width-20.f, 149)];
    self.textView.delegate = self;
    self.textView.returnKeyType = UIReturnKeyDone;
    self.textView.font = [UIFont systemFontOfSize:14.f];
    self.textView.textColor = [UIColor blackColor];
    //self.textView.backgroundColor = [UIColor whiteColor];
    [bk1 addSubview:self.textView];
    
    self.msgLb = [[UILabel alloc] initWithFrame:CGRectMake(10.f , 10.f, kScreenSize.width - 30.f , 20.f)];
    self.msgLb.textColor = [UIColor lightGrayColor];
    self.msgLb.text = @"快来给我们提意见吧...";
    self.msgLb.font = [UIFont systemFontOfSize:14.f];
    
    [bk1 addSubview:self.msgLb];
    
    [view addSubview:bk1];
    [self.view addSubview:view];
    
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(toSubmit:)];
    right.tintColor = [UIColor whiteColor];
    [right setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[right];
}

- (void)toSubmit:(UIBarButtonItem *)sender {
    
    NSString *content = self.textView.text;
    if (content.length == 0) {
        [self showMessageForUser:@"请填写您的意见"];
        return;
    }
    
    NSDictionary *param = @{@"context":content};
    
    [[LYAPIManager sharedInstance] POST:@"transportion/transInfoFeedback/addFeedback" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *msg = result[@"msg"];
        if (msg.length) {
            [LYAPIManager showMessageForUser:msg];
        }
        if ([result[@"errcode"] integerValue] == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }else {
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}




- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.msgLb.text = @"";
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {

    NSString *content = textView.text;
    if (content.length == 0) {
        self.msgLb.text = @"快来给我们提意见吧...";
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
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
