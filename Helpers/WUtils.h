//
//  WUtils.h
//  JiXiuBang_ShangJiaDuan
//
//  Created by apple on 15/11/24.
//  Copyright © 2015年 wenchanglin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WUtils : NSObject

#pragma 正则匹配手机号
+ (BOOL)checkTelNumber:(NSString *) telNumber;
#pragma 正则匹配用户密码6-18位数字和字母组合
+ (BOOL)checkPassword:(NSString *) password;
#pragma 正则匹配用户姓名,20位的中文或英文
+ (BOOL)checkUserName : (NSString *) userName;
#pragma 正则匹配用户身份证号
+ (BOOL)checkUserIdCard: (NSString *) idCard;


+ (BOOL)isBankCard:(NSString *) cardNumber;


@end
