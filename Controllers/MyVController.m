//
//  MyVController.m
//  CustomFurniture
//
//  Created by Blues on 16/10/18.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "MyVController.h"
#import "MyTCell.h"


@interface MyVController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) NSArray           *dataArr;
@property (nonatomic, strong) UIBarButtonItem   *editItem;
@property (nonatomic, strong) UIBarButtonItem   *saveItem;
@property (nonatomic, strong) UIView            *footer;
@property (nonatomic, weak) UITextField         *perView;
@property (nonatomic, weak) UIImageView         *headIv;
@property (nonatomic, assign) BOOL              isEdit;
@property (nonatomic, strong) UIImage  *image;

@end

@implementation MyVController

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.isEdit = NO;
    
    self.navigationItem.title = @"我的信息";
    self.dataArr = @[@"头像",@"昵称",@"性别",@"公司名称",@"联系方式",@"车辆信息"];
    self.rightArr = [[NSMutableArray alloc] initWithObjects:@"",@"",@"",@"",@"",@"", nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MyTCell" bundle:nil] forCellReuseIdentifier:@"MyTCell"];
    
    self.navigationItem.rightBarButtonItems = @[self.editItem];
    self.tableView.tableFooterView = self.footer;
    
    UIImage *img = [[UIImage imageNamed:@"go_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStyleDone target:self action:@selector(popCurrentView:)];
    self.navigationItem.leftBarButtonItems = @[item];
    
    [self getMyInfo];
}

- (void)popCurrentView:(UIBarButtonItem *)item {
    [self.navigationController popViewControllerAnimated:YES];
}


- (UIBarButtonItem *)editItem {

    if (!_editItem) {
        _editItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(toEdit:)];
        _editItem.tintColor = [UIColor whiteColor];
        [_editItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    }
    return _editItem;
}

- (void)toEdit:(UIBarButtonItem *)item {
    
    for (NSInteger i = 1001; i < 1006; i ++) {
    
        UITextField *tf = (UITextField *)[self.view viewWithTag:i];
        if (i == 1002 || i == 1004) {
            tf.userInteractionEnabled = NO;
        }else {
            tf.userInteractionEnabled = YES;
        }
    }
    self.navigationItem.rightBarButtonItems = @[self.saveItem];
    
    self.isEdit = YES;
    
    UITextField *nametf = (UITextField *)[self.view viewWithTag:1001];
    [nametf becomeFirstResponder];
}


- (UIBarButtonItem *)saveItem {
    
    if (!_saveItem) {
        _saveItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(toSave:)];
        _saveItem.tintColor = [UIColor whiteColor];
        [_saveItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    }
    return _saveItem;
}

- (void)toSave:(UIBarButtonItem *)item {
    
    [self.view endEditing:YES];
    
    self.isEdit = NO;
    for (MyTCell *cell in [self.tableView visibleCells]) {
        cell.ttf.userInteractionEnabled = NO;
    }
    
    UITextField *nametf = (UITextField *)[self.view viewWithTag:1001];
    NSString *nickname = nametf.text;
    
    UITextField *gendertf = (UITextField *)[self.view viewWithTag:1002];
    NSString *gender = gendertf.text;
    
    UITextField *companytf = (UITextField *)[self.view viewWithTag:1003];
    NSString *company = companytf.text;
    
    UITextField *phonetf = (UITextField *)[self.view viewWithTag:1004];
    NSString *phone = phonetf.text;
    
    UITextField *cartf = (UITextField *)[self.view viewWithTag:1005];
    NSString *car = cartf.text;
    
    NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID],
                            @"IdNum":@"",
                            @"nickName":nickname,
                            @"sex":gender,
                            @"contactTel":phone,
                            @"companyName":company,
                            @"carMsg":car
                            };
    
    [[LYAPIManager sharedInstance] POST:@"transportion/driver/updateDriverInfo" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.navigationItem.rightBarButtonItems = @[self.editItem];
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *msg = result[@"msg"];
        if (msg.length) {
            [LYAPIManager showMessageForUser:msg];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {}];
}


- (void)getMyInfo {
    
    NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID]};
    
    [[LYAPIManager sharedInstance] POST:@"transportion/driver/queryDriverDetail" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([result[@"errcode"] integerValue] == 0) {
            
            NSDictionary *data = result[@"data"];
            
            NSString *imgUrlStr     = nil;
            NSString *nickName      = nil;
            NSString *sex           = nil;
            NSString *companyName   = nil;
            NSString *tel           = nil;
            NSString *carmsg         = nil;
            
            if (NotNilAndNull(data[@"userInfoBase"])) {
                NSDictionary *userInfoBase = data[@"userInfoBase"];
                if (NotNilAndNull(userInfoBase[@"userName"])) {
                    nickName = userInfoBase[@"userName"];
                }else {
                    nickName = @"";
                }
                if (NotNilAndNull(userInfoBase[@"phone"])) {
                    tel = userInfoBase[@"phone"];
                }else {
                    tel = @"";
                }
                if (NotNilAndNull(userInfoBase[@"userPhoto"])) {
                    NSDictionary *userPhoto = userInfoBase[@"userPhoto"];
                    imgUrlStr = [NSString stringWithFormat:ImgLoadUrl,userPhoto[@"location"]];
                }else {
                    imgUrlStr = @"";
                }
            }else {
                nickName = @"";
                tel = @"";
            }
            if (NotNilAndNull(data[@"sex"])) {
                sex = data[@"sex"];
            }else {
                sex = @"";
            }
            if (NotNilAndNull(data[@"companyName"])) {
                companyName = data[@"companyName"];
            }else {
                companyName = @"";
            }
            if (NotNilAndNull(data[@"truckModel"])) {
                NSDictionary *truckModel = data[@"truckModel"];
                carmsg = truckModel[@"carModel"];
            }else {
                carmsg = @"";
            }
            self.rightArr = [[NSMutableArray alloc] initWithObjects:imgUrlStr,nickName,sex,companyName,tel,carmsg, nil];
            [self.tableView reloadData];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


- (UIView *)footer {

    if (!_footer) {
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 1)];
        _footer.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _footer;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    MyTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyTCell" forIndexPath:indexPath];
    NSString *rtl = [self.dataArr objectAtIndex:indexPath.row];
    NSString *indexStr = [self.rightArr objectAtIndex:indexPath.row];
    cell.ttf.delegate = self;
    cell.tlb.text = rtl;
    
    if (indexPath.row == 0)
    {
        
        if (indexStr.length > 2) {
            NSString *url = [NSString stringWithFormat:@"%@",indexStr];
            [cell.iv sd_setImageWithURL:[NSURL URLWithString:url]];
        }
        if (NotNilAndNull(self.image)) {
            cell.iv.image = self.image;
        }
        cell.iv.hidden = NO;
        cell.ttf.hidden = YES;
        self.headIv = cell.iv;
    }
    else
    {
        
        cell.ttf.tag = 1000 + indexPath.row;
        cell.ttf.placeholder = rtl;
        cell.iv.hidden = YES;
        cell.ttf.hidden = NO;
        if (self.isEdit) {
            cell.ttf.userInteractionEnabled = YES;
        }else {
            cell.ttf.userInteractionEnabled = NO;
        }
        cell.ttf.textAlignment = NSTextAlignmentRight;
        cell.ttf.delegate = self;
        cell.ttf.text = indexStr;
        if (indexPath.row == 2 || indexPath.row == 4 || indexPath.row == 5) {
            cell.ttf.userInteractionEnabled = NO;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.isEdit) {
        return;
    }
    
    if (indexPath.row == 0) {
        
        if (IOS8_OR_LATER) {
            [self showActionSheetController888];
        }else {
            [self showActionSheet888];
        }
    
    }else if (indexPath.row == 2){
        
        if (IOS8_OR_LATER) {
            [self showActionSheetController889];
        }else {
            [self showActionSheet889];
        }
        
    }else{
        
        MyTCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.perView = cell.ttf;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        return 65.f;
    }
    return 44.f;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (void)viewWillLayoutSubviews {
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (void)showActionSheet888 {
    
    [self.view endEditing:YES];

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"设置头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机",@"相册", nil];
    actionSheet.tag = 888;
    [actionSheet showInView:self.view];
}

- (void)showActionSheet889 {
    
    [self.view endEditing:YES];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"设置性别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
    actionSheet.tag = 889;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 888) {
     
        if (buttonIndex == 0) {
            [self takePhoto];
        }else if (buttonIndex == 1) {
            [self LocalPhoto];
        }
        
    }else if (actionSheet.tag == 889){
    
        UITextField *gendertf = (UITextField *)[self.view viewWithTag:1002];
        if (buttonIndex == 0) {
            gendertf.text = @"男";
        }else if (buttonIndex == 1){
            gendertf.text = @"女";
        }
    }
}

- (void)showActionSheetController888 {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置头像" message:@"+选择图片" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *openCamera = [UIAlertAction actionWithTitle:@"相机" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto];
    }];
    UIAlertAction *openAlbum = [UIAlertAction actionWithTitle:@"相册" style: UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action) {
        [self LocalPhoto];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel  handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:openCamera];
    [alert addAction:openAlbum];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showActionSheetController889 {

    
    UITextField *gendertf = (UITextField *)[self.view viewWithTag:1002];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设置性别" message:@"+选择" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *man = [UIAlertAction actionWithTitle:@"男" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        gendertf.text = @"男";
        [self.rightArr replaceObjectAtIndex:2 withObject:@"男"];
    }];
    UIAlertAction *lady = [UIAlertAction actionWithTitle:@"女" style: UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action) {
        gendertf.text = @"女";
        [self.rightArr replaceObjectAtIndex:2 withObject:@"男"];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel  handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alert addAction:man];
    [alert addAction:lady];
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
    
    UIImage *outImage = [info objectForKey:UIImagePickerControllerEditedImage];
    self.headIv.image = outImage;
    self.image = outImage;
    
    NSString *url = [NSString stringWithFormat:@"%@transportion/file/uploadFile",BaseUrl];
    
    NSString *fkId = [LYHelper getCurrentUserID];
    
    NSData *data = UIImagePNGRepresentation(outImage);
    
    NSMutableURLRequest *requestf = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFormData:[fkId dataUsingEncoding:NSUTF8StringEncoding] name:@"fkPurposeId"];
        [formData appendPartWithFormData:[@"image" dataUsingEncoding:NSUTF8StringEncoding] name:@"fileType"];
        [formData appendPartWithFormData:[@"imageUserPhotoHead" dataUsingEncoding:NSUTF8StringEncoding] name:@"filePurpose"];
        [formData appendPartWithFileData:data name:@"uploadFile" fileName:@"header.jpg" mimeType:@"image/jpg"];
    } error:nil];
    
    AFURLSessionManager *managerf = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionUploadTask *uploadTaskf;
    uploadTaskf = [managerf uploadTaskWithStreamedRequest:requestf progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"-----[%.2f]", uploadProgress.fractionCompleted);
        });
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        //NSLog(@"%@___%@",response,error);
        //NSLog(@"%@___%@",responseObject,responseObject[@"msg"]);
        [LYAPIManager showMessageForUser:@"图片上传成功"];
    }];
    [uploadTaskf resume];
}

#pragma mark - UITextfieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.perView resignFirstResponder];
    NSLog(@"___%s___",__FUNCTION__);
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSInteger index = textField.tag - 1000;
    NSString  *text = textField.text;
    [self.rightArr replaceObjectAtIndex:index withObject:text];
    NSLog(@"_____%@",self.rightArr[index]);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
