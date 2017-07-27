//
//  DetailViewController.h
//  885logistics
//
//  Created by Blues on 17/1/12.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseViewController.h"


@class UserModel;

@interface DetailViewController : BaseViewController

@property (nonatomic, strong) UserModel *model;

@property (nonatomic, strong) NSString *justBack;

@end
