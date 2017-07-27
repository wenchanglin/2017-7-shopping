//
//  BrokerageController.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/18.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BrokerageController.h"
#import "CouponModel.h"
#import "CouponTCell.h"

@interface BrokerageController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (weak, nonatomic) IBOutlet UIView *okBt;
@property (weak, nonatomic) IBOutlet UIButton *noBt;
@property (weak, nonatomic) IBOutlet UIView *bkView;
@property (nonatomic, strong) UIView *footer;
@property (nonatomic, strong) NSString *voucher;

@end

@implementation BrokerageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViews];
}

- (void)createViews {
    
    self.voucher = @"";
    
    self.dataArr = [[NSMutableArray alloc] init];
    self.bkView.layer.masksToBounds = YES;
    self.bkView.layer.cornerRadius = 5.f;
    self.okBt.layer.masksToBounds = YES;
    self.okBt.layer.cornerRadius = 18.f;
    self.noBt.layer.masksToBounds = YES;
    self.noBt.layer.cornerRadius = 18.f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"CouponTCell" bundle:nil] forCellReuseIdentifier:@"CouponTCell"];
    self.tableView.tableFooterView = self.footer;
    [self queryDataFromServer];
}

- (IBAction)useClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(payWithCoupon:)]) {
            [self.delegate payWithCoupon:self.voucher];
        }
    }];
}

- (IBAction)notUseClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)backClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)queryDataFromServer {
    
    NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID]};
    [[LYAPIManager sharedInstance] POST:@"transportion/userSVoucher/querySVoucherAll" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        // NSLog(@"%@",result);
        
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
                    
                    [self.dataArr addObject:model];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        });
    }];
}

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
    return (kScreenSize.width - 80.f)/3.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CouponTCell *cell = [tableView  cellForRowAtIndexPath:indexPath];
    CouponModel *model = [self.dataArr objectAtIndex:indexPath.row];
    cell.imgBt.selected = !cell.imgBt.selected;
    if (cell.imgBt.isSelected) {
        cell.imgBt.selected = YES;
        model.isNow = @"1";
        self.voucher = model.fkCouponId;
    }else {
        cell.imgBt.selected = NO;
        model.isNow = @"0";
        self.voucher = @"";
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
        
        CGFloat width = kScreenSize.width - 80.f;
        
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 30.f)];
        _footer.backgroundColor = [UIColor clearColor];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 1.f)];
        line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_footer addSubview:line];
        UILabel *msgLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,width, 30.f)];
        msgLb.text = @"已检索所有可用抵金券";
        msgLb.textColor = [UIColor lightGrayColor];
        msgLb.textAlignment = NSTextAlignmentCenter;
        msgLb.font = [UIFont systemFontOfSize:13.f];
        [_footer addSubview:msgLb];
    }
    return _footer;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
