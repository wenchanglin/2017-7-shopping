//
//  ALineTCell.h
//  LogisticsDriver
//
//  Created by Blues on 17/1/23.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LineModel;

@protocol ALineTCellDelegate <NSObject>
- (void)moreLineWithLineID:(LineModel *)line;
@end

@interface ALineTCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *wayLongLb;
@property (weak, nonatomic) IBOutlet UILabel *fAera;
@property (weak, nonatomic) IBOutlet UILabel *fDetail;
@property (weak, nonatomic) IBOutlet UILabel *sAera;
@property (weak, nonatomic) IBOutlet UILabel *sDetail;
@property (weak, nonatomic) IBOutlet UILabel *dayLong;
@property (weak, nonatomic) IBOutlet UIButton *moreBt;

@property (nonatomic, weak) id<ALineTCellDelegate> delegate;

@property (nonatomic, strong) LineModel *myModel;

- (void)updateViewWithLine:(LineModel *)model;


@end
