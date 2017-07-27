//
//  LYImageView.h
//  CustomFurniture
//
//  Created by Blues on 16/11/23.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYImageView : UIImageView
{
    NSURL       *_imageURL;
}


/** imageURL 图片链接*/
@property (nonatomic, strong) NSURL *imageURL;


@end
