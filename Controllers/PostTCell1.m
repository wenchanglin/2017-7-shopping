//
//  PostTCell1.m
//  885logistics
//
//  Created by Blues on 17/1/10.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "PostTCell1.h"
#import "ImageCCell.h"
#import "PostModel.h"


@implementation PostTCell1

- (void)awakeFromNib {
    [super awakeFromNib];

    self.header.layer.masksToBounds = YES;
    self.header.layer.cornerRadius = 21.f;
    self.dataArr = [[NSMutableArray alloc]init];
    CGFloat width = (kScreenSize.width - 80.f)/3.f;
    self.layout.itemSize = CGSizeMake(width, width);
    self.layout.minimumInteritemSpacing = 5.f;
    self.layout.minimumLineSpacing = 5.f;
    self.imgView.dataSource = self;
    self.imgView.delegate = self;
    [self.imgView registerNib:[UINib nibWithNibName:@"ImageCCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCCell"];
}

- (void)paddingDataWith:(PostModel *)model {
    
    if (_model != model) {
        _model = model;
    }
    if (NotNilAndNull(_model.userImgUrl)) {
        if (model.userImgUrl.length) {
            NSString *urlStr = [NSString stringWithFormat:ImgLoadUrl,model.userImgUrl];
            [self.header sd_setBackgroundImageWithURL:[NSURL URLWithString:urlStr] forState:UIControlStateNormal];
        }
    }
    self.nameLb.text = model.userName;
    if ([model.userType isEqualToString:@"employ"]) {
        self.typeLb.text = @"【普通用户】";
        self.nameLb.textColor = MainYellowColor;
    }else {
        self.typeLb.text = @"【司机】";
        self.nameLb.textColor = MainColor;
    }
    self.titleLb.text = model.title;
    self.contentLb.text = model.content;
    self.dateLb.text = [LYHelper justDateStringWithInterval:model.createTime];
    [self.replyBt setTitle:[model.fkEvaNum stringValue] forState:UIControlStateNormal];
    if (model.images) {
        self.dataArr = [model.images mutableCopy];
        [self.imgView reloadData];
    }
}


#pragma mark - Images
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

- (IBAction)deleteClicked:(id)sender {
    [self.lifeVC deletePostWithPostID:_model];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
