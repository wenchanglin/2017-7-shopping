//
//  ShareController.m
//  885logistics
//
//  Created by Blues on 17/1/10.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "ShareController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>

@interface ShareController ()
@property (weak, nonatomic) IBOutlet UIImageView *QRIv;
@property (weak, nonatomic) IBOutlet UILabel *msgLb;

@end

@implementation ShareController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)createViews {
    self.navigationItem.title = @"分享885";
    self.msgLb.text = @"好东西要分享哦！\n喜欢就分享给你的小伙伴吧！";
}


- (IBAction)shareClicked:(UIButton *)sender {

    //1、创建分享参数
    NSArray* imageArray = @[[UIImage imageNamed:@"Icon-60"]];
    //（注意：图片必须要在Xcode左边目录里面，名称必须要传正确，如果要分享网络图片，可以这样传iamge参数 images:@[@"http://mob.com/Assets/images/logo.png?v=20150320"]）
    if (imageArray) {
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:@"快来加入我们吧!"
                                         images:imageArray
                                            url:[NSURL URLWithString:@"http://www.ibabawu.com"]
                                          title:@"巴巴五物流"
                                           type:SSDKContentTypeAuto];
        //有的平台要客户端分享需要加此方法，例如微博
        [shareParams SSDKEnableUseClientShare];
        //2、分享（可以弹出我们的分享菜单和编辑界面）
        [ShareSDK showShareActionSheet:nil //要显示菜单的视图, iPad版中此参数作为弹出菜单的参照视图，只有传这个才可以弹出我们的分享菜单，可以传分享的按钮对象或者自己创建小的view 对象，iPhone可以传nil不会影响
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       switch (state) {
                           case SSDKResponseStateSuccess:
                           {
                               [LYAPIManager showMessageForUser:@"分享成功"];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               [LYAPIManager showMessageForUser:@"分享失败"];
                               break;
                           }
                           default:
                               break;
                       }
                   }
         ];
    
    }
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
