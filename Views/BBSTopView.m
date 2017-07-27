//
//  BBSTopView.m
//  885logistics
//
//  Created by Blues on 17/1/5.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BBSTopView.h"

@implementation BBSTopView

- (void)awakeFromNib {

    [super awakeFromNib];
    CGFloat ItemW   = (kScreenSize.width - 66.f)/6.f;
    CGFloat height  = 42.f;

    self.layout.itemSize = CGSizeMake(ItemW, height);
    self.layout.minimumLineSpacing = 1;
    self.layout.minimumInteritemSpacing = 1;
    [self.collectionView  registerNib:[UINib nibWithNibName:@"KindSCell" bundle:nil] forCellWithReuseIdentifier:@"KindSCell"];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
