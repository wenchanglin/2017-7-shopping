//
//  PickPDTController.h
//  CustomFurniture
//
//  Created by Blues on 16/11/3.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//


#import <UIKit/UIKit.h>


typedef void(^PDTBlock)(NSDictionary *pdt);

typedef void(^SerPDTBlock)(NSDictionary *Spdt);

typedef void(^HideBlock)(void);


@interface PickPDTController : UIViewController

@property (nonatomic, copy) PDTBlock pdtBlock;

@property (nonatomic, copy) HideBlock hideBlock;

@property (nonatomic, copy) SerPDTBlock serBlock;



- (void)cameSetserBlock:(SerPDTBlock)sBlock;

- (void)cameSetHideBlock:(HideBlock)block;

- (void)cameSetMy:(PDTBlock)block;




@end
