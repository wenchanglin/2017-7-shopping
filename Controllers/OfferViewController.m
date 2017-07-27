//
//  OfferViewController.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/13.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "OfferViewController.h"

@interface OfferViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *mdView;
@property (weak, nonatomic) IBOutlet UITextField *offerTf;
@property (weak, nonatomic) IBOutlet UIView *offerView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBt;
@property (weak, nonatomic) IBOutlet UIButton *sureBt;

@end

@implementation OfferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mdView.layer.masksToBounds = YES;
    self.mdView.layer.cornerRadius = 5.f;
    self.cancelBt.layer.masksToBounds = YES;
    self.cancelBt.layer.cornerRadius = 18.f;
    self.sureBt.layer.masksToBounds = YES;
    self.sureBt.layer.cornerRadius = 18.f;
    self.offerView.layer.masksToBounds = YES;
    self.offerView.layer.cornerRadius = 3.f;
    self.offerView.layer.borderColor = LGrayColor.CGColor;
    self.offerView.layer.borderWidth = 1.f;
    self.view.backgroundColor = [UIColor clearColor];
}


- (IBAction)suerClicked:(id)sender {

    NSString *offer = self.offerTf.text;
    if (IsEmptyStr(offer) && [offer floatValue] < 0.f) {
        [LYAPIManager showMessageForUser:@"请输入有效保价"];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(offerPriceForOrder:)]) {
            [self.delegate offerPriceForOrder:offer];
        }
    }];
    
}

- (IBAction)cancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
