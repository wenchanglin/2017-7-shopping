//
//  BaseViewController.h
//  885logistics
//
//  Created by Blues on 17/1/3.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostModel,AddressModel;

@interface BaseViewController : UIViewController

// 子类实现
- (void)initData;
- (void)queryDataFromServer;
- (void)createViews;

// 子类继承
- (void)addPopItem;
// 导航返回
- (void)popCurrentView:(UIBarButtonItem *)item;

#pragma 论坛帖子
/* 删除帖子 */
- (void)deletePostWithPostID:(PostModel *)model;
/* 播放视频 */
- (void)playVideoWithUrlString:(NSString *)urlStr;
/* 举报帖子 */
- (void)reportPostWithPostID:(PostModel *)model;
/* 回复评论 */
- (void)replyPostWithPostID:(PostModel *)model;

#pragma 地址管理
- (void)doSomethingWithASModel:(AddressModel *)model;

#pragma 公用
- (void)somethingNeedAction1;

- (void)somethingNeedAction2;

#pragma 提示语
- (void)showMessageForUser:(NSString *)message;

@end
