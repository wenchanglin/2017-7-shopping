//
//  HomeDetailController.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/13.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "HomeDetailController.h"
#import "OfferViewController.h"
#import "HDetailTopView.h"
#import "OrderModel.h"

@interface HomeDetailController ()<UIScrollViewDelegate,OfferViewControllerDelegate>{
    
}
@property (nonatomic, strong) UIScrollView *bigScrollView;
@property (nonatomic, weak) HDetailTopView *detailView;


@end

@implementation HomeDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)createViews {
    
    self.navigationItem.title = @"订单详情";
    
    self.bigScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f)];
    self.bigScrollView.delegate = self;
    self.bigScrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.bigScrollView.bounces = YES;
    self.bigScrollView.contentSize = CGSizeMake(0, 650.f);
    [self.bigScrollView addSubview:self.detailView];
    
    [self.view addSubview:self.bigScrollView];
    
    [self queryDataFromServer];
}

//- (void)isAuditSuccess {
//
//    NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID]};
//    [[LYAPIManager sharedInstance] POST:@"/transportion/driver/queryDriverDetail" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//        if ([result[@"errcode"] integerValue] == 0) {
//            if (NotNilAndNull(result[@"data"])) {
//                NSDictionary *data = result[@"data"];
//                if (NotNilAndNull(data[@"audit"])) {
//                    NSString *via = data[@"audit"];
//                    if (![via isEqualToString:@"SUCCESS"]) {
//                        [self atttentViewShow];
//                    }
//                }
//            }
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) { }];
//}

- (void)queryDataFromServer {
    
    if (!_model){
        return;
    }
    NSDictionary *param = @{@"fkTransId":_model.fkOrderId,
                            @"fkDriverId":[LYHelper getCurrentUserID]
                            };
    
    [[LYAPIManager sharedInstance] POST:@"transportion/transOrderOffer/queryDriverOfferExit" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (NotNilAndNull(result[@"data"])) {
            self.detailView.offerBt.selected = YES;
            self.detailView.offerBt.userInteractionEnabled = NO;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

//- (void)atttentViewShow {
//
//    [_detailView.offerBt addTarget:self action:@selector(showMsg) forControlEvents:UIControlEventTouchUpInside];
//}
//- (void)showMsg {
//    
//    __weak typeof(self) weakSlef = self;
//
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"认证信息未完善,立即去完善?" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *acA = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//           
//            
//            
//            
//        });
//    }];
//    UIAlertAction *acB = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
//    [alert addAction:acB];
//    [alert addAction:acA];
//    [self presentViewController:alert animated:YES completion:^{}];
//
//}
//
//
//- (void)offerClicked {
//    
//
//}


- (HDetailTopView *)detailView {
    
    if (!_detailView) {
        _detailView = [[NSBundle mainBundle] loadNibNamed:@"HDetailTopView" owner:nil options:nil].lastObject;
        _detailView.frame = CGRectMake(0, 0, kScreenSize.width, 650.f);
        if (NotNilAndNull(self.model)) {
            [_detailView updateViewWithHDModel:self.model];
        }
        [_detailView.offerBt addTarget:self action:@selector(offerBtClicked) forControlEvents:UIControlEventTouchUpInside];

    }
    return _detailView;
}

- (void)offerBtClicked {

    OfferViewController *more = [[OfferViewController alloc]init];
    more.delegate = self;
    more.providesPresentationContextTransitionStyle = true;
    more.definesPresentationContext = true;
    more.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    more.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:more animated:YES completion:nil];
}

- (void)offerPriceForOrder:(NSString *)someStr {    
    
    if (!someStr) {
        return;
    }
    NSDictionary *param = @{@"fkTransId":_model.fkOrderId,
                            @"fkDriverId":[LYHelper getCurrentUserID],
                            @"offer":someStr
                            };
    NSLog(@"___报价____%@__",param);
    [[LYAPIManager sharedInstance] POST:@"transportion/transOrderOffer/addTransOrderOffer" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        [LYAPIManager showMessageForUser:result[@"msg"]];
        if ([result[@"errcode"] integerValue] == 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.detailView.offerBt.selected = YES;
                self.detailView.offerBt.userInteractionEnabled = NO;
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
