//
//  SureViewController.m
//  885logistics
//
//  Created by Blues on 17/3/16.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "SureViewController.h"
#import "ImageCCell.h"
#import "OrderModel.h"

@interface SureViewController ()<UITextFieldDelegate,UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTf;
@property (weak, nonatomic) IBOutlet UITextField *phoneTf;
@property (weak, nonatomic) IBOutlet UITextView *textV;
@property (weak, nonatomic) IBOutlet UILabel *msgLb;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (weak, nonatomic) IBOutlet UIView *textBk;
@property (nonatomic, strong) NSMutableArray *dataArr;//图片数组
@property (nonatomic, strong) UIImage *plusIv;

@end

@implementation SureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViews];
}

- (void)createViews {
    
    self.navigationItem.title = @"投诉";
    [self createNavItems];
    
    self.dataArr = [[NSMutableArray alloc] initWithObjects:self.plusIv, nil];
    
    [self.textBk bringSubviewToFront:self.msgLb];
    
    CGFloat itemWH = (kScreenSize.width - 38.f)/3.f;
    self.layout.itemSize = CGSizeMake(itemWH,itemWH);
    self.layout.minimumLineSpacing = 5.f;
    self.layout.minimumInteritemSpacing = 5.f;
    self.layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10.f);
    [self.collectionView registerNib:[UINib nibWithNibName:@"ImageCCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCCell"];
}

- (void)createNavItems {
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(morePublish)];
    item.tintColor = [UIColor whiteColor];
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[item];
}

- (void)morePublish {
    
    [self.view endEditing:YES];
    if (IsNilOrNull(_myModel.fkDriverId)) {
        return;
    }
    
    NSString *title = self.nameTf.text;
    if (IsNilOrNull(title)) {
        [LYAPIManager showMessageForUser:@"请填写姓名"];
        return;
    }
    NSString *tel = self.phoneTf.text;
    if (IsNilOrNull(tel)) {
        [LYAPIManager showMessageForUser:@"请填写联系电话"];
        return;
    }
    
    NSString *content = self.textV.text;
    if (content.length == 0) {
        [LYAPIManager showMessageForUser:@"请填写投诉原因"];
        return;
    }
    
    NSDictionary *param = @{@"fkTransId":_myModel.fkOrderId,
                            @"fkUserId":_myModel.fkUserId,
                            @"fkDriverId":_myModel.fkDriverId,
                            @"name":title,
                            @"tel":tel,
                            @"content":content
                            };
    NSLog(@"___%@__",param);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [[LYAPIManager sharedInstance] POST:@"transportion/transInfoComplian/addComplain" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        // NSLog(@"___%@____",result);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [LYAPIManager showMessageForUser:result[@"msg"]];
        if ([result[@"errcode"] integerValue] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (NotNilAndNull(result[@"data"])) {
                    [self uploadImagesWithPostId:result[@"data"]];
                }
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)uploadImagesWithPostId:(NSString *)postID {
    if (self.dataArr.count == 1) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    NSInteger count = self.dataArr.count;
    NSArray *images = nil;
    if ([self.dataArr containsObject:self.plusIv]){
        images = [self.dataArr subarrayWithRange:NSMakeRange(0, count - 1)];
    }else{
        images = [self.dataArr copy];
    }
    [LYAPIManager uploadImagesWithPostID:postID goal:@"imageComplianForOrder" imageData:images];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - getter
- (UIImage *)plusIv {
    if (!_plusIv) {
        _plusIv = [UIImage imageNamed:@"plus1"];
    }
    return _plusIv;
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
        self.msgLb.text = @"请在此说明投诉原因";
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
    [self.collectionView reloadData];
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
    
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.dataArr insertObject:image atIndex:0];
    
    if (self.dataArr.count == 4) {
        [self.dataArr removeLastObject];
    }
    [self.collectionView reloadData];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
