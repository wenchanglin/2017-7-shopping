//
//  VideosController.m
//  885logistics
//
//  Created by Blues on 17/1/18.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "VideosController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VideoCCell.h"
#import "VideoModel.h"


@interface VideosController ()<UICollectionViewDataSource,UICollectionViewDelegate>{
    
}

@property (nonatomic, strong) MPMoviePlayerViewController *mp;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIBarButtonItem *navItem;

@property (nonatomic, strong) VideoModel  *myModel;

@end

@implementation VideosController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)initData {
    
    self.myModel = nil;
    self.dataArr = [NSMutableArray new];
    
    
}

- (void)createViews {
    
    self.navigationItem.title = @"添加视频";
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    layout.itemSize = CGSizeMake((kScreenSize.width - 13.f)/4.f, (kScreenSize.width - 13.f)/4.f);
    layout.headerReferenceSize = CGSizeMake(0, 0);
    layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 2, kScreenSize.width, kScreenSize.height-66.f) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"VideoCCell" bundle:nil] forCellWithReuseIdentifier:@"VideoCCell"];
    
    [self.view addSubview:self.collectionView];
    
    [self localVideos];
}

- (void)cameSetMyBlock:(ReturnBlock)block {
    self.myBlock = block;
}


- (void)localVideos {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group) {
            
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                
                if (result) {
                    
                    VideoModel *vModel = [[VideoModel alloc] init];
                    vModel.thumbnail = [UIImage imageWithCGImage:result.thumbnail];
                    vModel.videoURL = result.defaultRepresentation.url;
                    NSNumber *duration = [result valueForProperty:ALAssetPropertyDuration];
                    vModel.duration = [duration floatValue]/100.f;
                    vModel.name = [self getFormatedDateStringOfDate:[result valueForProperty:ALAssetPropertyDate]];
                    vModel.size = result.defaultRepresentation.size; //Bytes
                    vModel.format = [result.defaultRepresentation.filename pathExtension];
                    vModel.isSlt = @"0";
                    
                    NSLog(@"____视频地址__%@",vModel.videoURL);
                    [self.dataArr addObject:vModel];
                }
            }];
        }else {
            //没有更多的group时，即可认为已经加载完成。
            //NSLog(@"after load, the total alumvideo count is %ld",_albumVideoInfos.count);
        }
        
        [self.collectionView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    } failureBlock:^(NSError *error) {
        //NSLog(@"Failed.");
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}


- (UIBarButtonItem *)navItem {
    
    if (!_navItem) {
        _navItem = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(chooseVideo)];
        _navItem.tintColor = [UIColor whiteColor];
        [_navItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    }
    return _navItem;
}

- (void)chooseVideo {
    
    if (self.myBlock && self.myModel) {
        self.myBlock(self.myModel);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


//将创建日期作为文件名
- (NSString *)getFormatedDateStringOfDate:(NSDate*)date {
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"]; //注意时间的格式：MM表示月份，mm表示分钟，HH用24小时制，小hh是12小时制。
    NSString* dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    VideoCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCCell" forIndexPath:indexPath];
    VideoModel *model = [self.dataArr objectAtIndex:indexPath.row];
    cell.iv.image = model.thumbnail;
    cell.timeLb.text = [NSString stringWithFormat:@"%.2f",model.duration];
    if ([model.isSlt integerValue] == 1) {
        cell.selBt.selected = YES;
    }else {
        cell.selBt.selected = NO;
    }
    cell.selBt.tag = 100 + indexPath.row;
    [cell.selBt addTarget:self action:@selector(cancelSelect:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)cancelSelect:(UIButton *)sender {

    sender.selected = !sender.selected;
    NSInteger current = sender.tag - 100;
    for (NSInteger i = 0; i < self.dataArr.count; i ++) {
        
        VideoModel *model = [self.dataArr objectAtIndex:i];
        if (i == current) {
            if (sender.selected) {
                model.isSlt = @"1";
                self.navigationItem.rightBarButtonItems = @[self.navItem];
                self.myModel = model;
            }else {
                model.isSlt = @"0";
                self.navigationItem.rightBarButtonItems = @[];
                self.myModel = nil;
            }
        }else {
            model.isSlt = @"0";
        }
    }
    [self.collectionView reloadData];
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    VideoModel *model = [self.dataArr objectAtIndex:indexPath.row];
    [self playVideoWithPath:model.videoURL];
}


#pragma mark - 播放视频
- (void)playVideoWithPath:(NSURL *)url {

    //增加观察者 视频播放完毕或者点击Done
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playBack:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    self.mp = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    self.mp.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    self.mp.moviePlayer.shouldAutoplay = YES;
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
