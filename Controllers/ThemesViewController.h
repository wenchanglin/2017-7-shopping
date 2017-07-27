//
//  BankListController.h
//  CustomFurniture
//
//  Created by Blues on 16/11/15.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KindsModel;

typedef void(^returnBlock)(KindsModel *);

@interface ThemesViewController : UIViewController

@property (nonatomic, assign) NSInteger kindtype;

@property (nonatomic, copy) returnBlock mBlock;


- (void)cameGetMy:(returnBlock)block;

@end
