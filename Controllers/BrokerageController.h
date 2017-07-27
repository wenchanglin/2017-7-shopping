//
//  BrokerageController.h
//  LogisticsDriver
//
//  Created by Blues on 17/3/18.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol BrokerageControllerDelegate <NSObject>

- (void)payWithCoupon:(NSString *)coupon;

@end

@interface BrokerageController : UIViewController

@property (nonatomic, weak) id<BrokerageControllerDelegate> delegate;

@end
