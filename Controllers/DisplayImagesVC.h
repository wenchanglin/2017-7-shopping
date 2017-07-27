//
//  DisplayImagesVC.h
//  DAup
//
//  Created by Blues on 16/9/21.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^hideBlock)(void);

@interface DisplayImagesVC : UIViewController

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic) NSInteger off;
@property (nonatomic, copy) hideBlock myblock;

- (void)hideTabbarWithBlock:(hideBlock)block;

@end
