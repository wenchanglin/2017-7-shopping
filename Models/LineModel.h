//
//  LineModel.h
//  LogisticsDriver
//
//  Created by Blues on 17/3/14.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseModel.h"

@interface LineModel : BaseModel

/*
 createTime = 1488773934000;
 delFlag = 0;
 detailEndAddr = "\U62f1\U5885\U533a\U7965\U56ed\U8def39\U53f7";
 detailStarAddr = "\U7ea2\U661f\U8def106\U53f7";
 endX = "30.341199";
 endY = "120.118221";
 id = "c4847b8c-595a-4de7-a776-9f0ba68bc306";
 lineDay = 14;
 lineEnd = "\U6d59\U6c5f\U7701\U676d\U5dde\U5e02";
 lineLong = 800;
 lineStart = "\U5929\U6d25\U5e02\U6cb3\U5317\U533a";
 m = "661.5";
 startX = "39.161495";
 startY = "117.240831";
 status = 0;
 way = "\U5f88\U591a\U7684\U57ce\U5e02\U7701\U7565\U5566";
 
 */

@property (nonatomic, copy) NSString *fkLineId;
@property (nonatomic, copy) NSNumber *status;
@property (nonatomic, copy) NSString *detailEndAddr;
@property (nonatomic, copy) NSString *lineEnd;
@property (nonatomic, copy) NSString *detailStarAddr;
@property (nonatomic, copy) NSString *lineStart;
@property (nonatomic, copy) NSNumber *m;
@property (nonatomic, copy) NSString *way;
@property (nonatomic, copy) NSNumber *lineDay;
@property (nonatomic, copy) NSNumber *lineLong;


@end
