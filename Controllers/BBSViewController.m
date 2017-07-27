//
//  BBSViewController.m
//  885logistics
//
//  Created by Blues on 17/1/3.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BBSViewController.h"
#import "TextViewController.h"
#import "VideoViewController.h"
#import "BBSDetailController.h"
#import "BBSTopView.h"
#import "ChooseThemeView.h"
#import "ReleaseView.h"
#import "KindsModel.h"
#import "KindSCell.h"
#import "KindCCell.h"
#import "ColumnTCell.h"
#import "PostTCell1.h"
#import "PostTCell2.h"
#import "PostModel.h"
#import "PostCell3.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LctItem.h"



@interface BBSViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource> {
    
    MPMoviePlayerViewController *_mp;
}

@property (nonatomic, strong) MPMoviePlayerViewController *mp;
@property (nonatomic, weak)   ChooseThemeView *moreView;
@property (nonatomic, weak)   BBSTopView *header;
@property (nonatomic, weak)   ReleaseView *leview;
@property (nonatomic, strong) UIView *footer;
@property (nonatomic, strong) NSMutableArray *kindsArr;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSString *kindStr;
@property (nonatomic, strong) NSString *hot;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) LctItem *lctItem;


@end

@implementation BBSViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)initData {
    
    self.view.frame = CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f);
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.kindsArr   = [NSMutableArray new];
    self.dataArr    = [NSMutableArray new];
    self.hot        = @"hot";
    self.date       = @"";
    self.kindStr    = @"";
    self.page       = 0;
    [self queryThemesFromServer];
}

- (void)createViews {

    [self createNavItems];
    
    [self.view addSubview:self.header];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80.f, kScreenSize.width, kScreenSize.height - 145.f) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tag = 777;
    self.tableView.tableFooterView = self.footer;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTCell2" bundle:nil] forCellReuseIdentifier:@"PostTCell2"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PostTCell1" bundle:nil] forCellReuseIdentifier:@"PostTCell1"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PostCell3" bundle:nil] forCellReuseIdentifier:@"PostCell3"];
    [self.view addSubview:self.tableView];
    
    MJRefreshNormalHeader *mjHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 0;
        [self queryPostFromServiceReload:YES];
    }];
    self.tableView.mj_header = mjHeader;
    MJRefreshBackNormalFooter *mjFooter = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        self.page ++;
        [self queryPostFromServiceReload:NO];
    }];
    self.tableView.mj_footer = mjFooter;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:self.moreView];
    
    [window addSubview:self.leview];
}


- (void)createNavItems {

    UIImage *img = [[UIImage imageNamed:@"nav1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStyleDone target:self action:@selector(toggleRelease)];
    self.navigationItem.rightBarButtonItems = @[item];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:self.lctItem];
    self.navigationItem.leftBarButtonItems = @[left];
}

- (LctItem *)lctItem {
    
    if (!_lctItem) {
        _lctItem = [[LctItem alloc] initWithFrame:CGRectMake(0, 0, 80.f, 40.f)];
    }
    return _lctItem;
}

- (void)toggleRelease {
    self.leview.hidden = NO;
}

- (void)queryThemesFromServer {
    
    [[LYAPIManager sharedInstance] POST:@"transportion/comn/queryComnAll" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"水电费%@",result);
        
        if ([result[@"errcode"] integerValue] == 0) {
            NSDictionary *data = result[@"data"];
            if (NotNilAndNull(data[@"iData"])) {
                NSArray *iData = data[@"iData"];
                
                NSInteger once = 0;
                
                for (NSDictionary *theme in iData) {
                    
                    KindsModel *model = [[KindsModel alloc] init];
                    model.text = theme[@"comName"];
                    model.kindID = theme[@"id"];
                    if (once == 0) {
                        model.isNow = @"1";
                        self.kindStr = theme[@"id"];
                    }else {
                        model.isNow = @"0";
                    }
                    [self.kindsArr addObject:model];
                    
                    once ++;
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.header.collectionView reloadData];
                    [self queryPostFromServiceReload:NO];
                });
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}



- (void)queryPostFromServiceReload:(BOOL)reload {
    
    if (reload) {
        
         self.page = 0;
        [self.dataArr removeAllObjects];
        [self.tableView reloadData];
    }

    NSDictionary *param = @{@"comId":self.kindStr,
                            @"location":[LYHelper getCurrentCityName],
                            @"hot":self.hot,
                            @"date":self.date,
                            @"page":@(self.page),
                            @"limit":@"8"
                            };
    NSLog(@"——————>%@--->",param);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[LYAPIManager sharedInstance] POST:@"transportion/forunmPost/queryForunmPostByCondition" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"____%@",result);
        
        if ([result[@"errcode"] integerValue] == 0) {
            
            NSDictionary *data = result[@"data"];
            NSString *userID = [LYHelper getCurrentUserID];
            
            if (NotNilAndNull(data[@"iData"])) {
                
                NSArray *iData = data[@"iData"];
                for (NSDictionary *post in iData) {
                    
                    PostModel *model = [[PostModel alloc] init];
                    [model setValuesForKeysWithDictionary:post];
                    model.fkPostID = post[@"id"];
                    
                    model.userType = @"";
                    model.userName = @"";
                    model.isMine = @"0";
                    model.pOre = @"post";
                    
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
                        //NSLog(@"____%@",userInfoBase);
                        if ([userID isEqualToString:userInfoBase[@"id"]]) {
                            model.isMine = @"111";
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
                    //NSLog(@"_____%@______%@",model.type,model.isMine);
                    [self.dataArr addObject:model];
                }
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"885:%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        });
    }];
}


#pragma mark - getter

- (BBSTopView *)header {
    
    if (!_header) {
        
        _header = [[NSBundle mainBundle] loadNibNamed:@"BBSTopView" owner:nil options:nil].lastObject;
        _header.frame = CGRectMake(0, 0, kScreenSize.width, 80.f);
        _header.collectionView.tag = 888;
        _header.collectionView.delegate = self;
        _header.collectionView.dataSource = self;
        [_header.showBtn addTarget:self action:@selector(showAllKinds:) forControlEvents:UIControlEventTouchUpInside];
        _header.btn1.tag = 555;
        _header.btn1.selected = YES;
        [_header.btn1 addTarget:self action:@selector(sortNews:) forControlEvents:UIControlEventTouchUpInside];
        _header.btn2.tag = 556;
        [_header.btn2 addTarget:self action:@selector(sortNews:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _header;
}


- (void)sortNews:(UIButton *)sender {

    if (sender.isSelected) {
        
    }else {
        
        for (NSInteger i = 555; i < 557; i ++) {
            UIButton *btn = (UIButton *)[self.header viewWithTag:i];
            btn.selected = NO;
        }
        if (sender.tag == 555) {
            //NSLog(@"热门");
            self.hot = @"hot";
            self.date = @"";
        }else {
            //NSLog(@"最新");
            self.date = @"date";
            self.hot = @"";
        }
        sender.selected = YES;
        [self queryPostFromServiceReload:YES];
    }
}


- (ChooseThemeView *)moreView {

    if (!_moreView) {
        _moreView = [[NSBundle mainBundle] loadNibNamed:@"ChooseThemeView" owner:nil options:nil].lastObject;
        _moreView.frame = CGRectMake(0, 0, kScreenSize.width, kScreenSize.height);
        _moreView.cltView.tag = 999;
        _moreView.cltView.delegate = self;
        _moreView.cltView.dataSource = self;
        _moreView.hidden = YES;
        [_moreView.bkBt addTarget:self action:@selector(hideMoreKinds:) forControlEvents:UIControlEventTouchUpInside];
        [_moreView.tpBt addTarget:self action:@selector(hideMoreKinds:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreView;
}


- (void)showAllKinds:(UIButton *)sender {
    self.moreView.hidden = NO;
    [self.moreView.cltView reloadData];
}

- (void)hideMoreKinds:(UIButton *)sender {
    
    if (sender != nil) {
        self.moreView.hidden = YES;
        [self.header.collectionView reloadData];
    }
    [self queryPostFromServiceReload:YES];
}


- (ReleaseView *)leview {

    if (!_leview) {
        
        _leview = [[NSBundle mainBundle] loadNibNamed:@"ReleaseView" owner:nil options:nil].lastObject;
        _leview.frame = CGRectMake(0, 64, kScreenSize.width, kScreenSize.height - 64.f);
        _leview.dataArr1 = @[@"主题帖",@"视频帖"];
        _leview.dataArr2 = @[@"release1",@"release2"];
        _leview.tabView.tag = 1111;
        _leview.tabView.delegate = self;
        [_leview.bkBt addTarget:self action:@selector(hidLeView:) forControlEvents:UIControlEventTouchUpInside];
        _leview.hidden = YES;
    }
    return _leview;
}

- (void)hidLeView:(UIButton *)sender {
    self.leview.hidden = YES;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

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
        cell.deleteBt.hidden = YES;
        [cell paddingDataWith2:model];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    }else if(postType == 3){
        
        PostTCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"PostTCell1" forIndexPath:indexPath];
        cell.deleteBt.hidden = YES;
        cell.lifeVC = self;
        [cell paddingDataWith:model];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    }else if (postType == 2){

        PostCell3 *vCell = [tableView dequeueReusableCellWithIdentifier:@"PostCell3" forIndexPath:indexPath];
        [vCell paddingVideoDataWith:model];
        vCell.lifeVC = self;
        vCell.deleteBt.hidden = YES;
        vCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return vCell;
    }
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == 777) {
        
        PostModel *model = [self.dataArr objectAtIndex:indexPath.row];
        NSInteger type = [model.type integerValue];
        if (type == 1) {
            
            return 115.f;
            
        }else if (type == 3){
            
            return 120.f + kScreenSize.width * 0.3f;
        }
        
        return 215.f;
    }
    
    return 45.f;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (tableView.tag == 1111) {
        
        if (indexPath.row == 0) {
            
            TextViewController *textController = [[TextViewController alloc] init];
            [textController addPopItem];
            textController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:textController animated:YES];
            
        }else if (indexPath.row == 1){
            
            VideoViewController *videoController = [[VideoViewController alloc] init];
            [videoController addPopItem];
            videoController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:videoController animated:YES];
        }
        
        self.leview.hidden = YES;
        
    }else {
    
        
        PostModel *model = [self.dataArr objectAtIndex:indexPath.row];
        
        BBSDetailController *detail = [[BBSDetailController alloc] init];
        detail.postID = model.fkPostID;
        [detail addPopItem];
        detail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detail animated:YES];
        
    }
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


#pragma mark UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.kindsArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    KindsModel *model = [self.kindsArr objectAtIndex:indexPath.row];
    
    if (collectionView.tag == 888) {
        
        KindSCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KindSCell" forIndexPath:indexPath];
        [cell.markBt setTitle:model.text forState:UIControlStateNormal];
        
        if ([model.isNow integerValue] == 1) {
            
            cell.markIv.hidden = NO;
            cell.markBt.selected = YES;
            
        }else {
    
            cell.markIv.hidden = YES;
            cell.markBt.selected = NO;
        }
        return cell;
        
    }else {
    
        KindCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"KindCCell" forIndexPath:indexPath];
        [cell.bt setTitle:model.text forState:UIControlStateNormal];
        if ([model.isNow integerValue] == 1) {
            cell.bt.selected = YES;
        }else {
            cell.bt.selected = NO;
        }
        return cell;
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    for (NSInteger i = 0; i < self.kindsArr.count; i ++) {
        
        KindsModel *model = [self.kindsArr objectAtIndex:i];
        model.isNow = @"0";
        NSIndexPath *tmpIndex = [NSIndexPath indexPathForRow:i inSection:0];
        KindSCell *scell = (KindSCell *)[self.header.collectionView cellForItemAtIndexPath:tmpIndex];
        scell.markBt.selected = NO;
        scell.markIv.hidden = YES;
        KindCCell *ccell = (KindCCell *)[self.moreView.cltView cellForItemAtIndexPath:tmpIndex];
        ccell.bt.selected = NO;
    }
    
    KindsModel *model = [self.kindsArr objectAtIndex:indexPath.row];
    model.isNow = @"1";
    self.kindStr = model.kindID;
    
    KindSCell *scell = (KindSCell *)[self.header.collectionView cellForItemAtIndexPath:indexPath];
    scell.markBt.selected = YES;
    scell.markIv.hidden = NO;
    if (collectionView.tag == 888) {
        NSLog(@"_____%@",self.kindStr);
        [self hideMoreKinds:nil];
    }
    
    KindCCell *ccell = (KindCCell *)[self.moreView.cltView cellForItemAtIndexPath:indexPath];
    ccell.bt.selected = YES;
    
    [self.header.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:0 animated:YES];
}


- (void)playVideoWithUrlString:(NSString *)urlStr {
    if (IsNilOrNull(urlStr)) {
        return;
    }
    NSString *url = [NSString stringWithFormat:ImgLoadUrl,urlStr];
    NSLog(@"##———视频链接————%@",url);
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
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 50.f)];
        _footer.backgroundColor = [UIColor clearColor];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 1.f)];
        view.backgroundColor = LGrayColor;
        [_footer addSubview:view];
    }
    return _footer;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
