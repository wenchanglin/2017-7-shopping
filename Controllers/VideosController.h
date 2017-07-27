//
//  VideosController.h
//  885logistics
//
//  Created by Blues on 17/1/18.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseViewController.h"

@class VideoModel;

typedef void(^ReturnBlock)(VideoModel *vModel);

@interface VideosController : BaseViewController

@property (nonatomic, copy) ReturnBlock myBlock;


- (void)cameSetMyBlock:(ReturnBlock)block;


@end
