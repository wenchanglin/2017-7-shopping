//
//  PayViewController.m
//  885logistics
//
//  Created by Blues on 17/3/1.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "PayViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "BBCPayController.h"
#import "CouponModel.h"
#import "OrderModel.h"
#import "CouponTCell.h"
#import "PayHeader.h"
#import "WXApi.h"



@interface PayViewController ()<UITableViewDelegate,UITableViewDataSource> {

//  300 余额  301 建行 302 支付宝  303 微信支付
    NSInteger _payType;
    NSString *_fkVoucher;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) PayHeader *header;
@property (nonatomic, strong) UIView *footer;
@property (nonatomic, strong) NSMutableArray *dataArr;


@end

@implementation PayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     _payType = 0;
    _fkVoucher = @"";
    
    if (_myModel) {
        self.header.payMoney.text = [NSString stringWithFormat:@"%.2f",[_myModel.offer floatValue]];
        [self queryCouponsFromServer];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WXPay" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    NSNotificationCenter *not = [NSNotificationCenter defaultCenter];
    [not addObserver:self selector:@selector(weixinPayOK:) name:@"WXPay" object:nil];
}

- (void)weixinPayOK:(NSNotification *)notfc {
    if ([notfc.object isEqualToString:@"success"]) {
        [LYAPIManager showMessageForUser:@"微信支付成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)createViews {

    self.navigationItem.title = @"支付保证金";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = self.header;
    self.tableView.tableFooterView = self.footer;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CouponTCell" bundle:nil] forCellReuseIdentifier:@"CouponTCell"];
    [self.view addSubview:self.tableView];
}

#pragma mark - PayOrder
- (void)beforePayCliked:(UIButton *)sender {
    
    if (sender.isSelected){
    }else {
        for (NSInteger i = 300; i < 304; i ++) {
            UIButton *btn = [self.header viewWithTag:i];
            if (i == sender.tag) {
                btn.selected = YES;
            }else {
                btn.selected = NO;
            }
        }
    }
    _payType = sender.tag;
}

- (void)payOffer:(UIButton *)sender {

    NSInteger which = _payType;
    if (which == 300)
    {
        [self balancePay];
    }
    else if (which == 301)
    {
        [self ccbPay];
    }
    else if (which == 302)
    {
        [self aliPay];
    
    }
    else if (which == 303)
    {// 微信支付
        [self weixinPay];
    }
}


#pragma mark - 余额支付
- (void)balancePay {

    if (!_myModel) {
        return;
    }
    NSDictionary *param = @{@"toId":_myModel.fkOrderId,
                            @"fkVoucher":_fkVoucher
                            };
    [[LYAPIManager sharedInstance] POST:@"transportion/transOrderInfo/upateTransOrder" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        [LYAPIManager showMessageForUser:result[@"msg"]];
        if ([result[@"errcode"] integerValue] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


#pragma mark - 建行支付
- (void)ccbPay {
    
    if (!_myModel) {
        return;
    }
    NSDictionary *before = @{@"toId":_myModel.fkOrderId,
                             @"fkDriverId":_myModel.fkDriverId,
                             @"offer":_myModel.offer,
                             @"fkVoucher":_fkVoucher,
                             };
    NSLog(@"___%@___",before);
    [[LYAPIManager sharedInstance] POST:@"transportion/transOrderInfo/addToPay" parameters:before progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"___%@___",result);
        if ([result[@"errcode"] integerValue] == 0) {
            if (NotNilAndNull(result[@"data"])) {
                [self createOrderUrlWithNumber:result[@"data"]];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"_____%@",error);
    }];
}

- (void)createOrderUrlWithNumber:(NSNumber *)number {
    
    if (IsNilOrNull(number)) {
        return;
    }
    NSDictionary *param = @{@"oid":_myModel.fkOrderId,
                            @"m":number,
                            };
    NSLog(@"___%@____",param);
    
    [[LYAPIManager sharedInstance] POST:@"transportion/ccb/b2cSendOrder" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            
            NSLog(@"___%@",result);
            
            if (NotNilAndNull(result[@"data"])) {
                NSString *dataStr = result[@"data"];
                NSArray *array = [dataStr componentsSeparatedByString:@"\'"];
                if (array.count > 2) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        BBCPayController *bbc = [[BBCPayController alloc] init];
                        [bbc addPopItem];
                        bbc.webUrl = [array objectAtIndex:1];
                        [self.navigationController pushViewController:bbc animated:YES];
                    });
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)aliPay {

    
}


- (void)weixinPay {
    
    NSDictionary *param = nil;
    if (NotNilAndNull(_myModel)) {
        param = @{@"orderId":_myModel.fkOrderId,
                  @"fkVoucherId":_fkVoucher
                  };
    }
    if (NotNilAndNull(param)) {
        
        [[LYAPIManager sharedInstance] POST:@"transportion/wechatPay2/payOrder" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"______%@___",result);
            if ([result[@"errcode"] integerValue] == 0) {
                [self wxpayWithServerDict:result[@"data"]];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) { }];
    }
}


- (void)wxpayWithServerDict:(NSDictionary *)dict {

    if (![WXApi isWXAppInstalled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请安装微信" delegate:self cancelButtonTitle:@"确定"otherButtonTitles:nil];
        [alert show];
        return;
    }else if (![WXApi isWXAppSupportApi]){
        //NSLog(@"不支持微信支付");
        return;
    }
    
    NSString    *time_stamp, *nonce_str;
    //设置支付参数
    time_t now;
    time(&now);
    time_stamp  = [NSString stringWithFormat:@"%ld", now];
    nonce_str	= [self md5:time_stamp];
    
    //第二次签名参数列表
    NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
    [signParams setObject:@"wxc8f1d1336cec8b0b" forKey:@"appid"];
    [signParams setObject:@"Sign=WXPay"      forKey:@"package"];
    [signParams setObject:@""        forKey:@"partnerid"];//就不告诉你，就不告诉你
    
    [signParams setObject:nonce_str    forKey:@"noncestr"];
    [signParams setObject:time_stamp   forKey:@"timestamp"];
    
    [signParams setObject:dict[@"prepayId"]     forKey:@"prepayid"];
    
    //生成签名
    NSString *sign = [self createMd5Sign:signParams];
    
    //添加签名
    [signParams setObject:sign         forKey:@"sign"];
    
    NSLog(@"____%@",sign);
    
    //调起微信支付
    PayReq* req             = [[PayReq alloc] init];
    req.openID              = [signParams objectForKey:@"appid"];
    req.partnerId           = [signParams objectForKey:@"partnerid"];
    req.prepayId            = signParams[@"prepayid"];
    req.nonceStr            = [signParams objectForKey:@"noncestr"];
    req.timeStamp           = time_stamp.intValue;
    req.package             = [signParams objectForKey:@"package"];
    req.sign                = [signParams objectForKey:@"sign"];
    
    if ([WXApi sendReq:req]) {
        [self showMessageForUser:@"请求微信支付"];
    }else{
        [self showMessageForUser:@"处理失败"];
    }
}

- (NSString*)createMd5Sign:(NSMutableDictionary*)dict {
    
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
    }
    //添加key字段
    [contentString appendFormat:@"key=%@", @"zjbabawu885zjbabawu885zjbabawu88"];
    //得到MD5 sign签名
    NSString *md5Sign =[self md5:contentString];
    
    //输出Debug Info
    return md5Sign;
}

- (NSString *)md5:(NSString *)str {
    
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02X", digest[i]];
    
    return output;
}


- (void)queryCouponsFromServer {
    
    self.dataArr = [[NSMutableArray alloc] init];
    NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID]};
    
    [[LYAPIManager sharedInstance] POST:@"transportion/userSVoucher/querySVoucherAll" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            
            NSDictionary *data = result[@"data"];
            if (NotNilAndNull(data[@"iData"])) {
                NSArray *iData = data[@"iData"];
                
                for (NSDictionary *coupon in iData) {
                    
                    CouponModel *model = [[CouponModel alloc] init];
                    model.isNow = @"0";
                    model.fkCouponId = coupon[@"id"];
                    [model setValuesForKeysWithDictionary:coupon];
                    
                    if (NotNilAndNull(coupon[@"voucher"])) {
                        NSDictionary *voucher = coupon[@"voucher"];
                        [model setValuesForKeysWithDictionary:voucher];
                    }
                    if ([_myModel.offer compare:model.useRequire] == NSOrderedAscending) {
                        continue;
                    }
                    [self.dataArr addObject:model];
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CouponTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CouponTCell" forIndexPath:indexPath];
    CouponModel *model = [self.dataArr objectAtIndex:indexPath.row];
    cell.couponName.text = model.voucherName;
    cell.muchLb.text = [model.amounts stringValue];
    cell.limitDate.text = [NSString stringWithFormat:@"有效期至%@",model.term];
    cell.otherLb.text = [NSString stringWithFormat:@"%.2f",[model.useRequire floatValue]];
    if ([model.isNow integerValue] == 1) {
        cell.imgBt.selected = YES;
    }else {
        cell.imgBt.selected = NO;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kScreenSize.width/3.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CouponTCell *cell = [tableView  cellForRowAtIndexPath:indexPath];
    CouponModel *model = [self.dataArr objectAtIndex:indexPath.row];
    cell.imgBt.selected = !cell.imgBt.selected;
    if (cell.imgBt.isSelected) {
        cell.imgBt.selected = YES;
        model.isNow = @"1";
        _fkVoucher = model.fkCouponId;
    }else {
        cell.imgBt.selected = NO;
        model.isNow = @"0";
        _fkVoucher = @"";
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CouponTCell *cell = [tableView  cellForRowAtIndexPath:indexPath];
    CouponModel *model = [self.dataArr objectAtIndex:indexPath.row];
    cell.imgBt.selected = NO;
    model.isNow = @"0";
}

#pragma mark - getter
- (UIView *)footer {

    if (!_footer) {
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 30)];
        _footer.backgroundColor = [UIColor clearColor];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 0.6f)];
        line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_footer addSubview:line];
        UILabel *msgLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, kScreenSize.width, 25.f)];
        msgLb.text = @"已检索所有可用抵金券";
        msgLb.textColor = [UIColor lightGrayColor];
        msgLb.textAlignment = NSTextAlignmentCenter;
        msgLb.font = [UIFont systemFontOfSize:13.f];
        [_footer addSubview:msgLb];
    }
    return _footer;
}

- (PayHeader *)header {

    if (!_header) {
        
        _header = [[NSBundle mainBundle]loadNibNamed:@"PayHeader" owner:nil options:nil].lastObject;
        _header.frame = CGRectMake(0, 0, kScreenSize.width, 450.f);
        _header.balanceBt.tag = 300;
        _header.ccbBt.tag = 301;
        _header.aliBt.tag = 302;
        _header.wxBt.tag = 303;
        [_header attentionForUserBalance:YES ccb:YES ali:NO weixin:YES];
        [_header.balanceBt addTarget:self action:@selector(beforePayCliked:) forControlEvents:UIControlEventTouchUpInside];
        [_header.ccbBt addTarget:self action:@selector(beforePayCliked:) forControlEvents:UIControlEventTouchUpInside];
        [_header.aliBt addTarget:self action:@selector(beforePayCliked:) forControlEvents:UIControlEventTouchUpInside];
        [_header.wxBt addTarget:self action:@selector(beforePayCliked:) forControlEvents:UIControlEventTouchUpInside];
        [_header.payBt addTarget:self action:@selector(payOffer:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _header;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
