//
//  CommentsTCell.m
//  LogisticsDriver
//
//  Created by Blues on 17/1/23.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "CommentsTCell.h"
#import "StarLevelView.h"
#import "CommentDTO.h"
#import "ImageCCell.h"

@implementation CommentsTCell{

    NSMutableArray *_imgs;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.header.layer.masksToBounds = YES;
    self.header.layer.cornerRadius = 21.f;
    CGFloat width = (kScreenSize.width - 82.f)/3.f;
    self.layout.itemSize = CGSizeMake(width, width);
    self.layout.minimumInteritemSpacing = 5.f;
    self.imgView.dataSource = self;
    self.imgView.delegate = self;
    [self.imgView registerNib:[UINib nibWithNibName:@"ImageCCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCCell"];
}

- (void)updateViewWithComment:(CommentDTO *)dto {
    
    if (_myDto != dto) {
        _myDto = dto;
    }
    if (NotNilAndNull(_myDto.userImg)) {
        NSString *url = [NSString stringWithFormat:ImgLoadUrl,_myDto.userImg];
        [self.header sd_setBackgroundImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal];
    }
    self.nickName.text = _myDto.userName;
    [self.starView setStarLevel:[_myDto.quality doubleValue]];
    self.dateLb.text = [LYHelper justDateStringWithInterval:_myDto.createTime dateFM:nil];
    self.contentLb.text = _myDto.content;
    if (NotNilAndNull(_myDto.imageArr)) {
        _imgs = [_myDto.imageArr copy];
        [self.imgView reloadData];
    }
    if (_myDto.isCan) {
        self.replyBt.hidden = NO;
    }else {
        self.replyBt.hidden = YES;
    }
}

- (IBAction)replyUser:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(replyUserWithfkOrderId:)]) {
        [self.delegate replyUserWithfkOrderId:_myDto.fkTransId];
    }
}

#pragma mark - Images
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imgs.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ImageCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCCell" forIndexPath:indexPath];
    NSString *urlStr = [_imgs objectAtIndex:indexPath.row];
    NSString *url = [NSString stringWithFormat:ImgLoadUrl,urlStr];
    [cell.iv sd_setImageWithURL:[NSURL URLWithString:url]];
    cell.deleteBt.hidden = YES;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
