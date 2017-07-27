//
//  OfferViewController.h
//  LogisticsDriver
//
//  Created by Blues on 17/3/13.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OfferViewControllerDelegate <NSObject>

- (void)offerPriceForOrder:(NSString *)someStr;

@end

@interface OfferViewController : UIViewController

@property (nonatomic, weak) id<OfferViewControllerDelegate> delegate;



@end
