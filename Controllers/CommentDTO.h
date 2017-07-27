//
//  CommentDTO.h
//  LogisticsDriver
//
//  Created by Blues on 17/3/21.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseModel.h"

@interface CommentDTO : BaseModel

@property (nonatomic, copy) NSString *fkDataId;
@property (nonatomic, assign) BOOL isCan;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSNumber *createTime;
@property (nonatomic, copy) NSString *fkDriverId;
@property (nonatomic, copy) NSString *fkCommentId;//数据id
@property (nonatomic, copy) NSString *fkTransId;
@property (nonatomic, copy) NSString *fkUserId;
@property (nonatomic, copy) NSNumber *quality;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userImg;
@property (nonatomic, strong) NSMutableArray *imageArr;//图片数组

@property (nonatomic, copy) NSString *type;

@end
