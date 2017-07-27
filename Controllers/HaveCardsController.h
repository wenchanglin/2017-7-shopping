//
//  HaveCardsController.h
//  885logistics
//
//  Created by Blues on 17/3/29.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseViewController.h"

@class BCardsModel;

@protocol HaveCardsControllerDelegate <NSObject>

- (void)updateLastController:(BCardsModel *)model;

@end


@interface HaveCardsController : BaseViewController

@property (nonatomic, weak) id<HaveCardsControllerDelegate> delegate;

@end
