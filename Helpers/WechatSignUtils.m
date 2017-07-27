//
//  WechatSignUtils.m
//  form-data_upload_demo
//
//  Created by Zhibo Wang on 16/6/16.
//  Copyright © 2016年 Zhibo Wang. All rights reserved.
//

#import "WechatSignUtils.h"
#import "NSString+MD5.h"

@implementation WechatSignUtils

+ (NSString *)sign:(NSDictionary *)info {
    NSMutableArray *keys = [NSMutableArray array];
    
    for (NSString *key in info) {
        if (info[key]) {
            [keys addObject:key];
        }
    }
    
    [keys sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableString *mutStr = [NSMutableString string];
    for (NSString *key in keys) {
        
        if (mutStr.length) {
            [mutStr appendString:@"&"];
        }
        [mutStr appendString:key];
        [mutStr appendString:@"="];
        [mutStr appendString:info[key]];
    }
    
    [mutStr appendString:@"&key=daup13588080831daup13588080831da"];
    
    NSLog(@"＝＝＝＝＝＝＝未使用API签名＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝%@",mutStr);
    
    NSString *sign = [mutStr MD5Digest];

    return [sign uppercaseString];
}

@end
