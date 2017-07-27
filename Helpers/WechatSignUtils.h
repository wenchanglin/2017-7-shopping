//
//  WechatSignUtils.h
//  form-data_upload_demo
//
//  Created by Zhibo Wang on 16/6/16.
//  Copyright © 2016年 Zhibo Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WechatSignUtils : NSObject

+(NSString *)sign:(NSDictionary *)info;

@end
