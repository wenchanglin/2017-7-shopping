//
//  TextViewController.m
//  885logistics
//
//  Created by Blues on 17/1/6.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "TextViewController.h"
#import "ThemesViewController.h"
#import "ImageCCell.h"
#import "KindsModel.h"


@interface TextViewController ()<UITextFieldDelegate,UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *topBt;
@property (weak, nonatomic) IBOutlet UITextField *titleTf;
@property (weak, nonatomic) IBOutlet UITextView *contentTv;
@property (weak, nonatomic) IBOutlet UILabel *msgLb;
@property (weak, nonatomic) IBOutlet UILabel *locationLb;

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (weak, nonatomic) IBOutlet UICollectionView *imgView;

@property (nonatomic, strong) NSMutableArray *dataArr;//图片数组
@property (nonatomic, strong) UIImage *plusIv;
@property (nonatomic, strong) NSString *themeStr;

@end

@implementation TextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initData {

    self.dataArr = [[NSMutableArray alloc] initWithObjects:self.plusIv, nil];
    self.locationLb.text = [LYHelper getCurrentCityName];
}

- (void)createViews {

    self.navigationItem.title = @"主题帖";
    [self createNavItems];
    
    CGFloat itemWH = (kScreenSize.width - 36.f)/3.f;
    
    self.layout.itemSize = CGSizeMake(itemWH,itemWH);
    
    self.layout.minimumLineSpacing = 10.f;
    
    [self.imgView registerNib:[UINib nibWithNibName:@"ImageCCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCCell"];
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
    
    NSDictionary *param = @{@"type":@"1",
                            @"fkUserId":[LYHelper getCurrentUserID],
                            @"fkComnId":_themeStr,
                            @"title":title,
                            @"content":content,
                            @"location":[LYHelper getCurrentCityName]
                            };
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[LYAPIManager sharedInstance] POST:@"transportion/forunmPost/addForunmPost" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        [LYAPIManager showMessageForUser:result[@"msg"]];
        if ([result[@"errcode"] integerValue] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 NSDictionary *dict = result[@"data"];
                [self uploadImagesWithPostId:dict[@"id"]];
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    }];
}

- (void)uploadImagesWithPostId:(NSString *)postID {
    if (_dataArr.count < 2) {
        
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    NSInteger count = _dataArr.count;
    NSArray *images = nil;
    if ([self.dataArr containsObject:self.plusIv]){
        images = [_dataArr subarrayWithRange:NSMakeRange(0, count - 1)];
    }else{
        images = [_dataArr copy];
    }
    [LYAPIManager uploadImagesWithPostID:postID goal:@"posTopicJustPhotoHead" imageData:images];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - getter
- (UIImage *)plusIv {
    if (!_plusIv) {
        _plusIv = [UIImage imageNamed:@"plus1"];
    }
    return _plusIv;
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ImageCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCCell" forIndexPath:indexPath];
    cell.iv.image = [self.dataArr objectAtIndex:indexPath.row];
    if ([self.dataArr containsObject:self.plusIv]) {
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
    if (![self.dataArr containsObject:self.plusIv]) {
        [self.dataArr addObject:self.plusIv];
    }
    [self.imgView reloadData];
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if ([self.dataArr containsObject:self.plusIv]) {
     
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

//相册选择
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
    UIImage *img = nil;
    if (picker.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
        img = [info objectForKey:UIImagePickerControllerOriginalImage];
    }else {
        img = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    [self.dataArr insertObject:img atIndex:0];
    if (self.dataArr.count == 4) {
        [self.dataArr removeLastObject];
    }
    [self.imgView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
