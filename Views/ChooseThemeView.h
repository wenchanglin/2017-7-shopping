//
//  ChooseThemeView.h
//  885logistics
//
//  Created by Blues on 17/1/4.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseThemeView : UIView 

@property (weak, nonatomic) IBOutlet UIButton *bkBt;
@property (weak, nonatomic) IBOutlet UIButton *tpBt;

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (weak, nonatomic) IBOutlet UICollectionView *cltView;

@property (nonatomic, strong) NSMutableArray *dataArr;


@end
