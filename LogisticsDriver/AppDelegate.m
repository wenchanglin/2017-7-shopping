//
//  AppDelegate.m
//  LogisticsDriver
//
//  Created by Blues on 17/1/22.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "AppDelegate.h"
#import "TBViewController.h"
#import "LoginViewController.h"
#import "CompleteVController.h"
#import <RongIMKit/RongIMKit.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
//微信SDK头文件
#import "WXApi.h"



@interface AppDelegate ()<RCIMUserInfoDataSource,JPUSHRegisterDelegate,WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    NSDictionary *user = [[NSUserDefaults standardUserDefaults] objectForKey:@"User"];
    
    [self initRCIM];
    [self initShareSDK];
    
    //微信支付
    [WXApi registerApp:@"wxc8f1d1336cec8b0b" withDescription:@"巴巴五物流"];
    
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
//         NSSet<UNNotificationCategory *> *categories for iOS10 or later
//         NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    [JPUSHService setupWithOption:launchOptions appKey:@"3de7279c9fb481212f2b9d0d"
                          channel:nil
                 apsForProduction:YES
            advertisingIdentifier:nil];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    
    if (user) {
        
        TBViewController *tbc = [[TBViewController alloc] init];
        [self.window setRootViewController:tbc];
        
    }else {
    
        LoginViewController *home = [[LoginViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
        [self.window setRootViewController:nav];
    }
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)initRCIM {
    
    [[RCIM sharedRCIM] initWithAppKey:@"8w7jv4qb8w1jy"];
    [LYHelper loginRongCloud];
    [[RCIM sharedRCIM] setUserInfoDataSource:self];
    [RCIM sharedRCIM].globalNavigationBarTintColor = MainColor;
}

- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *))completion {
    
    if (!userId) {
        return;
    }
    
    NSDictionary *param1 = @{@"uid":userId};
    
    [[LYAPIManager sharedInstance] POST:@"transportion/employ/queryEmployDetails" parameters:param1 progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];

        if ([result[@"errcode"] integerValue] == 0) {
            
            if (NotNilAndNull(result[@"data"])) {
                
                RCUserInfo *rcUser = [[RCUserInfo alloc] init];
                rcUser.userId = userId;
                NSDictionary *data = result[@"data"];
                
                if (NotNilAndNull(data[@"userInfoBase"])) {
                    NSDictionary *userInfoBase = data[@"userInfoBase"];
                    if (NotNilAndNull(userInfoBase[@"userName"])) {
                        rcUser.name = userInfoBase[@"userName"];
                    }
                    if (NotNilAndNull(userInfoBase[@"userPhoto"])) {
                        NSDictionary *userPhoto = userInfoBase[@"userPhoto"];
                        rcUser.portraitUri = [NSString stringWithFormat:ImgLoadUrl,userPhoto[@"location"]];
                    }
                }
                completion(rcUser);
            }
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
    NSDictionary *param2 = @{@"uid":userId};
    [[LYAPIManager sharedInstance] POST:@"/transportion/driver/queryDriverDetail" parameters:param2 progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {

            if (NotNilAndNull(result[@"data"])) {
                
                RCUserInfo *rcUser = [[RCUserInfo alloc] init];
                rcUser.userId = userId;
                NSDictionary *data = result[@"data"];
                if (NotNilAndNull(data[@"userInfoBase"])) {
                    
                    NSDictionary *userInfoBase = data[@"userInfoBase"];
                    if (NotNilAndNull(userInfoBase[@"userName"])) {
                        NSString *username = userInfoBase[@"userName"];
                        rcUser.name = username;
                    }
                    if (NotNilAndNull(userInfoBase[@"userPhoto"])) {
                        NSDictionary *userPhoto = userInfoBase[@"userPhoto"];
                        rcUser.portraitUri = [NSString stringWithFormat:ImgLoadUrl,userPhoto[@"location"]];
                    }
                }
                completion(rcUser);
            }
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    
    }];
}

- (void)initShareSDK {
    
    [ShareSDK registerApp:@"1c159dd84430c"
          activePlatforms:@[@(SSDKPlatformSubTypeWechatSession),
                            @(SSDKPlatformSubTypeWechatTimeline),
                            @(SSDKPlatformTypeQQ)]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:@"wxc8f1d1336cec8b0b"
                                       appSecret:@"63979547790ebf459b5f90c04891b76f"];
                 break;
             default:
                 [appInfo SSDKSetupQQByAppId:@"1105967425"
                                      appKey:@"HWkdUs0Y9zB6UGva"
                                    authType:SSDKAuthTypeBoth];
                 break;
         }
     }];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // Optional Error
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler
{
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]])
    {
        [JPUSHService handleRemoteNotification:userInfo];
        [JPUSHService resetBadge];
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService resetBadge];
        [JPUSHService handleRemoteNotification:userInfo];
        [self showMsgForUser:content.body];
    }
    completionHandler();  // 系统要求执行这个方法
}
#endif


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // Atleast iOS 7.0 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    NSLog(@"___%@",userInfo);
    NSDictionary *msg = userInfo[@"aps"];
    if (NotNilAndNull(msg[@"alert"])) {
        NSString *alert= msg[@"alert"];
        [self showMsgForUser:alert];
    }
}

- (void)showMsgForUser:(NSString *)msg {
    if (NotNilAndNull(msg)) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alertView show];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary*)options {
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:self];
}

//微信SDK自带的方法，处理从微信客户端完成操作后返回程序之后的回调方法,显示支付结果的
- (void)onResp:(BaseResp*)resp {
    
    NSString * wxPayResult;
    //判断是否是微信支付回调 (注意是PayResp 而不是PayReq)
    if ([resp isKindOfClass:[PayResp class]])
    {
        //支付返回的结果, 实际支付结果需要去微信服务器端查询
        switch (resp.errCode)
        {
            case WXSuccess:
            {
                wxPayResult = @"success";
                break;
            }
            case WXErrCodeUserCancel:
            {
                wxPayResult = @"cancel";
                break;
            }
            default:
            {
                wxPayResult = @"faile";
                NSLog(@"微信支付失败code——%d————str——%@",resp.errCode,resp.errStr);
                break;
            }
        }
        //发出通知 从微信回调回来之后,发一个通知,让请求支付的页面接收消息,并且展示出来,或者进行一些自定义的展示或者跳转
        NSNotification *notification = [NSNotification notificationWithName:@"WXPay" object:wxPayResult];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

@end
