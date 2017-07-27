//
//  LYImageView.m
//  CustomFurniture
//
//  Created by Blues on 16/11/23.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "LYImageView.h"


@implementation LYImageView


- (void)awakeFromNib {

    [super awakeFromNib];
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    self.contentMode =  UIViewContentModeScaleAspectFill;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.clipsToBounds  = YES;
}



- (void)setImageURL:(NSURL *)imageURL {
    
    if (_imageURL != imageURL) {
        
        _imageURL = imageURL;
        
        [self sd_setImageWithURL:_imageURL placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        
    } else {
        
        self.image = nil;
    }

}


- (CGSize)suitableSize:(CGSize)size imageSize:(CGSize)imgSize{   //计算UIImageView的合适大小
    
    CGFloat scale = size.width/imgSize.width < size.height/imgSize.height ? size.width/imgSize.width : size.height/imgSize.height;
    CGFloat width = imgSize.width * scale > size.width ? size.width : imgSize.width * scale;
    CGFloat height = imgSize.height * scale > size.height ? size.height : imgSize.height * scale;
    return CGSizeMake(width, height);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
