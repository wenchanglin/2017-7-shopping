//
//  ReplyUserController.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/22.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "ReplyUserController.h"
#import "ImageCCell.h"

@interface ReplyUserController ()<UICollectionViewDelegate,UICollectionViewDataSource,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *msgLb;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (weak, nonatomic) IBOutlet UICollectionView *imgView;
@property (nonatomic, strong) UIImage *plus;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation ReplyUserController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)createViews {
    
    self.navigationItem.title = @"回复评价";
    self.dataArr = [[NSMutableArray alloc] initWithObjects:self.plus, nil];

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(morePublish)];
    item.tintColor = [UIColor whiteColor];
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[item];
    
    CGFloat itemWH = (kScreenSize.width - 42.f)/3.f;
    self.layout.itemSize = CGSizeMake(itemWH,itemWH);
    self.layout.minimumLineSpacing = 5.f;
    self.layout.minimumInteritemSpacing = 5.f;
    self.layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10.f);
    [self.imgView registerNib:[UINib nibWithNibName:@"ImageCCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCCell"];
}

- (void)morePublish {
    
    if (!_fkOrderId) {
        return;
    }
    NSString *text = self.textView.text;
    if (text.length == 0) {
        [self showMessageForUser:@"请填写回复内容"];
        return;
    }
    NSDictionary *param = @{@"fkTransId":_fkOrderId,
                            @"content":text
                            };
    [[LYAPIManager sharedInstance] POST:@"transportion/transOrderEvaReply/addToEvaReply" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result  = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if (NotNilAndNull(result[@"msg"])) {
            NSString *msg = result[@"msg"];
            if (msg.length) {
                [LYAPIManager showMessageForUser:msg];
            }
        }
        if ([result[@"errcode"] integerValue] == 0) {
            if (NotNilAndNull(result[@"data"])) {
                NSString *msgId = result[@"data"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self uploadImagesWithPostId:msgId];
                });
            }
        }
    } failure:nil];
}


- (void)uploadImagesWithPostId:(NSString *)postID {
    
    if (_dataArr.count > 1) {
    
        NSInteger count = _dataArr.count;
        NSArray *images = nil;
        if ([_dataArr containsObject:_plus]){
            images = [self.dataArr subarrayWithRange:NSMakeRange(0, count - 1)];
        }else{
            images = [self.dataArr copy];
        }
        [LYAPIManager uploadImagesWithPostID:postID goal:@"imageEvaReplyForOrder" imageData:images];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ImageCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCCell" forIndexPath:indexPath];
    cell.iv.image = [self.dataArr objectAtIndex:indexPath.row];
    if ([self.dataArr containsObject:_plus]) {
        if ((self.dataArr.count-1) == indexPath.row) {
            cell.deleteBt.hidden = YES;
        }else {
            cell.deleteBt.hidden = NO;
        }
    }else {
        cell.deleteBt.hidden = NO;
    }
    cell.deleteBt.tag = indexPath.row + 100;
    [cell.deleteBt addTarget:self action:@selector(deleteImg:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}


- (void)deleteImg:(UIButton *)sender {
    
    [self.dataArr removeObjectAtIndex:sender.tag - 100];
    if (![self.dataArr containsObject:_plus]) {
        [self.dataArr addObject:_plus];
    }
    [self.imgView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.dataArr containsObject:_plus]) {
        
        if (self.dataArr.count-1 == indexPath.row) {
            
            [self showActionController];
        }
    }
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

//开始拍照
- (void)takePhoto {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *imagePicker =[[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = YES;
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            imagePicker.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)LocalPhoto {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            imagePicker.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.dataArr insertObject:image atIndex:0];
    
    if (self.dataArr.count == 4) {
        [self.dataArr removeLastObject];
    }
    [self.imgView reloadData];
}


#pragma mark - getter
- (UIImage *)plus {
    if (!_plus) {
        _plus = [UIImage imageNamed:@"plus1"];
    }
    return _plus;
}

#pragma mark - textview delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.msgLb.hidden = YES;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    if (textView.text.length == 0) {
        self.msgLb.hidden = NO;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
