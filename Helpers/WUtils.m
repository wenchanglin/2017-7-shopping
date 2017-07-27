//
//  WUtils.m
//  JiXiuBang_ShangJiaDuan
//
//  Created by apple on 15/11/24.
//  Copyright © 2015年 wenchanglin. All rights reserved.
//

#import "WUtils.h"


@implementation WUtils

// 正则匹配 手机号
+ (BOOL)checkTelNumber:(NSString *) telNumber
{
    NSString *pattern = @"^1[3|4|5|7|8][0-9]\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:telNumber];
    return isMatch;
}


// 匹配用户密码6-18位数字和字母组合
+ (BOOL)checkPassword:(NSString *) password
{
    NSString *pattern = @"^[a-zA-Z0-9]{6,20}+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:password];
    return isMatch;
}


// 正则匹配用户姓名,20位的中文或英文
+ (BOOL)checkUserName : (NSString *) userName
{
    NSString *pattern = @"^[a-zA-Z一-龥]{1,20}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:userName];
    return isMatch;
}

// 身份证验证
+ (BOOL)checkUserIdCard:(NSString *)idCard
{
    NSString *pattern = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:idCard];
    return isMatch;
}


+ (BOOL)isBankCard:(NSString *) cardNumber
{
    if (cardNumber.length != 19) {
        return NO;
    }
    NSString *first = [cardNumber substringToIndex:1];
    if ([first isEqualToString:@"6"]) {
        return YES;
    }else {
        return NO;
    }
}




@end
