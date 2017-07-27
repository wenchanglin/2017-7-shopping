//
//  BankListController.m
//  CustomFurniture
//
//  Created by Blues on 16/11/15.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "BankListController.h"
#import "BankListTCell.h"



@interface BankListController ()<UITableViewDelegate,UITableViewDataSource>{

}
@property (weak, nonatomic) IBOutlet UIView *alpView;
@property (nonatomic, strong) UIView *footer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSString *bankStr;


@end

@implementation BankListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.alpView.layer.masksToBounds = YES;
    self.alpView.layer.cornerRadius = 5.f;
    self.dataArr = [[NSMutableArray alloc] init];
    [self createViews];
}

- (IBAction)disClicked:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (self.mBlock && self.bankStr) {
            self.mBlock(self.bankStr);
        }
    }];
}

- (void)createViews {

    self.tableView.tableFooterView = self.footer;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BankListTCell" bundle:nil] forCellReuseIdentifier:@"BankListTCell"];
    
    [[LYAPIManager sharedInstance] POST:@"transportion/transBank/queryTransBankAll" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            if (NotNilAndNull(result[@"data"])) {
                NSDictionary *data = result[@"data"];
                if (NotNilAndNull(data[@"iData"])) {
                 
                    NSArray *iData = data[@"iData"];
                    for (NSDictionary *bank in iData) {
                     
                        [self.dataArr addObject:bank[@"bankName"]];
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


- (void)cameGetMy:(returnBlock)block {
    self.mBlock = [block copy];
}


- (UIView *)footer {

    if (!_footer) {
        _footer = [[UIView alloc] initWithFrame:CGRectMake(15.f, 0, kScreenSize.width - 55.f, 1.f)];
        _footer.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _footer;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    BankListTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BankListTCell" forIndexPath:indexPath];
    cell.tLb.text = [self.dataArr objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BankListTCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.iv.hidden = NO;
    self.bankStr = [self.dataArr objectAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    BankListTCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.iv.hidden = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
