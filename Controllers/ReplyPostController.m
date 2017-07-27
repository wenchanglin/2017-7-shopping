//
//  ReplyPostController.m
//  885logistics
//
//  Created by Blues on 17/2/14.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "ReplyPostController.h"
#import "PostModel.h"

@interface ReplyPostController ()<UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UITextView *contentTv;
@property (weak, nonatomic) IBOutlet UIImageView *iv;
@property (weak, nonatomic) IBOutlet UILabel *msgLb;
@property (weak, nonatomic) IBOutlet UIView *bk2;
@property (nonatomic, strong) UIImage *image;


@end

@implementation ReplyPostController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)createViews {

    self.navigationItem.title = @"回复";
    
    [self createNavItems];
    
    [self.bk2 bringSubviewToFront:self.msgLb];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showActionController)];
    [self.iv addGestureRecognizer:tap];
    
    if (NotNilAndNull(_model)) {
        self.nickName.text = [@"@" stringByAppendingString:_model.userName];
    }
}
- (void)createNavItems {
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStyleDone target:self action:@selector(replyPostClicked)];
    item.tintColor = [UIColor whiteColor];
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[item];
}

- (void)replyPostClicked {
    
    NSString *content = self.contentTv.text;
    if (content.length == 0) {
        [self showMessageForUser:@"请填写回复内容"];
        return;
    }
    
    NSDictionary *param = nil;
    NSString *urlStr = nil;
    
    if (NotNilAndNull(_fkPostId)) {
        
        param = @{@"fkPostId":_fkPostId,
                  @"fkUserId":[LYHelper getCurrentUserID],
                  @"content":content
                  };
        urlStr = @"transportion/forumEva/addForumEva";
        
    }else if (NotNilAndNull(_fkEvaId)){
        
        param = @{@"fkEvaId":_fkEvaId,
                  @"fkUserId":[LYHelper getCurrentUserID],
                  @"content":content
                  };
    
        urlStr = @"transportion/forumEvaReply/addForumEvaReply";
    }
    if (IsNilOrNull(urlStr) && IsNilOrNull(param)) {
        return;
    }
    
    NSLog(@"___%@____",param);
    
    [[LYAPIManager sharedInstance] POST:urlStr parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"__评论内容__%@",result);

        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *msg = result[@"msg"];
            if (msg.length) {
                [LYAPIManager showMessageForUser:msg];
            }
            if (NotNilAndNull(_image)) {
                if (NotNilAndNull(result[@"data"])) {
                    NSDictionary *data = result[@"data"];
                    if (NotNilAndNull(_fkEvaId)) {
                        [self uploadEvaImageWithDataId:data[@"id"] image:self.image];
                    }else {
                        [LYAPIManager uploadEvaImageWithEvaID:data[@"id"] image:self.image];
                    }
                }
            }
            if ([result[@"errcode"] integerValue] == 0) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)uploadEvaImageWithDataId:(NSString *)dataId image:(UIImage *)image {
    
    if (IsNilOrNull(dataId) || IsNilOrNull(image)) {
        return;
    }
    AFURLSessionManager *managerf = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSString *url = [NSString stringWithFormat:@"%@transportion/file/uploadFile",BaseUrl];
    
    NSData *data = UIImagePNGRepresentation(image);
    
    NSMutableURLRequest *requestf = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFormData:[dataId dataUsingEncoding:NSUTF8StringEncoding] name:@"fkPurposeId"];
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
        NSLog(@"%@___%@",responseObject,responseObject[@"msg"]);
    }];
    [uploadTaskf resume];
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
        self.msgLb.text = @"说点什么吧！";
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


- (void)showActionController {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"+添加图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *openCamera = [UIAlertAction actionWithTitle:@"相机" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto];
    }];
    UIAlertAction *openAlbum = [UIAlertAction actionWithTitle:@"相册" style: UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action) {
        [self LocalPhoto];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel  handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:openCamera];
    [alert addAction:openAlbum];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)takePhoto {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *imagePicker =[[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = YES;
        imagePicker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)LocalPhoto {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        imagePicker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *img = nil;
    if (picker.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
        img = [info objectForKey:UIImagePickerControllerOriginalImage];
    }else {
        img = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    self.iv.image = img;
    self.image = img;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
