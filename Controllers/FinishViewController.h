//
//  FinishViewController.h
//  LogisticsDriver
//
//  Created by Blues on 17/3/17.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^JustMsgBackkBlock)(void);

@interface FinishViewController : UIViewController

@property (nonatomic, copy) JustMsgBackkBlock myBlock;

@property (nonatomic, strong) NSString *msg;

- (instancetype)initWithJsbblock:(JustMsgBackkBlock)block;


@end
