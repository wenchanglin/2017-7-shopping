//
//  PostModel.h
//  885logistics
//
//  Created by Blues on 17/2/7.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseModel.h"

@interface PostModel : BaseModel
/*
 "id": "18bad6aa-f0a5-4f55-a559-f9edc8f79238",
 "type": "图片帖",
 "differ": "post",
 "fkUserId": "f2b594ee-4290-4772-aa61-3f3be46d2c8e",
 "fkComnId": "ce785507-8052-47d7-80a3-d47286af6edd",
 "title": "南京定位帖子内容测试",
 "content": "南京生活好",
 "location": "南京",
 "fkEvaNum": 6,
 "repNum": 0,
 "createTime": 1484129152000,
 "delFlag": 0,
 "postPhoto"
 */

@property (nonatomic, copy) NSString *fkPostID;//数据ID

@property (nonatomic, copy) NSString *type; // 帖子类型 1、无图 3、有图 2、视频
@property (nonatomic, copy) NSString *canAnswer; // 是否可以回复
@property (nonatomic, copy) NSString *differ;
@property (nonatomic, copy) NSString *fkUserId;
@property (nonatomic, copy) NSString *fkComnId;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *videoImageUrl;
@property (nonatomic, copy) NSNumber *createTime;

@property (nonatomic, copy) NSString *userName;//昵称
@property (nonatomic, copy) NSString *userImgUrl;// 发布者/头像
@property (nonatomic, copy) NSString *userType;// 司机/用户

@property (nonatomic, copy) NSNumber *repNum;// 回复数
@property (nonatomic, copy) NSNumber *fkEvaNum;// 评论次数
@property (nonatomic, strong) NSMutableArray *images;// 图片数

@property (nonatomic, copy) NSString *isMine;
@property (nonatomic, copy) NSString *pOre;


@end
