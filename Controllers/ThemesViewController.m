//
//  BankListController.m
//  CustomFurniture
//
//  Created by Blues on 16/11/15.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "ThemesViewController.h"
#import "KindsModel.h"
#import "ThemeTCell.h"


@interface ThemesViewController ()<UITableViewDelegate,UITableViewDataSource>{

}
@property (weak, nonatomic) IBOutlet UIView *alpView;
@property (nonatomic, strong) UIView *footer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSArray *stateArr;
@property (nonatomic, strong) KindsModel *model;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@end

@implementation ThemesViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.alpView.layer.masksToBounds = YES;
    self.alpView.layer.cornerRadius = 5.f;
    self.alpView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.alpView.layer.borderWidth = 1.f;
    
    self.sureBtn.layer.cornerRadius = 5.f;
    self.sureBtn.layer.borderWidth = 1;
    self.sureBtn.layer.borderColor = [MainColor CGColor];
    self.sureBtn.layer.masksToBounds = YES;
    
    self.cancelBtn.layer.cornerRadius = 5.f;
    self.cancelBtn.layer.borderWidth = 1;
    self.cancelBtn.layer.borderColor = [LGrayColor CGColor];
    self.cancelBtn.layer.masksToBounds = YES;
    
    self.dataArr = [[NSMutableArray alloc] init];
    [self createViews];
    
    if (self.kindtype == 1) {
        
        [self queryTransportTypesFromService];
        
    }else if (self.kindtype == 2){
        
    }else {
    
        [self queryThemesFromService];
    }
}


- (IBAction)removeBtnClick:(id)sender {
    [self animationbegin:sender];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)sureBtnClick:(id)sender {
    [self animationbegin:sender];
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.mBlock && self.model) {
            self.mBlock(self.model);
        }
    }];
}


- (void)animationbegin:(UIView *)view {
    // 设定为缩放
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    // 动画选项设定
    animation.duration = 0.1; // 动画持续时间
    animation.repeatCount = -1; // 重复次数
    animation.autoreverses = YES; // 动画结束时执行逆动画
    animation.fromValue = [NSNumber numberWithFloat:1.0]; // 开始时的倍率
    animation.toValue = [NSNumber numberWithFloat:0.9]; // 结束时的倍率
    [view.layer addAnimation:animation forKey:@"scale-layer"];
}

- (IBAction)disClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)createViews {

    self.tableView.tableFooterView = self.footer;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ThemeTCell" bundle:nil] forCellReuseIdentifier:@"ThemeTCell"];
}

- (void)cameGetMy:(returnBlock)block {
    self.mBlock = [block copy];
}


- (void)queryTransportTypesFromService {
    
    [[LYAPIManager sharedInstance] POST:@"transportion/transClass/queryAll" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"____%@",result);
        
        if ([result[@"errcode"] integerValue] == 0) {
            if ([result[@"errcode"] integerValue] == 0) {
                NSDictionary *data = result[@"data"];
                if (NotNilAndNull(data[@"iData"])) {
                    NSArray *iData = data[@"iData"];
                    for (NSDictionary *transType in iData) {
                        
                        KindsModel *model = [[KindsModel alloc] init];
                        model.kindID = transType[@"id"];
                        model.text = transType[@"transClass"];
                        model.isNow = @"0";
                        [self.dataArr addObject:model];
                    }
                    
                    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                        // Do something...
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    });
                }
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}



- (void)queryThemesFromService {
    
    [[LYAPIManager sharedInstance] POST:@"transportion/comn/queryComnAll" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        //NSLog(@"%@",result);
        
        if ([result[@"errcode"] integerValue] == 0) {
            NSDictionary *data = result[@"data"];
            if (NotNilAndNull(data[@"iData"])) {
                NSArray *iData = data[@"iData"];
                for (NSDictionary *theme in iData) {
                    
                    KindsModel *model = [[KindsModel alloc] init];
                    model.kindID = theme[@"id"];
                    model.text = theme[@"comName"];
                    model.isNow = @"0";
                    [self.dataArr addObject:model];
                }
                // Do something...
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    ThemeTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThemeTCell" forIndexPath:indexPath];
    
    KindsModel *model = [self.dataArr objectAtIndex:indexPath.row];
    cell.tLb.text = model.text;
    if ([model.isNow boolValue]) {
        cell.iv.hidden = NO;
    }else {
        cell.iv.hidden = YES;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ThemeTCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    KindsModel *model = [self.dataArr objectAtIndex:indexPath.row];
    model.isNow = @"1";
    cell.iv.hidden = NO;
    
    self.model = model;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ThemeTCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    KindsModel *model = [self.dataArr objectAtIndex:indexPath.row];
    model.isNow = @"0";
    cell.iv.hidden = YES;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void)viewWillLayoutSubviews {
    
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - getter

- (UIView *)footer {
    if (!_footer) {
        
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0, kScreenSize.width - 60.f, 0.6f)];
        _footer.backgroundColor = [UIColor lightGrayColor];
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
