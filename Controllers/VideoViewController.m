//
//  VideoViewController.m
//  885logistics
//
//  Created by Blues on 17/1/18.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "VideoViewController.h"
#import "VideosController.h"
#import "ThemesViewController.h"
#import "VideoModel.h"
#import "KindsModel.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import <AVFoundation/AVFoundation.h>


@interface VideoViewController ()<UITextFieldDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton       *topBt;
@property (weak, nonatomic) IBOutlet UITextField    *titleTf;
@property (weak, nonatomic) IBOutlet UITextView     *contentTv;
@property (weak, nonatomic) IBOutlet UILabel        *msgLb;
@property (weak, nonatomic) IBOutlet UILabel        *locationLb;
@property (weak, nonatomic) IBOutlet UIImageView    *pIv;
@property (weak, nonatomic) IBOutlet UILabel        *timeLb;

@property (nonatomic, strong) NSString *themeStr;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *outputFile;
@property (nonatomic, strong) NSURL *filePathUrl;
@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSURL *myUrl;

@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initData {
    
    [self createNavItems];
    self.locationLb.text = [LYHelper getCurrentCityName];
}

- (void)createViews {
    self.navigationItem.title = @"视频帖";
    
    self.pIv.userInteractionEnabled = YES;
    self.pIv.layer.masksToBounds = YES;
    self.pIv.layer.cornerRadius = 1.f;
    self.pIv.backgroundColor = [UIColor groupTableViewBackgroundColor];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClicked:)];
    [self.pIv addGestureRecognizer:tap];
}

- (void)createNavItems {
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStyleDone target:self action:@selector(morePublish)];
    item.tintColor = [UIColor whiteColor];
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[item];
}

- (void)morePublish {
    
    [self.view endEditing:YES];
    
    NSString *title = self.titleTf.text;
    if (IsNilOrNull(title)) {
        title = @"";
    }
    NSString *content = self.contentTv.text;
    if (content.length == 0) {
        [self showMessageForUser:@"请填写内容后发布"];
        return;
    }
    if (IsNilOrNull(self.themeStr)) {
        [self showMessageForUser:@"请选择帖子主题"];
        return;
    }

    if (IsNilOrNull(self.myUrl)) {
        [self showMessageForUser:@"请添加视频后发布"];
        return;
    }
    
    NSDictionary *param = @{@"type":@"2",
                            @"fkUserId":[LYHelper getCurrentUserID],
                            @"fkComnId":self.themeStr,
                            @"title":title,
                            @"content":content,
                            @"location":[LYHelper getCurrentCityName]
                            };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [[LYAPIManager sharedInstance] POST:@"transportion/forunmPost/addForunmPost" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        [LYAPIManager showMessageForUser:result[@"msg"]];
        // NSLog(@"___%@",result);
        if ([result[@"errcode"] integerValue] == 0) {
            NSDictionary *data = result[@"data"];
            if (NotNilAndNull(self.myUrl)) {
                self.postID = data[@"id"];
                [self convertMovVideoToMP4First];
                [self uploadServerImage];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}


- (void)convertMovVideoToMP4First {

    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:self.myUrl  options:nil];
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyyMMddHHmmss"];
    _fileName = [NSString stringWithFormat:@"output-%@.mp4",[formater stringFromDate:[NSDate date]]];
    _outputFile = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", _fileName];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
    
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        exportSession.outputURL = [NSURL fileURLWithPath:_outputFile];
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                _filePath = _outputFile;
                _filePathUrl = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",_filePath]];
                // NSLog(@"转换完成_filePath = %@\\n_filePathURL = %@",_filePath,_filePathUrl);
                // 获取大小和长度
                [self uploadVideo];
            }
        }];
    }
}



- (void)uploadServerImage {

    UIImage *image = [self getThumbailImage:self.myUrl];
    if (!image) {
        return;
    }
    NSLog(@"___图片信息__%@",image);
    
    AFURLSessionManager *managerf = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSString *url = [NSString stringWithFormat:@"%@transportion/file/uploadFile",BaseUrl];
    NSData *data = UIImagePNGRepresentation(image);
    
    NSMutableURLRequest *requestf = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFormData:[self.postID dataUsingEncoding:NSUTF8StringEncoding] name:@"fkPurposeId"];
        [formData appendPartWithFormData:[@"image" dataUsingEncoding:NSUTF8StringEncoding] name:@"fileType"];
        [formData appendPartWithFormData:[@"posTopicJustVideoPhoto" dataUsingEncoding:NSUTF8StringEncoding] name:@"filePurpose"];
        [formData appendPartWithFileData:data name:@"uploadFile" fileName:@"image.jpg" mimeType:@"image/jpg"];
    } error:nil];
    
    NSURLSessionUploadTask *uploadTaskf;
    uploadTaskf = [managerf uploadTaskWithStreamedRequest:requestf progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"-----[%.2f]", uploadProgress.fractionCompleted);
        });
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"%@____图片上传__%@",responseObject,responseObject[@"msg"]);
    }];
    [uploadTaskf resume];
}

- (void)uploadVideo {
    
    if (!self.postID) {
        return;
    }
    NSString *posturl = [NSString stringWithFormat:@"%@transportion/file/uploadFile",BaseUrl];

    NSData *data = [NSData dataWithContentsOfURL:_filePathUrl];
    if (!data) {
        [self showMessageForUser:@"请添加视频后发布"];
        return;
    }
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:posturl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFormData:[self.postID dataUsingEncoding:NSUTF8StringEncoding] name:@"fkPurposeId"];
        [formData appendPartWithFormData:[@"video" dataUsingEncoding:NSUTF8StringEncoding] name:@"fileType"];
        [formData appendPartWithFormData:[@"posTopicJustVideo" dataUsingEncoding:NSUTF8StringEncoding] name:@"filePurpose"];
        [formData appendPartWithFileData:data name:@"uploadFile" fileName:_fileName mimeType:@"video/mp4"];
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        // This is not called back on the main queue.
        // You are responsible for dispatching to the main queue for UI updates
        dispatch_async(dispatch_get_main_queue(), ^{
            //Update the progress view
            //[progressView setProgress:uploadProgress.fractionCompleted];
            NSLog(@"--##---[%.2f]", uploadProgress.fractionCompleted);
        });
    }completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        NSLog(@"——————%@",responseObject[@"msg"]);
        
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            
            if ([responseObject[@"errcode"] integerValue] == 0) {
                [self clearMovieFromDoucments];
            }
        }
    }];
    [uploadTask resume];
}

/* 按正确视频方向获取缩略图 */
- (UIImage *)getThumbailImage:(NSURL *)url {
    
    if (!url) {
        return nil;
    }
    NSDictionary *opts = @{AVURLAssetPreferPreciseDurationAndTimingKey:@(NO)};
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:opts];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    //创建视频缩略图的时间，第一个参数是视频第几秒，第二个参数是每秒帧数
    CMTime time = CMTimeMake(0, 8);
    CMTime actualTime;//实际生成视频缩略图的时间
    NSError *error = nil;//错误信息
    //使用对象方法，生成视频缩略图，注意生成的是CGImageRef类型，如果要在UIImageView上显示，需要转为UIImage
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time
                                                actualTime:&actualTime
                                                     error:&error];
    if (error) {
        NSLog(@"截取视频缩略图发生错误，错误信息%@",error.localizedDescription);
        return nil;
    }
    //CGImageRef转UIImage对象
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    //记得释放CGImageRef
    CGImageRelease(cgImage);
    return image;
}


#pragma mark - 清除documents中的视频文件
- (void)clearMovieFromDoucments {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        NSLog(@"%@",filename);
        if ([filename isEqualToString:@"tmp.PNG"]) {
            NSLog(@"删除%@",filename);
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
            continue;
        }
        if ([[[filename pathExtension] lowercaseString] isEqualToString:@"mp4"]||
            [[[filename pathExtension] lowercaseString] isEqualToString:@"mov"]||
            [[[filename pathExtension] lowercaseString] isEqualToString:@"png"]) {
            NSLog(@"删除%@",filename);
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
    }
}


- (void)tapClicked:(UIButton *)sender {
    
    VideosController *video = [[VideosController alloc] init];
    [video addPopItem];
    [video cameSetMyBlock:^(VideoModel *vModel) {
        self.pIv.image = vModel.thumbnail;
        self.myUrl = vModel.videoURL;
        self.timeLb.text = [NSString stringWithFormat:@"%.2f",vModel.duration];
    }];
    [self.navigationController pushViewController:video animated:YES];
}


- (IBAction)changeThemeClicked:(UIButton *)sender {
    
    ThemesViewController *more = [[ThemesViewController alloc]init];
    
    [more cameGetMy:^(KindsModel *model) {
        [self.topBt setTitle:model.text forState:UIControlStateNormal];
        self.themeStr = model.kindID;
    }];
    more.providesPresentationContextTransitionStyle = true;
    more.definesPresentationContext = true;
    more.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    more.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:more animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.msgLb.text = @"";
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    if (textView.text.length == 0) {
        self.msgLb.text = @"请输入内容";
    }
    return YES;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([@"\n" isEqualToString:text]){
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
