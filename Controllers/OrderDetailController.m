//
//  OrderDetailController.m
//  885logistics
//
//  Created by Blues on 17/1/20.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "OrderDetailController.h"
#import "InsuranceListController.h"
#import "PayViewController.h"
#import "CanCelViewController.h"
#import "FinishViewController.h"
#import "SureViewController.h"
#import "BrokerageController.h"
#import "AnotherUserController.h"
#import "OrderDetailView.h"
#import "OrderModel.h"
#import "OBTCell1.h"
#import "OBTCell2.h"
#import "OBTCell.h"
#import "UserModel.h"


@interface OrderDetailController ()<UIScrollViewDelegate,CanCelViewControllerDelegate,BrokerageControllerDelegate>{

}
@property (nonatomic, strong) UIScrollView *bigScrollView;
@property (nonatomic, weak) OrderDetailView *detailView;
@property (nonatomic, weak) OBTCell     *actionView;
@property (nonatomic, weak) OBTCell1    *cancelView;
@property (nonatomic, weak) OBTCell2    *depositView;
@end

@implementation OrderDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)createViews {
    
     self.navigationItem.title = @"订单详情";
    
    [self cecreateNavItem];
    
    self.bigScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f)];
    self.bigScrollView.delegate = self;
    self.bigScrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.bigScrollView.bounces = YES;
    self.bigScrollView.contentSize = CGSizeMake(0, 1000.f);
    [self.bigScrollView addSubview:self.detailView];
    
    [self.view addSubview:self.bigScrollView];
    
    [self queryDataFromServer];
    
     [self createActionView];
    
    if (NotNilAndNull(_isCancel)) {
        if ([_isCancel isEqualToString:@"YES"]) {
            [self cancelOrder];
        }
    }
    
    if (NotNilAndNull(_end)) {
        if ([_end isEqualToString:@"YES"]) {
            [self finishOrder];
        }
    }
    
    if (NotNilAndNull(_begin)) {
        if ([_begin isEqualToString:@"YES"]) {
            [self startTrans];
        }
    }
    
    if (NotNilAndNull(_isPay)) {
        if ([_isPay isEqualToString:@"YES"]) {
            [self payMoneyForBbw];
        }
    }
}

- (void)cecreateNavItem {
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"查看保单" style:UIBarButtonItemStyleDone target:self action:@selector(checkInsuranceList)];
    item.tintColor = [UIColor whiteColor];
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:14.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[item];
}

- (void)checkInsuranceList {
    
    InsuranceListController *insurance = [[InsuranceListController alloc] init];
    [insurance addPopItem];
    insurance.fkOrderId = _model.fkOrderId;
    [self.navigationController pushViewController:insurance animated:YES];
}

- (OrderDetailView *)detailView {

    if (!_detailView) {
        _detailView = [[NSBundle mainBundle] loadNibNamed:@"OrderDetailView" owner:nil options:nil].lastObject;
        _detailView.frame = CGRectMake(0, 0, kScreenSize.width, 950.f);
        
        if (NotNilAndNull(_model)) {
            [_detailView paddingOrderDetail:_model];
        }
        [_detailView.goBt addTarget:self action:@selector(checkDetail) forControlEvents:UIControlEventTouchUpInside];
        [_detailView.callBt addTarget:self action:@selector(callIt) forControlEvents:UIControlEventTouchUpInside];
        [_detailView.bfBt addTarget:self action:@selector(chatIt) forControlEvents:UIControlEventTouchUpInside];
    }
    return _detailView;
}

- (void)checkDetail {
    
    AnotherUserController *user = [[AnotherUserController alloc] init];
    [user addPopItem];
    UserModel *model = [[UserModel alloc] init];
    model.fkUserId = _model.fkUserId;
    user.model = model;
    [self.navigationController pushViewController:user animated:YES];
}


- (void)callIt {
    
    if (IsEmptyStr(_model.employTel)) {
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:_model.employTel message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *acA = [UIAlertAction actionWithTitle:@"拨打" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *url = [NSString stringWithFormat:@"tel://%@",_model.employTel];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }];
    UIAlertAction *acB = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:acB];
    [alert addAction:acA];
    [self presentViewController:alert animated:YES completion:^{}];
}


- (void)chatIt {

    if ([_model.isFriend integerValue] == 1) {
        [LYAPIManager showMessageForUser:@"你们已经是好友了"];
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加好友" message:@"您需要发送申请，等对方通过" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    UIAlertAction *acA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *textfield = alert.textFields.firstObject;
        NSString *msgtext = textfield.text;
        
        NSDictionary *param = @{@"fkUserId":[LYHelper getCurrentUserID],
                                @"fkDriverId":_model.fkUserId,
                                @"applyIde":@"driver",
                                @"customized":msgtext
                                };
        NSLog(@"______添加好友______%@",param);
        
        [[LYAPIManager sharedInstance] POST:@"transportion/user/addUserFriend" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSString *msg = result[@"msg"];
            if (msg.length) {
                [LYAPIManager showMessageForUser:msg];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        }];
    }];
    UIAlertAction *acB = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:acB];
    [alert addAction:acA];
    [self presentViewController:alert animated:YES completion:^{}];
}


- (void)queryDataFromServer {
    
    if (!_model) {
        return;
    }
    NSDictionary *param = @{@"fkTransId":_model.fkOrderId,
                            @"fkDriverId":[LYHelper getCurrentUserID]
                            };
    [[LYAPIManager sharedInstance] POST:@"transportion/transOrderOffer/queryDriverOfferExit" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            if (NotNilAndNull(result[@"data"])) {
                NSDictionary *data = result[@"data"];
                NSNumber *offer = data[@"offer"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.cancelView.myOffer.text = [NSString stringWithFormat:@"¥%.2f",[offer floatValue]];
                    self.depositView.myOffer.text = [NSString stringWithFormat:@"¥%.2f",[offer floatValue]];
                });
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (OBTCell1 *)cancelView {
    if (!_cancelView) {
        _cancelView = [[NSBundle mainBundle] loadNibNamed:@"OBTCell1" owner:nil options:nil].lastObject;
        _cancelView.frame = CGRectMake(0, kScreenSize.height - 64.f - 45.f, kScreenSize.width, 45.f);
        [_cancelView.cancelBt addTarget:self action:@selector(cancelOrder) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelView;
}

- (OBTCell2 *)depositView {

    if (!_depositView) {
        _depositView = [[NSBundle mainBundle] loadNibNamed:@"OBTCell2" owner:nil options:nil].lastObject;
        _depositView.frame = CGRectMake(0, kScreenSize.height - 64.f - 45.f, kScreenSize.width, 45.f);
        [_depositView.cancelBt addTarget:self action:@selector(cancelOrder) forControlEvents:UIControlEventTouchUpInside];
        [_depositView.deposit addTarget:self action:@selector(payOrder) forControlEvents:UIControlEventTouchUpInside];
    }
    return _depositView;
}

- (void)createActionView {
    
    if (!_model) {
        return;
    }
    NSString *status = _model.status;
    NSLog(@"___%@___",status);
    NSString *leftStr = nil;
    NSString *selectorLeft = nil;
    NSString *rightStr = nil;
    NSString *selectorRight = nil;
    
    if ([status isEqualToString:@"待处理_暂未报价"] || [status isEqualToString:@"待处理_待客户付款"])
    {
        [self.view addSubview:self.cancelView];
    }
    else if ([status isEqualToString:@"待处理_待付保证金"])
    {
        [self.view addSubview:self.depositView];
    }
    else if ([status isEqualToString:@"已关闭"] || [status isEqualToString:@"已完成_已关闭"]||[status isEqualToString:@"已完成"])
    {
        return;
    }else
    {
        self.actionView = [[NSBundle mainBundle] loadNibNamed:@"OBTCell" owner:nil options:nil].lastObject;
        self.actionView.frame = CGRectMake(0, kScreenSize.height - 64.f - 45.f, kScreenSize.width, 45.f);
        if (NotNilAndNull(_model.finalPrice)) {
            self.actionView.moneyLb.text = [NSString stringWithFormat:@"¥%.2f",[_model.finalPrice floatValue]];
        }
        if ([status isEqualToString:@"待运输_待支付投保"] ||[status isEqualToString:@"待运输"])
        {
            leftStr = @"申请取消";
            selectorLeft = @"cancelOrder";
            rightStr = @"开始运输";
            selectorRight = @"startTrans";
        }
        else if ([status isEqualToString:@"运输中"])
        {
            leftStr = @"投诉";
            selectorLeft = @"reportDriver";
            rightStr = @"确认送达";
            selectorRight = @"finishOrder";
        }
        else if ([status isEqualToString:@"运输中_待用户收货"])
        {
            rightStr = @"投诉";
            selectorRight = @"reportDriver";
        }
        else if ([status isEqualToString:@"已完成_待支付佣金"])
        {
            rightStr = @"支付平台佣金";
            selectorRight = @"payMoneyForBbw";
        }

        if (NotNilAndNull(leftStr)) {
            [self.actionView.leftBt setTitle:leftStr forState:UIControlStateNormal];
            if (NotNilAndNull(selectorLeft)) {
                SEL selectorL = NSSelectorFromString(selectorLeft);
                [self.actionView.leftBt addTarget:self action:selectorL forControlEvents:UIControlEventTouchUpInside];
            }
            
        }else {
            self.actionView.leftBt.hidden = YES;
        }
        if (NotNilAndNull(rightStr)) {
            
            [self.actionView.rightBt setTitle:rightStr forState:UIControlStateNormal];
            if (NotNilAndNull(selectorRight)) {
                SEL selectorR = NSSelectorFromString(selectorRight);
                [self.actionView.rightBt addTarget:self action:selectorR forControlEvents:UIControlEventTouchUpInside];
            }
        }else {
            self.actionView.rightBt.hidden = YES;
        }
        [self.view addSubview:self.actionView];
    }
}

#pragma mark - 取消订单
- (void)cancelOrder {
    
    CanCelViewController *cancel = [[CanCelViewController alloc] init];
    cancel.delegate = self;
    cancel.providesPresentationContextTransitionStyle = true;
    cancel.definesPresentationContext = true;
    cancel.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    cancel.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:cancel animated:YES completion:^{}];
}

- (void)cancelOrderWithReason:(NSString *)reason {
    
    NSDictionary *param = @{@"toId":_model.fkOrderId,
                            @"caReId":reason
                            };
    [[LYAPIManager sharedInstance] POST:@"transportion/transOrderInfo/stopTransOrderDriver" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            [LYAPIManager showMessageForUser:@"订单已取消"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else {
            if (NotNilAndNull(result[@"msg"])) {
                NSString *msg = result[@"msg"];
                if (msg.length) {
                    [LYAPIManager showMessageForUser:msg];
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];
}

#pragma mark - 支付保证金
- (void)payOrder {
    
    PayViewController *detail = [[PayViewController alloc] init];
    [detail addPopItem];
    detail.myModel  = _model;
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - 投诉
- (void)reportDriver {
    
    SureViewController *report = [[SureViewController alloc] init];
    [report addPopItem];
    report.myModel = _model;
    [self.navigationController pushViewController:report animated:YES];
}

#pragma mark - 确认送达
- (void)finishOrder {

    FinishViewController *cancel = [[FinishViewController alloc] initWithJsbblock:^{
        
        NSDictionary *param = @{@"toId":_model.fkOrderId,
                                @"status":@"确认送达"
                                };
        [[LYAPIManager sharedInstance] POST:@"transportion/transOrderInfo/updateTransOrderStatus" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if ([result[@"errcode"] integerValue] == 0) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [LYAPIManager showMessageForUser:@"订单更新成功"];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        } failure:nil];
    }];
    cancel.providesPresentationContextTransitionStyle = true;
    cancel.definesPresentationContext = true;
    cancel.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    cancel.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:cancel animated:YES completion:^{}];
}

#pragma mark - 开始运输

- (void)startTrans {
    
    FinishViewController *cancel = [[FinishViewController alloc] initWithJsbblock:^{
        
        NSDictionary *param = @{@"toId":_model.fkOrderId,
                                @"status":@"运输中"
                                };
        [[LYAPIManager sharedInstance] POST:@"transportion/transOrderInfo/updateTransOrderStatus" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if ([result[@"errcode"] integerValue] == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [LYAPIManager showMessageForUser:@"订单更新成功"];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        } failure:nil];
    }];
    cancel.msg = @"请确保运输工作已准备完成,\n确定要开始运输了吗?";
    cancel.providesPresentationContextTransitionStyle = true;
    cancel.definesPresentationContext = true;
    cancel.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    cancel.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:cancel animated:YES completion:nil];
}

#pragma mark - 支付平台佣金
- (void)payMoneyForBbw {
    
    BrokerageController *cancel = [[BrokerageController alloc] init];
    cancel.delegate = self;
    cancel.providesPresentationContextTransitionStyle = true;
    cancel.definesPresentationContext = true;
    cancel.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    cancel.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:cancel animated:YES completion:nil];
}

- (void)payWithCoupon:(NSString *)coupon {
    
    
    if (!_model) {
        return;
    }
    NSDictionary *param = @{@"toId":_model.fkOrderId,
                            @"fkVoucher":coupon
                            };
    
    [[LYAPIManager sharedInstance] POST:@"transportion/transOrderInfo/updateToCharges" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [LYAPIManager showMessageForUser:@"订单更新成功"];
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
