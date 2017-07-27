//
//  CityCCell.h
//  LogisticsDriver
//
//  Created by Blues on 17/3/14.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CityModel;

@protocol CityCCellDelegate <NSObject>

- (void)deleteCityModel:(CityModel *)model;

- (void)moreCityModel:(CityModel *)model;

@end

@interface CityCCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *bkView;
@property (weak, nonatomic) IBOutlet UILabel *cityLb;
@property (weak, nonatomic) IBOutlet LYButton *bt;
@property (nonatomic, weak) id<CityCCellDelegate> delegate;
@property (nonatomic, strong) CityModel *myModel;

- (void)updateViewWithCity:(CityModel *)model;


@end
