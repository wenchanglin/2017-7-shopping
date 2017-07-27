//
//  VideoModel.h
//  885logistics
//
//  Created by Blues on 17/1/18.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseModel.h"

@interface VideoModel : BaseModel

@property (nonatomic, copy)   NSString      *name;
@property (nonatomic, assign) long long     size; //Bytes
@property (nonatomic, assign) double        duration;
@property (nonatomic, copy)   NSString      *format;
@property (nonatomic, strong) UIImage       *thumbnail;
@property (nonatomic, strong) NSURL         *videoURL;
@property (nonatomic, copy)   NSString      *isSlt;//选中


@end
