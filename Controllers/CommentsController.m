//
//  CommentsController.m
//  LogisticsDriver
//
//  Created by Blues on 17/1/23.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "CommentsController.h"
#import "ReplyUserController.h"
#import "CommentsTCell.h"
#import "CommentsTCell1.h"
#import "ReplyCell.h"
#import "ReplyCell11.h"
#import "CommentDTO.h"

@interface CommentsController ()<UITableViewDelegate,UITableViewDataSource,CommentsTCellDelegate,CCellDelegate> {

}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, assign) NSInteger page;

@end

@implementation CommentsController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self queryDataFromServerReload:YES];
}

- (void)createViews {

    self.navigationItem.title = @"客户评价";
    
    self.page = 0;
    self.dataArr = [[NSMutableArray alloc] init];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentsTCell" bundle:nil] forCellReuseIdentifier:@"CommentsTCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentsTCell1" bundle:nil] forCellReuseIdentifier:@"CommentsTCell1"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ReplyCell" bundle:nil] forCellReuseIdentifier:@"ReplyCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ReplyCell11" bundle:nil] forCellReuseIdentifier:@"ReplyCell11"];
    [self.view addSubview:self.tableView];
    
    MJRefreshNormalHeader *mjHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
         self.page = 0;
        [self queryDataFromServerReload:YES];
    }];
    self.tableView.mj_header = mjHeader;
    MJRefreshBackNormalFooter *mjFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
         self.page ++;
        [self queryDataFromServerReload:NO];
    }];
    self.tableView.mj_footer = mjFooter;
}

- (void)queryDataFromServerReload:(BOOL)reload {

    if (reload) {
        
        [self.dataArr removeAllObjects];
        [self.tableView reloadData];
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
     NSDictionary *param = @{@"fkDriverId":[LYHelper getCurrentUserID],
                             @"page":@(self.page),
                             @"limit":@"6",
                             };
    
    [[LYAPIManager sharedInstance] POST:@"transportion/transOrderEva/queryTransOrderEva" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
          NSLog(@"___%@______",result);
        
        if ([result[@"errcode"] integerValue] == 0) {
            
            if (NotNilAndNull(result[@"data"])) {
                NSDictionary *data = result[@"data"];
                if (NotNilAndNull(data[@"iData"])) {
                    
                    NSArray *iData = data[@"iData"];
                    for (NSDictionary *comment in iData) {
                        
                        CommentDTO *dto1 = [[CommentDTO alloc] init];
                        dto1.isCan = YES;
                        dto1.type = @"100";
                        dto1.fkDataId = comment[@"id"];
                        
                       [dto1 setValuesForKeysWithDictionary:comment];
                        
                        if (NotNilAndNull(comment[@"evaPhoto"])) {
                            NSArray *images = comment[@"evaPhoto"];
                            dto1.imageArr = [[NSMutableArray alloc] init];
                            dto1.type = @"200";
                            for (NSDictionary *img in images) {
                                [dto1.imageArr addObject:img[@"location"]];
                            }
                        }
                        if (NotNilAndNull(comment[@"userInfoBase"])) {
                            
                            NSDictionary *user = comment[@"userInfoBase"];
                            dto1.userName = user[@"userName"];
                            if (NotNilAndNull(user[@"userPhoto"])) {
                                NSDictionary *userImg = user[@"userPhoto"];
                                dto1.userImg = userImg[@"location"];
                            }
                        }
                        [self.dataArr addObject:dto1];
                        
                        if (NotNilAndNull(comment[@"transOrderInfoEvaReply"])) {
                            
                             dto1.isCan = NO;
                            
                            NSDictionary *reply = comment[@"transOrderInfoEvaReply"];
                            CommentDTO *dto2 = [[CommentDTO alloc] init];
                            dto2.content = reply[@"content"];
                            dto2.type = @"300";
                            
                            if (NotNilAndNull(reply[@"evaReplyPhoto"])) {
                                
                                dto2.type = @"500";
                                dto2.imageArr = [[NSMutableArray alloc] init];
                                NSArray *images2 = reply[@"evaReplyPhoto"];
                                for (NSDictionary *rpImg in images2) {
                                    [dto2.imageArr addObject:rpImg[@"location"]];
                                }
                            }
                            [self.dataArr addObject:dto2];
                        }
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            });
        });
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CommentDTO *dto = [_dataArr objectAtIndex:indexPath.row];
    NSInteger type = [dto.type integerValue];
    switch (type) {
        case 100:
        {
            CommentsTCell1 *cell100 = [tableView dequeueReusableCellWithIdentifier:@"CommentsTCell1" forIndexPath:indexPath];
            [cell100 updateViewWithComment:dto];
            cell100.delegate = self;
            cell100.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell100;
        }
            break;
        case 200:
        {
        
            CommentsTCell *cell200 = [tableView dequeueReusableCellWithIdentifier:@"CommentsTCell" forIndexPath:indexPath];
            [cell200 updateViewWithComment:dto];
            cell200.delegate = self;
            cell200.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell200;
        }
            break;
        case 300:
        {
            ReplyCell11 *cell300 = [tableView dequeueReusableCellWithIdentifier:@"ReplyCell11" forIndexPath:indexPath];
            cell300.contentLb.text = dto.content;
            cell300.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell300;
        }
            break;

        default:
        {
            ReplyCell *cell500 = [tableView dequeueReusableCellWithIdentifier:@"ReplyCell" forIndexPath:indexPath];
            [cell500 updateViewWithComment:dto];
            cell500.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell500;
        }
            break;
    }
}

- (void)replyUserWithfkOrderId:(NSString *)fkOrderId {

    ReplyUserController *reply = [[ReplyUserController alloc] init];
    [reply addPopItem];
    reply.fkOrderId = fkOrderId;
    [self.navigationController pushViewController:reply animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CommentDTO *dto = [self.dataArr objectAtIndex:indexPath.row];
    NSInteger type = [dto.type integerValue];
    CGFloat h1 = [dto.content boundingRectWithSize:CGSizeMake(kScreenSize.width - 72.f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.f]} context:nil].size.height;
    if (type == 200) {
        
        return h1 + 70.f + kScreenSize.width/3.f;

    }else if (type == 100){
        
        return h1 + 70.f;
    
    }else if (type == 500){
        
        return h1 + 35.f + kScreenSize.width/3.f;
    
    }else {
        
        return h1 + 35.f;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
