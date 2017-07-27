//
//  DetailCell1.m
//  885logistics
//
//  Created by Blues on 17/2/13.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "DetailCell1.h"
#import "ImageCCell.h"
#import "PostModel.h"


@implementation DetailCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.moreView bringSubviewToFront:self.leView];
    self.header.layer.masksToBounds = YES;
    self.header.layer.cornerRadius = 21.f;
    self.dataArr = [[NSMutableArray alloc]init];
    CGFloat width = (kScreenSize.width - 35.f)/3.f;
    CGFloat height = kScreenSize.width * 0.29f;
    self.layout.itemSize = CGSizeMake(width, height);
    self.layout.minimumInteritemSpacing = 8.f;
    self.layout.minimumLineSpacing = 0.f;
    self.imgView.dataSource = self;
    self.imgView.delegate = self;
    [self.imgView registerNib:[UINib nibWithNibName:@"ImageCCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCCell"];
}

- (void)paddingDataWith1:(PostModel *)model cellType:(NSInteger)type {
    
    if (_model != model) {
        _model = model;
    }
    if (NotNilAndNull(_model.userImgUrl)) {
        if (_model.userImgUrl.length) {
            NSString *urlStr = [NSString stringWithFormat:ImgLoadUrl,_model.userImgUrl];
            [self.header sd_setBackgroundImageWithURL:[NSURL URLWithString:urlStr] forState:UIControlStateNormal];
        }
    }
    self.nameLb.text = _model.userName;
    if ([model.userType isEqualToString:@"employ"]) {
        self.typeLb.text = @"【普通用户】";
        self.nameLb.textColor = MainYellowColor;
    }else {
        self.typeLb.text = @"【司机】";
        self.nameLb.textColor = MainColor;
    }
    if (type == 2) {
        self.titleLb.text = _model.content;
        self.contentLb.text = @"";
    }else if (type == 1){
        self.titleLb.text = _model.title;
        self.contentLb.text = _model.content;
    }
    self.dateLb.text = [LYHelper justDateStringWithInterval:_model.createTime];
    if (model.images) {
        self.dataArr = [_model.images mutableCopy];
        [self.imgView reloadData];
    }
}

// 举报
- (IBAction)report1Clicked:(id)sender {
    [self.lifeVC reportPostWithPostID:_model];
}
// 下拉视图
- (IBAction)moreClicked:(id)sender {
    self.moreView.hidden = NO;
}

// 收起下拉
- (IBAction)hideClicked:(id)sender {
    self.moreView.hidden = YES;
}
// 回复
- (IBAction)replyClicked:(id)sender {
    [self.lifeVC replyPostWithPostID:_model];
    self.moreView.hidden = YES;
}
// 举报 2
- (IBAction)report2Ciicked:(id)sender {
    [self.lifeVC reportPostWithPostID:_model];
    self.moreView.hidden = YES;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCCell" forIndexPath:indexPath];
    NSString *urlStr = [self.dataArr objectAtIndex:indexPath.row];
    if (urlStr.length) {
        NSString *url = [NSString stringWithFormat:ImgLoadUrl,urlStr];
        [cell.iv sd_setImageWithURL:[NSURL URLWithString:url]];
    }else {
        cell.iv.image = nil;
    }
    cell.deleteBt.hidden = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (_model.images.count) {
        
        DisplayImagesVC *display = [[DisplayImagesVC alloc] init];
        [display setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        display.images = [_model.images mutableCopy];
        display.off = indexPath.row + 1;
        if (UIDevice.currentDevice.systemVersion.integerValue >= 8){
            //For iOS 8
            display.providesPresentationContextTransitionStyle = true;
            display.definesPresentationContext = true;
            display.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            display.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        }else{
            //For iOS 7
            display.modalPresentationStyle = UIModalPresentationCurrentContext;
            display.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        }
        [self.lifeVC presentViewController:display animated:YES completion:nil];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
