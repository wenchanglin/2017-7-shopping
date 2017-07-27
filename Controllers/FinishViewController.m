//
//  FinishViewController.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/17.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "FinishViewController.h"

@interface FinishViewController ()
@property (weak, nonatomic) IBOutlet UILabel *msgLb;
@property (weak, nonatomic) IBOutlet UIView *mbk;
@property (weak, nonatomic) IBOutlet UIButton *cancelBt;
@property (weak, nonatomic) IBOutlet UIButton *sureBt;

@end

@implementation FinishViewController


- (instancetype)initWithJsbblock:(JustMsgBackkBlock)block {

    self = [super init];
    if (self) {
        _myBlock = block;
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.mbk.layer.masksToBounds = YES;
    self.mbk.layer.cornerRadius = 5.f;
    self.cancelBt.layer.masksToBounds = YES;
    self.cancelBt.layer.cornerRadius = 18.f;
    self.sureBt.layer.masksToBounds = YES;
    self.sureBt.layer.cornerRadius = 18.f;
    
    if (NotNilAndNull(_msg)) {
        self.msgLb.text = _msg;
    }
}

- (IBAction)sureClicked:(id)sender {

    [self dismissViewControllerAnimated:YES completion:^{
        if (self.myBlock) {
            self.myBlock();
        }
    }];
}

- (IBAction)cancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
