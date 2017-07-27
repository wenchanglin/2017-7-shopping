//
//  ReplyCell.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/20.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "ReplyCell.h"
#import "CommentDTO.h"
#import "ImageCCell.h"


@implementation ReplyCell {

    NSMutableArray *_imgs;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
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
    self.contentLb.text = _myDto.content;
    if (NotNilAndNull(_myDto.imageArr)) {
        _imgs = [_myDto.imageArr copy];
        [self.imgView reloadData];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
