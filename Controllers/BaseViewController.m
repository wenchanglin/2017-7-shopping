//
//  BaseViewController.m
//  885logistics
//
//  Created by Blues on 17/1/3.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "BaseViewController.h"
#import <MBProgressHUD.h>

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navtitle_new"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18.f],NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    [self initData];
    [self createViews];
}

- (void)initData {
    
}

- (void)queryDataFromServer {


}

- (void)createViews {
    
}

- (void)addPopItem {
    
    UIImage *img = [[UIImage imageNamed:@"go_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStyleDone target:self action:@selector(popCurrentView:)];
    self.navigationItem.leftBarButtonItems = @[item];
}

- (void)popCurrentView:(UIBarButtonItem *)item {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showMessageForUser:(NSString *)message {
    
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
            hud.labelText = message;
            hud.labelFont = [UIFont systemFontOfSize:13.f];
            [hud hide:YES afterDelay:1.2];
        });
    });
}


- (void)replyPostWithPostID:(NSString *)postId {

}

- (void)reportPostWithPostID:(NSString *)postId {

}

- (void)playVideoWithUrlString:(NSString *)urlStr {

}

- (void)deletePostWithPostID:(PostModel *)postID {

}

- (void)doSomethingWithASModel:(AddressModel *)model {

}

- (void)somethingNeedAction1 {

}

- (void)somethingNeedAction2 {


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
