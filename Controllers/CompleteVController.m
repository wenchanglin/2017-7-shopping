//
//  CompleteVController.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/9.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "CompleteVController.h"
#import "TruckListController.h"
#import "TSListController.h"
#import "TBViewController.h"
#import "CarTypeModel.h"
#import "KindsModel.h"
#import "CompleteView.h"
#import "WUtils.h"
#import <CoreLocation/CoreLocation.h>


@interface CompleteVController ()<UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,CLLocationManagerDelegate>{
    
    CLLocationManager *_locationManager;
}

@property (nonatomic, weak) CompleteView    *completeView;
@property (nonatomic, copy) NSString        *trans;
@property (nonatomic, copy) NSString        *truck;
@property (nonatomic, assign) NSInteger     imgMark;
@property (nonatomic, copy) NSString        *imgGoal;
@property (nonatomic, assign) BOOL          isp1;
@property (nonatomic, assign) BOOL          isp2;
@property (nonatomic, assign) BOOL          isp3;
@property (nonatomic, assign) BOOL          isp4;
@property (nonatomic, assign) BOOL          isp6;
@property (nonatomic, assign) BOOL          isLocation;
@property (nonatomic, strong) NSString      *city;
@property (nonatomic, strong) CLLocation    *lct;

@end

@implementation CompleteVController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}


- (void)createViews {
    
    self.isp1 = YES;
    self.isp2 = YES;
    self.isp3 = YES;
    self.isp4 = YES;
    self.isp6 = YES;
    self.navigationItem.title = @"完善信息";
    self.city = @"杭州市";
    self.lct = [[CLLocation alloc] initWithLatitude:30.00000 longitude:120.00000];
    [self initializeLocationService];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(completeMine)];
    right.tintColor = [UIColor whiteColor];
    [right setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15.f],NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItems = @[right];
    
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - 64.f)];
    scrollview.contentSize = CGSizeMake(0, 1200.f);
    scrollview.showsVerticalScrollIndicator = YES;
    scrollview.showsHorizontalScrollIndicator = NO;
    scrollview.bounces = YES;
    
    [self.view addSubview:scrollview];
    
    self.completeView = [[NSBundle mainBundle] loadNibNamed:@"CompleteView" owner:nil options:nil].lastObject;
    self.completeView.frame = CGRectMake(0, 0, kScreenSize.width, 1200.f);
    
    self.completeView.nameTf.delegate = self;
    self.completeView.idNumberTf.delegate = self;
    self.completeView.btn1.tag = 521;
    [self.completeView.btn1 addTarget:self action:@selector(putImageFromAlbum:) forControlEvents:UIControlEventTouchUpInside];
    self.completeView.btn2.tag = 522;
    [self.completeView.btn2 addTarget:self action:@selector(putImageFromAlbum:) forControlEvents:UIControlEventTouchUpInside];
    self.completeView.btn3.tag = 523;
    [self.completeView.btn3 addTarget:self action:@selector(putImageFromAlbum:) forControlEvents:UIControlEventTouchUpInside];
    self.completeView.btn4.tag = 524;
    [self.completeView.btn4 addTarget:self action:@selector(putImageFromAlbum:) forControlEvents:UIControlEventTouchUpInside];
    self.completeView.btn5.tag = 525;
    [self.completeView.btn5 addTarget:self action:@selector(putImageFromAlbum:) forControlEvents:UIControlEventTouchUpInside];
    self.completeView.btn5.tag = 525;
    [self.completeView.btn5 addTarget:self action:@selector(putImageFromAlbum:) forControlEvents:UIControlEventTouchUpInside];
    self.completeView.btn6.tag = 526;
    [self.completeView.btn6 addTarget:self action:@selector(putImageFromAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [self.completeView.btn7 addTarget:self action:@selector(chooseTransKind) forControlEvents:UIControlEventTouchUpInside];
    [self.completeView.btn8 addTarget:self action:@selector(chooseCarKind) forControlEvents:UIControlEventTouchUpInside];
    [self.completeView.skipBt addTarget:self action:@selector(popToRootViewController) forControlEvents:UIControlEventTouchUpInside];
    [scrollview addSubview:self.completeView];
}

- (void)popToRootViewController {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)initializeLocationService {
    
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    if (self.isLocation && newLocation) {
        
        self.lct = newLocation;
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error){
            if (array.count){
                CLPlacemark *placemark = [array objectAtIndex:0];
                NSString *city = placemark.locality;
                if (!city) {
                    city = placemark.administrativeArea;
                }
                _city = city;
            }else {
                [self showMessageForUser:@"请允许该应用使用您的位置信息"];
            }
        }];
        [manager stopUpdatingLocation];
        self.isLocation = NO;
    }
}


- (void)completeMine {
    
    NSString *name = self.completeView.nameTf.text;
    if (IsEmptyStr(name)) {
        [self showMessageForUser:@"请填写您的真实姓名"];
        return;
    }
    NSString *idNumber = self.completeView.idNumberTf.text;
    if (IsEmptyStr(idNumber)) {
        [self showMessageForUser:@"请填写您的身份证号"];
        return;
    }
    
    if (![WUtils checkUserIdCard:idNumber]) {
        [self showMessageForUser:@"身份证号码有误"];
        return;
    }
    
    if (self.isp2 && self.isp3 && self.isp1 && self.isp6) {
        [self showMessageForUser:@"请上传证件照片"];
        return;
    }
    
    if (IsEmptyStr(self.trans)) {
        [self showMessageForUser:@"请选择运输类型"];
        return;
    }
    if (IsEmptyStr(self.truck)) {
        [self showMessageForUser:@"请选择车辆类型"];
        return;
    }
    
    NSDictionary *param = @{@"uid":self.fkId,
                            @"x":@(_lct.coordinate.latitude),
                            @"y":@(_lct.coordinate.longitude),
                            @"realname":name,
                            @"idCard":idNumber,
                            @"fkCarClass":self.trans,
                            @"fkTruckModel":self.truck,
                            @"address":_city
                            };
    
    NSLog(@"___%@___",param);
    
    [[LYAPIManager sharedInstance] POST:@"transportion/driver/addDriverCarInfo" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)putImageFromAlbum:(UIButton *)sender {

    self.imgMark = sender.tag;
    
    switch (sender.tag) {
        case 521:
        {
            self.isp1 = NO;
            self.imgGoal = @"imagePcForIdCard";
            [self showActionSheetWithMessage:@"身份证正面照片"];
        }
            break;
        case 522:
        {
            self.isp2 = NO;
            self.imgGoal = @"imagePcForSelf";
            [self showActionSheetWithMessage:@"手持身份证照片"];
        }
            break;
        case 523:
        {
            self.isp3 = NO;
            self.imgGoal = @"imagePcForDriverLicense";
            [self showActionSheetWithMessage:@"驾驶证照片"];
        }
            break;
        case 524:
        {
            self.isp4 = NO;
            self.imgGoal = @"imagePcForCertificate";
            [self showActionSheetWithMessage:@"资格证照片"];
        }
            break;
        case 525:
        {
            self.imgGoal = @"imagePolicyForSelf";
            [self showActionSheetWithMessage:@"人身保险单照片"];
        }
            break;
        default:
        {
            self.isp6 = NO;
            self.imgGoal = @"imagePolicyForCar";
            [self showActionSheetWithMessage:@"车辆保险单照片"];
        }
            break;
    }
}

- (void)chooseTransKind {
    
    TSListController *tsList = [[TSListController alloc] initWithRTKindBlock:^(KindsModel *model) {
        
        self.trans = model.kindID;
        self.completeView.ttransTf.text = model.text;
    }];
    [tsList addPopItem];
    
    [self.navigationController pushViewController:tsList animated:YES];
}


- (void)chooseCarKind {
    
    TruckListController *truck = [[TruckListController alloc] initWithRTTruckBlock:^(CarTypeModel *model) {
        self.truck = model.CarID;
        
        self.completeView.carTf.text = model.carModel;
        self.completeView.sizeTf.text = model.modelSize;
        self.completeView.loadTf.text = model.modelWeight;
    }];
    [truck addPopItem];
    [self.navigationController pushViewController:truck animated:YES];
}


- (void)showActionSheetWithMessage:(NSString *)msg {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:msg message:@"选择图片" preferredStyle:UIAlertControllerStyleActionSheet];
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

//开始拍照
- (void)takePhoto {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *imagePicker =[[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = YES;
        imagePicker.modalPresentationStyle=UIModalPresentationOverCurrentContext;
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
        imagePicker.modalPresentationStyle=UIModalPresentationOverCurrentContext;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *outImage = [info objectForKey:UIImagePickerControllerEditedImage];

    UIButton *btn = (UIButton *)[self.completeView viewWithTag:self.imgMark];
    [btn setBackgroundImage:outImage forState:UIControlStateNormal];
    
    NSString *url = [NSString stringWithFormat:@"%@transportion/file/uploadFile",BaseUrl];

    NSData *data = UIImagePNGRepresentation(outImage);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableURLRequest *requestf = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            
            [formData appendPartWithFormData:[self.fkId dataUsingEncoding:NSUTF8StringEncoding] name:@"fkPurposeId"];
            [formData appendPartWithFormData:[@"image" dataUsingEncoding:NSUTF8StringEncoding] name:@"fileType"];
            [formData appendPartWithFormData:[self.imgGoal dataUsingEncoding:NSUTF8StringEncoding] name:@"filePurpose"];
            [formData appendPartWithFileData:data name:@"uploadFile" fileName:@"header.jpg" mimeType:@"image/jpg"];
        } error:nil];
        
        AFURLSessionManager *managerf = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSURLSessionUploadTask *uploadTaskf;
        uploadTaskf = [managerf uploadTaskWithStreamedRequest:requestf progress:^(NSProgress * _Nonnull uploadProgress) {
        } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
            [LYAPIManager showMessageForUser:@"图片上传成功"];
        }];
        [uploadTaskf resume];
    });
}

#pragma mark - UITextFieldDelegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
