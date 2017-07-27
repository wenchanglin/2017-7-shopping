//
//  NewsModel.h
//  885logistics
//
//  Created by Blues on 17/1/9.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseModel.h"

@interface NewsModel : BaseModel

@property (nonatomic, copy) NSString *fkMsgId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *msgOption;
@property (nonatomic, copy) NSString *customized;// 添加好友验证消息
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *fkForumId;// 帖子ID
@property (nonatomic, copy) NSNumber *createTime;


@end
