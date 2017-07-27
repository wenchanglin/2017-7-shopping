//
//  LYHelper.h
//  CustomFurniture
//
//  Created by Blues on 16/11/16.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>

@interface LYHelper : NSObject


+ (NSString *)converTypeStr:(NSString *)oldStr;

+ (BOOL)notLogin;

+ (BOOL)isWorkNow;

+ (NSString *)getOrderStatus:(NSString *)status;

+ (NSString *)getCurrentUserID;

+ (NSString *)getCurrentCityName;

+ (NSString *)getFullPathWithFile:(NSString *)urlName;

+ (BOOL)isTimeInWithFile:(NSString *)filePath timeOut:(double)timeOut;

+ (NSString *)justDateStringWithInterval:(NSNumber *)interval;

+ (NSString *)justDateStringWithInterval:(NSNumber *)interval dateFM:(NSString *)fm;

+ (void)loginRongCloud;

+ (RCUserInfo *)getCurrentRCUser;

+ (void)refreshUserInfo;


@end
