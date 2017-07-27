//
//  HomeViewController.m
//  OneDropCarConsultant
//
//  Created by mc on 16/1/27.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "StarLevelView.h"

@implementation StarLevelView
{
    UIImageView *_backImageView;
    UIImageView *_foreImageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self creatView];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self creatView];
    }
    return self;
}

- (void)creatView
{
    _backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 65, 23)];
    _backImageView.image = [UIImage imageNamed:@"StarsBackground"];
    _backImageView.contentMode = UIViewContentModeLeft;

    [self addSubview:_backImageView];
    

    _foreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 65, 23)];
    _foreImageView.image = [UIImage imageNamed:@"StarsForeground"];
    _foreImageView.contentMode = UIViewContentModeLeft;
    
    _foreImageView.clipsToBounds = YES;
    [self addSubview:_foreImageView];
}

- (void)setStarLevel:(double)level {
    _foreImageView.frame = CGRectMake(0, 0, _backImageView.frame.size.width*(level/5.0), 23);
}
@end
