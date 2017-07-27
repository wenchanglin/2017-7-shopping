//
//  PostsViewController.m
//  885logistics
//
//  Created by Blues on 17/1/10.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "PostsViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "PostTCell2.h"
#import "PostTCell1.h"
#import "PostCell3.h"
#import "PostModel.h"


@interface PostsViewController ()<UITableViewDelegate,UITableViewDataSource> {
    MPMoviePlayerViewController *_mp;
}
@property (nonatomic, strong) MPMoviePlayerViewController *mp;
@property (nonatomic, strong) UIView *footer;
@property (nonatomic, assign) NSInteger page;

@end

@implementation PostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)initData {

    self.page = 0;
    self.dataArr = [[NSMutableArray alloc] init];
    [self queryMyPostsFormServiceReload:NO];
}


- (void)createViews {

    self.navigationItem.title = @"我的帖子";
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = self.footer;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTCell2" bundle:nil] forCellReuseIdentifier:@"PostTCell2"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTCell1" bundle:nil] forCellReuseIdentifier:@"PostTCell1"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PostCell3" bundle:nil] forCellReuseIdentifier:@"PostCell3"];
    
    [self.view addSubview:self.tableView];
    
    
    MJRefreshNormalHeader *mjHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 0;
        [self queryMyPostsFormServiceReload:YES];
    }];
    self.tableView.mj_header = mjHeader;
    MJRefreshBackNormalFooter *mjFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        
        self.page ++;
        [self queryMyPostsFormServiceReload:NO];
    }];
    self.tableView.mj_footer = mjFooter;
}


- (void)queryMyPostsFormServiceReload:(BOOL)reload {
    
    if (reload) {
        
        [self.dataArr removeAllObjects];
        [self.tableView reloadData];
    }
    NSDictionary *param = @{@"fkUserId":[LYHelper getCurrentUserID],
                            @"page":@(self.page),
                            @"limit":@"10"
                            };
    
    [[LYAPIManager sharedInstance] POST:@"transportion/forunmPost/queryForunmPost" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
         NSLog(@"%@___",result);
        
        if ([result[@"errcode"] integerValue] == 0) {
            
            NSDictionary *data = result[@"data"];
            
            id idiData = data[@"iData"];
            
            if (NotNilAndNull(idiData)) {
                
                NSArray *iData = data[@"iData"];
                for (NSDictionary *post in iData) {
                    
                    PostModel *model = [[PostModel alloc] init];
                    [model setValuesForKeysWithDictionary:post];
                    model.fkPostID = post[@"id"];
                    
                    model.userType = @"";
                    model.userName = @"匿名";
                    
                    if (NotNilAndNull(post[@"userInfoBase"])) {
                        
                        NSDictionary *userInfoBase = post[@"userInfoBase"];
                        model.userType = userInfoBase[@"roleType"];
                        if (NotNilAndNull(userInfoBase[@"userName"])) {
                            model.userName = userInfoBase[@"userName"];
                        }
                        if (NotNilAndNull(userInfoBase[@"userPhoto"])) {
                            NSDictionary *userPhoto = userInfoBase[@"userPhoto"];
                            model.userImgUrl = userPhoto[@"location"];
                        }
                    }
                    
                    model.images = [[NSMutableArray alloc] init];
                    if (NotNilAndNull(post[@"postPhoto"])) {
                        
                        NSArray *postPhoto = post[@"postPhoto"];
                        if (postPhoto.count) {
                            for (NSDictionary *IMG in postPhoto) {
                                [model.images addObject:IMG[@"location"]];
                            }
                            model.type = @"3";
                        }
                    }
                    
                    if (NotNilAndNull(post[@"postVideo"])) {
                        
                        NSDictionary *postVideo = post[@"postVideo"];
                        NSArray *lcs = postVideo[@"iData"];
                        NSDictionary *lcDict = lcs.firstObject;
                        model.videoUrl = lcDict[@"location"];
                    }
                    
                    if (NotNilAndNull(post[@"postVideoPhoto"])) {
                        NSDictionary *postVideoPhoto = post[@"postVideoPhoto"];
                        NSArray *videoImages = postVideoPhoto[@"iData"];
                        NSDictionary *img = videoImages.firstObject;
                        model.videoImageUrl = img[@"location"];
                    }
                    //NSLog(@"_____%@_____%@",model.type,model.videoUrl);
                    
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
    
    PostModel *model = [self.dataArr objectAtIndex:indexPath.row];
    NSInteger postType = [model.type integerValue];
    
    if (postType == 1) {
        
        PostTCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"PostTCell2" forIndexPath:indexPath];
        cell.deleteBt.hidden = NO;
        cell.lifeVC = self;
        [cell paddingDataWith2:model];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else if(postType == 3){
        
        PostTCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"PostTCell1" forIndexPath:indexPath];
        cell.deleteBt.hidden = NO;
        cell.lifeVC = self;
        [cell paddingDataWith:model];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    }else if (postType == 2){
        //视频
        PostCell3 *vCell = [tableView dequeueReusableCellWithIdentifier:@"PostCell3" forIndexPath:indexPath];
        [vCell paddingVideoDataWith:model];
        vCell.deleteBt.hidden = NO;
        vCell.lifeVC = self;
        vCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return vCell;
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PostModel *model = [self.dataArr objectAtIndex:indexPath.row];
    NSInteger type = [model.type integerValue];
    if (type == 1) {
        
        return 115.f;
        
    }else if (type == 3){
        
        return 120.f + kScreenSize.width * 0.3f;
    }
    return 215.f;
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

#pragma mark - Delete

- (void)deletePostWithPostID:(PostModel *)model {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定删除此帖?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary *param = @{@"pId":model.fkPostID};
        
        [[LYAPIManager sharedInstance] POST:@"transportion/forunmPost/delForunmPost" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            if ([result[@"errcode"] integerValue] == 0) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.tableView beginUpdates];
                    //NSIndexPath *indexPath  = [self.tableView indexPathForCell:self];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.dataArr indexOfObject:model] inSection:0];
                    [self.dataArr removeObjectAtIndex:indexPath.row];
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView endUpdates];
                });
            }else {
                
                if (NotNilAndNull(result[@"msg"])) {
                    NSString *msg = result[@"msg"];
                    if (msg.length) {
                        [LYAPIManager showMessageForUser:msg];
                    }
                }
            }
        } failure:nil];
    }];
    UIAlertAction *alertAC = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // do nothing
    }];
    [alert addAction:alertAction];
    [alert addAction:alertAC];
    [self presentViewController:alert animated:YES completion:^{}];
}


#pragma mark - PlayVideo

- (void)playVideoWithUrlString:(NSString *)urlStr {
    if (IsNilOrNull(urlStr)) {
        return;
    }
    NSString *url = [NSString stringWithFormat:ImgLoadUrl,urlStr];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playBack:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    self.mp = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:url]];
    self.mp.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    self.mp.moviePlayer.shouldAutoplay = NO;
    [self presentMoviePlayerViewControllerAnimated:self.mp];
}

- (void)playBack:(NSNotification *)nf {
    
    if (self.mp) {
        [[NSNotificationCenter defaultCenter] removeObserver:self  name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
        [self.mp.moviePlayer stop];
        [self.mp dismissViewControllerAnimated:YES completion:nil];
        self.mp = nil;
    }
}


#pragma mark - getter
- (UIView *)footer {

    if (!_footer) {
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 1.f)];
        _footer.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _footer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
