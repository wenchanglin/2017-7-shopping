//
//  LYAPIManager.m
//  CustomFurniture
//
//  Created by Blues on 16/11/14.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//
//
#import "LYAPIManager.h"
#import <MBProgressHUD.h>
#import "MineModel.h"

static LYAPIManager *manager;

@implementation LYAPIManager


+ (LYAPIManager *)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[LYAPIManager alloc] initWithBaseURL:[NSURL URLWithString:BaseUrl]];
        
        //manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager.requestSerializer  setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/xml",@"text/html", @"text/json",@"text/plain",@"text/javascript",nil];
    });
    return manager;
}



- (NSMutableArray *)homeArr {

    if (!_homeArr) {
        
        _homeArr = [NSMutableArray new];
        NSArray *types = @[@"全部订单",@"整车订单",@"专线订单",@"拼车订单"];
        NSArray *typesLink = @[@"",@"3",@"1",@"2"];
        for (NSInteger i = 0; i < types.count; i ++) {
            MineModel *model = [[MineModel alloc] init];
            model.isNow = @"0";
            model.titleName = [types objectAtIndex:i];
            model.htype = [typesLink objectAtIndex:i];
            if (i == 0) {
                model.isNow = @"1";
            }
            [_homeArr addObject:model];
        }
    }
    return _homeArr;
}


+ (void)uploadImagesWithPostID:(NSString *)postID goal:(NSString *)goal imageData:(NSArray *)images {
    
    if (images == nil || images.count == 0) {
        return;
    }
    AFURLSessionManager *managerf = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSString *url = [NSString stringWithFormat:@"%@transportion/file/uploadFile",BaseUrl];
    
    for (UIImage *image in images) {
        
        NSData *data = UIImagePNGRepresentation(image);
        NSMutableURLRequest *requestf = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            
            [formData appendPartWithFormData:[postID dataUsingEncoding:NSUTF8StringEncoding] name:@"fkPurposeId"];
            [formData appendPartWithFormData:[@"image" dataUsingEncoding:NSUTF8StringEncoding] name:@"fileType"];
            [formData appendPartWithFormData:[goal dataUsingEncoding:NSUTF8StringEncoding] name:@"filePurpose"];
            [formData appendPartWithFileData:data name:@"uploadFile" fileName:@"img.jpg" mimeType:@"image/jpg"];
        } error:nil];
        
        NSURLSessionUploadTask *uploadTaskf;
        uploadTaskf = [managerf uploadTaskWithStreamedRequest:requestf progress:^(NSProgress * _Nonnull uploadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"-----[%.2f]", uploadProgress.fractionCompleted);
            });
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            //NSLog(@"%@___%@",response,error);
            NSLog(@"%@___%@",responseObject,responseObject[@"msg"]);
            if ([responseObject[@"errcode"] integerValue] == 0) {
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    // Do something...
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                    });
                });
            }
        }];
        [uploadTaskf resume];
    }
}



+ (BOOL)clearCachesWithFilePath:(NSString *)path
{
    NSFileManager *mgr = [NSFileManager defaultManager];
    return [mgr removeItemAtPath:path error:nil];
}


+ (void)uploadEvaImageWithEvaID:(NSString *)evaID image:(UIImage *)image {
    
    if (IsNilOrNull(evaID) || IsNilOrNull(image)) {
        return;
    }
    AFURLSessionManager *managerf = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSString *url = [NSString stringWithFormat:@"%@transportion/file/uploadFile",BaseUrl];
    
    NSData *data = UIImagePNGRepresentation(image);
    
    NSMutableURLRequest *requestf = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFormData:[evaID dataUsingEncoding:NSUTF8StringEncoding] name:@"fkPurposeId"];
        [formData appendPartWithFormData:[@"image" dataUsingEncoding:NSUTF8StringEncoding] name:@"fileType"];
        [formData appendPartWithFormData:[@"posTopicEvaPhotoHead" dataUsingEncoding:NSUTF8StringEncoding] name:@"filePurpose"];
        [formData appendPartWithFileData:data name:@"uploadFile" fileName:@"img.jpg" mimeType:@"image/jpg"];
    } error:nil];
    
    NSURLSessionUploadTask *uploadTaskf;
    uploadTaskf = [managerf uploadTaskWithStreamedRequest:requestf progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"-----[%.2f]", uploadProgress.fractionCompleted);
        });
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        //NSLog(@"%@___%@",response,error);
        NSLog(@"%@___%@",responseObject,responseObject[@"msg"]);
        if ([responseObject[@"errcode"] integerValue] == 0) {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                // Do something...
                dispatch_async(dispatch_get_main_queue(), ^{
                });
            });
        }
    }];
    [uploadTaskf resume];
    
}


+ (void)uploadReplyImageWithReplyID:(NSString *)replyID image:(UIImage *)image {
    
    if (IsNilOrNull(replyID) || IsNilOrNull(image)) {
        return;
    }
    AFURLSessionManager *managerf = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSString *url = [NSString stringWithFormat:@"%@transportion/file/uploadFile",BaseUrl];
    
    NSData *data = UIImagePNGRepresentation(image);
    
    NSMutableURLRequest *requestf = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFormData:[replyID dataUsingEncoding:NSUTF8StringEncoding] name:@"fkPurposeId"];
        [formData appendPartWithFormData:[@"image" dataUsingEncoding:NSUTF8StringEncoding] name:@"fileType"];
        [formData appendPartWithFormData:[@"evaReplyPhotoHead" dataUsingEncoding:NSUTF8StringEncoding] name:@"filePurpose"];
        [formData appendPartWithFileData:data name:@"uploadFile" fileName:@"img.jpg" mimeType:@"image/jpg"];
    } error:nil];
    
    NSURLSessionUploadTask *uploadTaskf;
    uploadTaskf = [managerf uploadTaskWithStreamedRequest:requestf progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"-----[%.2f]", uploadProgress.fractionCompleted);
        });
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        //NSLog(@"%@___%@",response,error);
        NSLog(@"%@___%@",responseObject,responseObject[@"msg"]);
        if ([responseObject[@"errcode"] integerValue] == 0) {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                // Do something...
                dispatch_async(dispatch_get_main_queue(), ^{
                });
            });
        }
    }];
    [uploadTaskf resume];
    
}


+ (void)showMessageForUser:(NSString *)message {
    
    if (IsEmptyStr(message)) {
        return;
    }
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
            hud.removeFromSuperViewOnHide = YES;
            hud.mode = MBProgressHUDModeText;
            hud.animationType = MBProgressHUDAnimationZoomOut;
            hud.cornerRadius = 8;
            hud.labelFont = [UIFont systemFontOfSize:14.f];
            hud.labelText = message;
            [hud hide:YES afterDelay:1.f];
        });
    });
}







@end
