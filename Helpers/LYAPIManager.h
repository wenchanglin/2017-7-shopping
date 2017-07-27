//
//  LYAPIManager.h
//  CustomFurniture
//
//  Created by Blues on 16/11/14.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//
//

#import <AFNetworking/AFNetworking.h>

@interface LYAPIManager : AFHTTPSessionManager

@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, strong) NSMutableArray *homeArr;


+ (LYAPIManager *)sharedInstance;

// 图片上传
+ (void)uploadImagesWithPostID:(NSString *)postID goal:(NSString *)goal imageData:(NSArray *)images;

//回复评论图片上传
+ (void)uploadEvaImageWithEvaID:(NSString *)evaID image:(UIImage *)image;

//评论图片上传
+ (void)uploadReplyImageWithReplyID:(NSString *)replyID image:(UIImage *)image;


+ (void)showMessageForUser:(NSString *)message;



@end

