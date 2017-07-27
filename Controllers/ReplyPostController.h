//
//  ReplyPostController.h
//  885logistics
//
//  Created by Blues on 17/2/14.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseViewController.h"

@class PostModel;

@interface ReplyPostController : BaseViewController

@property (nonatomic, strong) PostModel *model;
@property (nonatomic, copy) NSString *fkPostId;
@property (nonatomic, copy) NSString *fkEvaId;


@end
