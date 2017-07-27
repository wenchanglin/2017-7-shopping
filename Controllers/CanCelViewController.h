//
//  CanCelViewController.h
//  885logistics
//
//  Created by Blues on 17/3/15.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CanCelViewControllerDelegate <NSObject>

- (void)cancelOrderWithReason:(NSString *)reason;

@end

@interface CanCelViewController : UIViewController

@property (nonatomic, weak) id<CanCelViewControllerDelegate> delegate;

@end
