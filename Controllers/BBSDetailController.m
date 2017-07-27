//
//  BBSDetailController.m
//  885logistics
//
//  Created by Blues on 17/1/22.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BBSDetailController.h"
#import "ReplyPostController.h"
#import "ReportViewController.h"
#import "PostModel.h"
#import "DetailCell1.h"
#import "DetailCell2.h"
#import "DetailCell3.h"
#import "ReplyCell1.h"
#import "ReplyCell2.h"
#import <MediaPlayer/MediaPlayer.h>


@interface BBSDetailController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate> {

    MPMoviePlayerViewController *_mp;
}
@property (nonatomic, strong) MPMoviePlayerViewController *mp;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) PostModel *model;


@end

@implementation BBSDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self queryPostDetailReload:YES];
}


- (void)initData {
    
    self.dataArr = [[NSMutableArray alloc] init];
}

- (void)createViews {
    
    self.navigationItem.title = @"帖子详情";
    
    [self createNavItems];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 106.f) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ReplyCell2" bundle:nil] forCellReuseIdentifier:@"ReplyCell2"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ReplyCell1" bundle:nil] forCellReuseIdentifier:@"ReplyCell1"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DetailCell1" bundle:nil] forCellReuseIdentifier:@"DetailCell1"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DetailCell2" bundle:nil] forCellReuseIdentifier:@"DetailCell2"];
    [self.tableView registerNib:[UINib nibWithNibName:@"DetailCell3" bundle:nil] forCellReuseIdentifier:@"DetailCell3"];

    //[self.view addSubview:self.tableView];
    [self.view addSubview:self.bottomView];
    
    MJRefreshNormalHeader *mjHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self queryPostDetailReload:YES];
    }];
    self.tableView.mj_header = mjHeader;
}

- (void)createNavItems {
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"举报" style:UIBarButtonItemStyleDone target:self action:@selector(reportPostClicked)];
    item.tintColor = [UIColor whiteColor];
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[item];
}

- (void)reportPostClicked {
    
    if (!_model) {
        return;
    }
    ReportViewController *report = [[ReportViewController alloc] init];
    [report addPopItem];
    report.model = _model;
    [self.navigationController pushViewController:report animated:YES];
}


- (void)queryPostDetailReload:(BOOL)reload {
    
    if (reload) {
        [self.dataArr removeAllObjects];
        [self.tableView reloadData];
    }
    
    NSDictionary *param = @{@"pid":_postID};
    
    //NSLog(@"____%@",param);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[LYAPIManager sharedInstance] POST:@"transportion/forunmPost/queryForunmPostByPid" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        //NSLog(@"___%@",result);
        
        if ([result[@"errcode"] integerValue] == 0) {
            
            NSDictionary *data = result[@"data"];
            
            self.model = [[PostModel alloc] init];
            [self.model setValuesForKeysWithDictionary:data];
            self.model.fkPostID = data[@"id"];
            
            self.model.userType = @"";
            self.model.userName = @"";
            self.model.isMine = @"0";
            self.model.pOre = @"post";
                
            if (NotNilAndNull(data[@"userInfoBase"])) {
                
                NSDictionary *userInfoBase = data[@"userInfoBase"];
                self.model.userType = userInfoBase[@"roleType"];
                if (NotNilAndNull(userInfoBase[@"userName"])) {
                    self.model.userName = userInfoBase[@"userName"];
                }
                if (NotNilAndNull(userInfoBase[@"userPhoto"])) {
                    NSDictionary *userPhoto = userInfoBase[@"userPhoto"];
                    self.model.userImgUrl = userPhoto[@"location"];
                }
                //NSLog(@"____%@",userInfoBase);
                if ([[LYHelper getCurrentUserID] isEqualToString:userInfoBase[@"id"]]) {
                    self.model.isMine = @"111";
                }
            }
                
            self.model.images = [[NSMutableArray alloc] init];
            if (NotNilAndNull(data[@"postPhoto"])) {
                
                NSArray *postPhoto = data[@"postPhoto"];
                if (postPhoto.count) {
                    for (NSDictionary *IMG in postPhoto) {
                        [self.model.images addObject:IMG[@"location"]];
                    }
                    self.model.type = @"3";
                }
            }
                
            if (NotNilAndNull(data[@"postVideo"])) {
                
                NSDictionary *postVideo = data[@"postVideo"];
                NSArray *lcs = postVideo[@"iData"];
                NSDictionary *lcDict = lcs.firstObject;
                self.model.videoUrl = lcDict[@"location"];
            }
            
            if (NotNilAndNull(data[@"postVideoPhoto"])) {
                NSDictionary *postVideoPhoto = data[@"postVideoPhoto"];
                NSArray *videoImages = postVideoPhoto[@"iData"];
                NSDictionary *img = videoImages.firstObject;
                self.model.videoImageUrl = img[@"location"];
            }
            
            if (NotNilAndNull(data[@"forumEva"])) {
                
                NSArray *forumEva = data[@"forumEva"];
                
                //NSLog(@"_forumEva Class___%@",[data[@"forumEva"] class]);
                for (NSDictionary *eva1 in forumEva) {
                    
                    //NSLog(@"___%@",eva1[@"id"]);
                    
                    PostModel *model1 = [[PostModel alloc] init];
                    [model1 setValuesForKeysWithDictionary:eva1];
                    model1.fkPostID     = eva1[@"id"];
                    model1.type         = @"1";
                    model1.userType     = @"";
                    model1.userName     = @"";
                    model1.canAnswer    = @"YES";
                    model1.pOre         = @"eva";
                    
                    if (NotNilAndNull(eva1[@"userInfoBase"])) {

                        NSDictionary *userInfoBase = eva1[@"userInfoBase"];
                        model1.userType = userInfoBase[@"roleType"];
                        if (NotNilAndNull(userInfoBase[@"userName"])) {
                            model1.userName = userInfoBase[@"userName"];
                        }
                        
                        if (NotNilAndNull(userInfoBase[@"userPhoto"])) {
                            NSDictionary *userPhoto = userInfoBase[@"userPhoto"];
                            model1.userImgUrl = userPhoto[@"location"];
                        }
                    }
                    
                    model1.images = [[NSMutableArray alloc] init];
                    if (NotNilAndNull(eva1[@"postEvaPhoto"])) {
                        NSArray *postEvaPhoto = eva1[@"postEvaPhoto"];
                        if (postEvaPhoto.count) {
                            for (NSDictionary *IMG in postEvaPhoto) {
                                [model1.images addObject:IMG[@"location"]];
                            }
                            model1.type = @"3";
                        }
                    }
                    
                    [self.dataArr addObject:model1];

                    if (NotNilAndNull(eva1[@"forumEvaReply"])) {
                        
                        NSLog(@"_____");
                        
                        model1.canAnswer = @"NO";
                        
                        NSArray *forumEvaReply = eva1[@"forumEvaReply"];
                        
                        for (NSDictionary *eva2 in forumEvaReply) {
                            
                            //NSLog(@"__eva2__%@",eva2[@"id"]);
                            
                            PostModel *model2 = [[PostModel alloc] init];
                            [model2 setValuesForKeysWithDictionary:eva2];
                            model2.fkPostID = eva2[@"id"];
                            model2.type = @"6";
                            
                            model2.images = [[NSMutableArray alloc] init];
                            
                            if (NotNilAndNull(eva2[@"evaReplyPhoto"])) {
                                
                                NSArray *evaReplyPhoto = eva2[@"evaReplyPhoto"];
                                if (evaReplyPhoto.count) {
                                    for (NSDictionary *IMG in evaReplyPhoto) {
                                        [model2.images addObject:IMG[@"location"]];
                                    }
                                    model2.type = @"5";
                                }
                            }
                            [self.dataArr addObject:model2];
                        }
                    }
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.view addSubview:self.tableView];
                self.label1.text = [NSString stringWithFormat:@"评论 %@",data[@"fkEvaNum"]];
                [self.tableView reloadData];
                [self.tableView.mj_header endRefreshing];
            });
            
        }else {
            

            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.tableView.mj_header endRefreshing];
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.tableView.mj_header endRefreshing];
            });
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    }
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        
        PostModel *model = self.model;
        NSInteger postType = [model.type integerValue];
        
        if (postType == 3) {
            //有图片
            DetailCell1 *cell1 = [tableView dequeueReusableCellWithIdentifier:@"DetailCell1" forIndexPath:indexPath];
            cell1.reportBt1.hidden = YES;
            cell1.moreBt.hidden = YES;
            cell1.lifeVC = self;
            [cell1 paddingDataWith1:model cellType:1];
            cell1.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell1;
            
        }else if(postType == 1){
            
            DetailCell2 *cell2 = [tableView dequeueReusableCellWithIdentifier:@"DetailCell2" forIndexPath:indexPath];
            cell2.reportBt1.hidden = YES;
            cell2.moreBt.hidden = YES;
            cell2.lifeVC = self;
            [cell2 paddingDataWith2:model cellType:1];
            cell2.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell2;
            
        }else if (postType == 2){
            //视频
            DetailCell3 *cell3 = [tableView dequeueReusableCellWithIdentifier:@"DetailCell3" forIndexPath:indexPath];
            [cell3 paddingDataWith3:model];
            cell3.lifeVC = self;
            cell3.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell3;
        }
        
    }else {
        //------------------------------------------------------------------//
        //****************************** 评论区  ****************************//
        //------------------------------------------------------------------//
        
        PostModel *model = [self.dataArr objectAtIndex:indexPath.row];
        NSInteger celltype = [model.type integerValue];
        NSInteger postUser = [self.model.isMine integerValue];
        
        if (celltype == 3) {
            //有图片
            DetailCell1 *cell1 = [tableView dequeueReusableCellWithIdentifier:@"DetailCell1" forIndexPath:indexPath];
            if (postUser == 111 && [model.canAnswer isEqualToString:@"YES"]) {
                cell1.reportBt1.hidden = YES;
                cell1.moreBt.hidden = NO;
            }else {
                cell1.reportBt1.hidden = NO;
                cell1.moreBt.hidden = YES;
            }
            cell1.lifeVC = self;
            [cell1 paddingDataWith1:model cellType:2];
            cell1.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell1;
            
        }else if (celltype == 1){
            
            DetailCell2 *cell2 = [tableView dequeueReusableCellWithIdentifier:@"DetailCell2" forIndexPath:indexPath];
            if (postUser == 111 && [model.canAnswer isEqualToString:@"YES"]) {
                cell2.reportBt1.hidden = YES;
                cell2.moreBt.hidden = NO;
            }else {
                cell2.reportBt1.hidden = NO;
                cell2.moreBt.hidden = YES;
            }
            cell2.lifeVC = self;
            [cell2 paddingDataWith2:model cellType:2];
            cell2.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell2;
            
        }else if (celltype == 5){
            
            ReplyCell1 *cell5 = [tableView dequeueReusableCellWithIdentifier:@"ReplyCell1"];
            cell5.contentLb.text = model.content;
            NSString *ivUrlStr = [NSString stringWithFormat:ImgLoadUrl,[model.images firstObject]];
            [cell5.iv sd_setImageWithURL:[NSURL URLWithString:ivUrlStr]];
            cell5.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell5;
            
        }else if (celltype == 6){
        
            ReplyCell2 *cell6 = [tableView dequeueReusableCellWithIdentifier:@"ReplyCell2"];
            cell6.contentLb.text = model.content;
            cell6.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell6;
        }
    }
    return nil;
}


- (void)reportPostWithPostID:(PostModel *)model {

    ReportViewController *report = [[ReportViewController alloc] init];
    [report addPopItem];
    report.model = model;
    [self.navigationController pushViewController:report animated:YES];
}

- (void)replyPostWithPostID:(PostModel *)model {

    ReplyPostController *reply = [[ReplyPostController alloc] init];
    [reply addPopItem];
    reply.model = model;
    reply.fkEvaId = model.fkPostID;
    [self.navigationController pushViewController:reply animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        PostModel *model = self.model;
        NSInteger postType = [model.type integerValue];
        CGFloat h1 = [model.title boundingRectWithSize:CGSizeMake(kScreenSize.width - 18.f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.f]} context:nil].size.height;
        CGFloat h2 = [model.content boundingRectWithSize:CGSizeMake(kScreenSize.width - 18.f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.f]} context:nil].size.height;
        
        if (postType == 1) {
            
            return 80.f + h1 + h2 ;
            
        }else if (postType == 2){
        
            return 80.f + kScreenSize.width * 0.45f + h2 + h1;
            
        }else if (postType == 3){
            
            return 80.f + h1 + h2 + kScreenSize.width * 0.3f;
        }
    }else if (indexPath.section == 1){
    
        PostModel *model = [self.dataArr objectAtIndex:indexPath.row];
        NSInteger postType = [model.type integerValue];
        CGFloat h1 = [model.content boundingRectWithSize:CGSizeMake(kScreenSize.width - 18.f, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.f]} context:nil].size.height;
        if (postType == 1) {
            
            return 90.f + h1;
            
        }else if (postType == 3){
            
            return 90.f + h1 + kScreenSize.width * 0.3f;
        
        }else if (postType == 5){
            
            return 50.f + kScreenSize.width * 0.3f + h1;
        
        }else if (postType == 6){
            
            return 50.f + h1;
        }
    }
    
    return 0.f;
}



- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    NSArray *cells = [self.tableView visibleCells];
    
    for (UITableViewCell *cell in cells) {
        if ([cell isKindOfClass:[DetailCell1 class]]) {
            DetailCell1 *cell1 = (DetailCell1 *)cell;
            cell1.moreView.hidden = YES;
        }else if ([cell isKindOfClass:[DetailCell2 class]]) {
            DetailCell2 *cell2 = (DetailCell2 *)cell;
            cell2.moreView.hidden = YES;
        }
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if (section == 1) {
        return 36.f;
    }
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (section == 1) {
        return  self.view1;
    }
    return nil;
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
- (UIView *)view1 {

    if (!_view1) {
        _view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 36.f)];
        [_view1 addSubview:self.label1];
    }
    return _view1;
}
- (UILabel *)label1 {

    if (!_label1) {
        _label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 36)];
        _label1.textColor = [UIColor lightGrayColor];
        _label1.font = [UIFont systemFontOfSize:14.f];
        _label1.text = @"评论";
    }
    return _label1;
}

- (UIView *)bottomView {

    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenSize.height - 106.f, kScreenSize.width,42.f)];
        _bottomView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 1.f, kScreenSize.width, 41.f)];
        view.backgroundColor = [UIColor whiteColor];
        [_bottomView addSubview:view];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(kScreenSize.width/2.f - 60.f, 3.f, 120, 36)];
        [button setTitle:@"回复楼主" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:14.f];
        [button addTarget:self action:@selector(replyPostUser) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
    }
    return _bottomView;
}

- (void)replyPostUser {

    ReplyPostController *reply = [[ReplyPostController alloc] init];
    [reply addPopItem];
    reply.fkPostId = self.model.fkPostID;
    reply.model = self.model;
    [self.navigationController pushViewController:reply animated:YES];
}


- (void)playVideoWithUrlString:(NSString *)urlStr {
    if (IsNilOrNull(urlStr)) {
        return;
    }
    NSString *url = [NSString stringWithFormat:ImgLoadUrl,urlStr];
    NSLog(@"##———视频链接————%@",url);
    //增加观察者 视频播放完毕或者点击Done
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playBack:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    self.mp = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:url]];
    self.mp.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    self.mp.moviePlayer.shouldAutoplay = NO;
    //界面跳转
    [self presentMoviePlayerViewControllerAnimated:self.mp];
}


- (void)playBack:(NSNotification *)nf {
    if (self.mp) {
        //删除观察者
        [[NSNotificationCenter defaultCenter] removeObserver:self  name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        [self.mp.moviePlayer stop];
        [self.mp dismissViewControllerAnimated:YES completion:nil];
        self.mp = nil;
    }
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
