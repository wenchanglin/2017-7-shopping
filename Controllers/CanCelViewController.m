//
//  CanCelViewController.m
//  885logistics
//
//  Created by Blues on 17/3/15.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "CanCelViewController.h"
#import "KindsModel.h"

@interface CanCelViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *reasonLb;
@property (weak, nonatomic) IBOutlet UIButton *swBt;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *mbk;
@property (weak, nonatomic) IBOutlet UIButton *cancelBt;
@property (weak, nonatomic) IBOutlet UIButton *sureBt;
@property (weak, nonatomic) IBOutlet UIView *offerView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (weak, nonatomic) IBOutlet UILabel *msgLb;
@property (nonatomic, strong) UIView *footer;
@property (nonatomic, strong) NSString *strR;

@end

@implementation CanCelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViews];
    [self queryFromServer];
}

- (void)createViews {
    
    self.msgLb.text = @"取消订单需要对方同意,\n如需强制取消，请联系客服人员！";
    
    self.mbk.layer.masksToBounds = YES;
    self.mbk.layer.cornerRadius = 5.f;
    self.cancelBt.layer.masksToBounds = YES;
    self.cancelBt.layer.cornerRadius = 18.f;
    self.sureBt.layer.masksToBounds = YES;
    self.sureBt.layer.cornerRadius = 18.f;
    self.offerView.layer.masksToBounds = YES;
    self.offerView.layer.cornerRadius = 3.f;
    self.offerView.layer.borderColor = LGrayColor.CGColor;
    self.offerView.layer.borderWidth = 1.f;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tabCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = self.footer;
}

- (void)queryFromServer {
    
    self.dataArr = [[NSMutableArray alloc] init];
    [[LYAPIManager sharedInstance] POST:@"transportion/TransOrderCanRea/queryCanRea" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            
            if (NotNilAndNull(result[@"data"])) {
                
                NSDictionary *data = result[@"data"];
                if (NotNilAndNull(data[@"iData"])) {
                    NSArray *iData = data[@"iData"];
                    NSInteger once = 1;
                    for (NSDictionary *dict in iData) {
                        
                        if (once) {
                            self.reasonLb.text = dict[@"reason"];
                            self.strR = dict[@"id"];
                        }
                        KindsModel *model = [[KindsModel alloc]init];
                        model.text = dict[@"reason"];
                        model.kindID = dict[@"id"];
                        [self.dataArr addObject:model];
                        once = 0;
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (IBAction)hideOrShow:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.tableView.hidden = NO;
    }else {
        self.tableView.hidden = YES;
    }
}
- (IBAction)bkClicked:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tabCell"];
    KindsModel *model = [self.dataArr objectAtIndex:indexPath.row];
    cell.textLabel.text = model.text;
    cell.textLabel.font = [UIFont systemFontOfSize:14.f];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    KindsModel *model = [self.dataArr objectAtIndex:indexPath.row];
    self.reasonLb.text = model.text;
    self.strR = model.kindID;
    self.tableView.hidden = YES;
    self.swBt.selected = NO;
}

- (IBAction)sureClicked:(id)sender {
    
    NSString *reason = self.strR;
    if (IsEmptyStr(reason)) {
        [LYAPIManager showMessageForUser:@"请选择取消原因"];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(cancelOrderWithReason:)]) {
            [self.delegate cancelOrderWithReason:reason];
        }
    }];
}

- (IBAction)cancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.f;
}


- (UIView *)footer {
    
    if (!_footer) {
        
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 5.f)];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15.f, 0, kScreenSize.width - 75.f, 1.f)];
        line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _footer.backgroundColor = [UIColor clearColor];
        [_footer addSubview:line];
    }
    return _footer;
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
