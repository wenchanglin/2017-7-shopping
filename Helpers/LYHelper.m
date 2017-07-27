//
//  LYHelper.m
//  CustomFurniture
//
//  Created by Blues on 16/11/16.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "LYHelper.h"
#import "NSString+MD5.h"
#import <CoreLocation/CoreLocation.h>


@implementation LYHelper


+ (NSString *)justDateStringWithInterval:(NSNumber *)interval {
    
    NSTimeInterval intval = [interval doubleValue];
    intval = intval/1000;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:intval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)justDateStringWithInterval:(NSNumber *)interval dateFM:(NSString *)fm {
    
    if (!fm) {
        fm = @"yyyy-MM-dd HH:mm:ss";
    }
    NSTimeInterval intval = [interval doubleValue];
    intval = intval/1000;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:intval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:fm];
    
    return [dateFormatter stringFromDate:date];
}


//获取 一个文件 在沙盒Library/Caches/ 目录下的路径
+ (NSString *)getFullPathWithFile:(NSString *)urlName {
    
    //先获取 沙盒中的Library/Caches/路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *myCacheDirectory = [docPath stringByAppendingPathComponent:@"MyCaches"];
    //检测MyCaches 文件夹是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:myCacheDirectory]) {
        //不存在 那么创建
        [[NSFileManager defaultManager] createDirectoryAtPath:myCacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //用md5进行 加密 转化为 一串十六进制数字 (md5加密可以把一个字符串转化为一串唯一的用十六进制表示的串)
    NSString *newName = [urlName MD5Digest];
    //拼接路径
    return [myCacheDirectory stringByAppendingPathComponent:newName];
}


//检测 缓存文件 是否超时
+ (BOOL)isTimeInWithFile:(NSString *)filePath timeOut:(double)timeOut {
    //获取文件的属性
    NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    //获取文件的上次的修改时间
    NSDate *lastModfyDate = fileDict.fileModificationDate;
    //算出时间差 获取当前系统时间 和 lastModfyDate时间差
    NSTimeInterval sub = [[NSDate date] timeIntervalSinceDate:lastModfyDate];
    if (sub < 0) {
        sub = -sub;
    }
    //比较是否超时
    if (sub > timeOut) {
        //如果时间差 大于 设置的超时时间 那么就表示超时
        return NO;
    }
    return YES;
}


+ (NSString *)getCurrentUserID {
    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"User"];
    if (user) {
        return user[@"id"];
    }
    return @"";
}


+ (BOOL)isWorkNow {

    NSString *status = [[NSUserDefaults standardUserDefaults] objectForKey:@"Status"];
    if (status) {
        if ([status isEqualToString:@"ON"]) {
            return YES;
        }
    }
    return NO;
}


+ (BOOL)notLogin {

    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"User"];
    if (user) {
        return NO;
    }
    return YES;
}


+ (NSString *)converTypeStr:(NSString *)oldStr {

    if (oldStr) {
        NSString *subStr = [oldStr substringWithRange:NSMakeRange(1, oldStr.length - 2)];
        return subStr;
    }
    return @"";
}


+ (NSString *)getOrderStatus:(NSString *)status {
    if (status) {
        NSArray *array = [status componentsSeparatedByString:@"_"];
        return array.lastObject;
    }
    return @"";
}

+ (NSString *)getCurrentCityName {
    
    NSString *city = [[NSUserDefaults standardUserDefaults] objectForKey:@"location"];
    if (city) {
        return city;
    }
    return @"";
}

+ (RCUserInfo *)getCurrentRCUser {
    NSString *user = [LYHelper getCurrentUserID];
    if (IsEmptyStr(user)) {
        return nil;
    }
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"];
    NSString *imgUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"ImageUrl"];
    RCUserInfo *rcUser = [[RCUserInfo alloc] initWithUserId:user name:userName portrait:imgUrl];
    NSLog(@"当前用户——%@----%@---%@",rcUser.name,rcUser.portraitUri,rcUser.userId);
    return rcUser;
}

+ (void)refreshUserInfo {
    
    NSString *user = [LYHelper getCurrentUserID];
    if (IsEmptyStr(user)) {
        return;
    }
    RCUserInfo *rcUser = [LYHelper getCurrentRCUser];
    [[RCIM sharedRCIM] refreshUserInfoCache:rcUser withUserId:user];
}

+ (void)loginRongCloud {
    
    if ([LYHelper notLogin]) {
        return;
    }
    NSDictionary *param = @{@"userId":[LYHelper getCurrentUserID]};
    
    [[LYAPIManager sharedInstance] POST:@"transportion/rongYun/getUserToken" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"___RongCloudToken____%@",result);
        if ([result[@"errcode"] integerValue] == 0) {
            
            id Objc = result[@"data"];
            if (NotNilAndNull(Objc)) {
                NSString *token = result[@"data"];
                [[RCIM sharedRCIM] connectWithToken:token success:^(NSString *userId) {
                    NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
                } error:^(RCConnectErrorCode status) {
                    NSLog(@"登陆的错误码为:%ld", (long)status);
                } tokenIncorrect:^{
                    NSLog(@"token错误");
                }];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}



@end
