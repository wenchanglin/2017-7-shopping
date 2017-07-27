//
//  ChooseThemeView.m
//  885logistics
//
//  Created by Blues on 17/1/4.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "ChooseThemeView.h"
#import "KindCCell.h"


@implementation ChooseThemeView


- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.layout.itemSize = CGSizeMake((kScreenSize.width - 20.f - 20.f)/5.f, 30.f);
    self.layout.minimumLineSpacing = 8.f;
    self.layout.minimumInteritemSpacing = 5.f;
    self.layout.sectionInset = UIEdgeInsetsMake(5.f, 10.f, 0, 10.f);
    
    [self.cltView  registerNib:[UINib nibWithNibName:@"KindCCell" bundle:nil] forCellWithReuseIdentifier:@"KindCCell"];
}











/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
