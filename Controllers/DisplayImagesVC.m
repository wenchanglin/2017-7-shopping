//
//  DisplayImagesVC.m
//  DAup
//
//  Created by Blues on 16/9/21.
//  Copyright © 2016年 LTD.wenchanglin. All rights reserved.
//

#import "DisplayImagesVC.h"

@interface DisplayImagesVC ()<UIScrollViewDelegate> {
    
    UIScrollView *_subScroll;
    NSInteger _index;
}

@property (nonatomic, strong) UIScrollView *bigScrollView;

@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation DisplayImagesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *bk = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height)];
    bk.backgroundColor = [UIColor darkGrayColor];
    bk.alpha = 0.7f;
    [self.view addSubview:bk];
    
    [self createView];
    // Do any additional setup after loading the view.
    [self addBackAction];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];//黑色
}

- (void)addBackAction {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(DismissThisView)];
    [self.view addGestureRecognizer:tap];
}

- (void)DismissThisView {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.myblock) {
            self.myblock();
        }
    }];
}

- (void)hideTabbarWithBlock:(hideBlock)block {
    self.myblock = block;
}

- (void)createView {
    
    self.view.backgroundColor = [UIColor clearColor];
    
    for (NSString *img in self.images) {
        if (img.length == 0) {
            [self.images removeObject:img];
        }
    }
    self.bigScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height)];
    self.bigScrollView.backgroundColor = [UIColor clearColor];
    self.bigScrollView.delegate = self;
    self.bigScrollView.bounces = NO;
    self.bigScrollView.tag = 888;
    self.bigScrollView.pagingEnabled = YES;
    self.bigScrollView.contentSize = CGSizeMake(kScreenSize.width * self.images.count, 0);
    [self.bigScrollView setContentOffset:CGPointMake(kScreenSize.width * (self.off-1), 0)];
    self.bigScrollView.showsVerticalScrollIndicator = NO;
    self.bigScrollView.showsHorizontalScrollIndicator = NO;
    
    [self.view addSubview:self.bigScrollView];
    
    
    NSInteger offset = 0;
    
    for (NSString *imageid in self.images) {
    
        UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(kScreenSize.width * offset , 0, kScreenSize.width, kScreenSize.height)];
        scroll.minimumZoomScale = 1;
        scroll.maximumZoomScale = 3.0;
    
        scroll.showsHorizontalScrollIndicator = NO;
        scroll.showsVerticalScrollIndicator = NO;
        scroll.delegate = self;
        scroll.backgroundColor = [UIColor clearColor];
        
        NSString *imageUrl = [NSString stringWithFormat:ImgLoadUrl,imageid];
        //NSLog(@"-当前图片链接---->%@",imageUrl);
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = 200 + offset;
        [scroll addSubview:imageView];
        
//        UIButton *lp = [[UIButton alloc] initWithFrame:CGRectMake((kScreenSize.width)/2.f - 40.f, kScreenSize.height - 50.f, 80, 28.f)];
//        lp.tag = 100 + offset;
//        lp.titleLabel.font = [UIFont systemFontOfSize:14.f];
//        lp.layer.cornerRadius = 3.f;
//        lp.layer.borderColor = [UIColor whiteColor].CGColor;
//        lp.layer.borderWidth = 1.f;
//        [lp setTitle:@"保存图片" forState:UIControlStateNormal];
//        [lp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [lp addTarget:self action:@selector(savePicture:) forControlEvents:UIControlEventTouchUpInside];
//        [scroll addSubview:lp];
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                //NSLog(@"-图片加载出错----->%@",error);
            }else {
                
                CGSize suitableSize = [self suitableSize:kScreenSize imageSize:image.size];//合适的大小
                //NSLog(@"计算合适大小－－>>>>－－%@",NSStringFromCGSize(suitableSize));
                CGRect frameIV = imageView.frame;
                frameIV.size.width = suitableSize.width;
                frameIV.size.height = suitableSize.height;
                imageView.frame = frameIV;
                imageView.center = CGPointMake(kScreenSize.width/2.f, kScreenSize.height/2.f);
            }
        }];
        
        [self.bigScrollView addSubview:scroll];
        if (offset == 0) {
            _index = 0;
            _subScroll = scroll;
        }
        offset ++;
    }

    [self.view addSubview:self.pageControl];
}
//
//- (void)savePicture:(UIButton *)lp {
//    
//    UIImageView *iv = [self.view viewWithTag:lp.tag + 100];
//    UIImage *img = iv.image;
//    
//    if (img) {
//        
//        [self loadImageFinished:img];
//    }
//
//}
//- (void)loadImageFinished:(UIImage *)image {
//    
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
//}
//
//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
//    
//    if (error) {
//    
//        NSLog(@"保存失败");
//        [self showMessageForUser:@"保存失败"];
//    }else {
//        NSLog(@"保存成功");
//        [self showMessageForUser:@"保存成功"];
//    }
//    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
//}
//
//- (void)showMessageForUser:(NSString *)message {
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.removeFromSuperViewOnHide = YES;
//        hud.mode = MBProgressHUDModeText;
//        hud.animationType = MBProgressHUDAnimationZoomIn;
//        hud.cornerRadius = 8;
//        hud.labelText = message;
//        [hud hide:YES afterDelay:1.6];
//    });
//}


- (UIPageControl *)pageControl {

    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(10.f, kScreenSize.height - 80.f, kScreenSize.width - 20.f, 30.f)];
        _pageControl.backgroundColor = [UIColor clearColor];
        _pageControl.currentPageIndicatorTintColor = LineRedColor;
        _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.numberOfPages = self.images.count;
        _pageControl.enabled = NO;
        _pageControl.hidesForSinglePage = YES;
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}

#pragma mark - pageControl
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.tag == 888) {
        
        // 获取当前的偏移量，计算当前第几页
        int page = self.bigScrollView.contentOffset.x / kScreenSize.width + 0.5;
        // 设置页数
        self.pageControl.currentPage = page;
    }
}


#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView.tag == 888) {    //只响应外层scrollView的滑动事件
        
        NSInteger index = scrollView.contentOffset.x/kScreenSize.width;
        if (_index != index) {
            //恢复大小
            _subScroll .zoomScale = 1;
            
            //[--更新当前信息,  以备下次使用
            UIScrollView *subScroll = (UIScrollView *)scrollView.subviews[index];
            _subScroll = subScroll;
            _index = index;
            //-]
        }
    }else{
        NSLog(@"Do nothing.");
    }
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    //NSLog(@"zoom change:%.2f", scrollView.zoomScale);
    //保证图片在缩放过程中居中显示 [--
    UIView * imgView = [scrollView subviews].firstObject;
    CGFloat centerX = scrollView.frame.size.width/2.f;
    CGFloat centerY = scrollView.frame.size.height/2.f;
    
    centerX = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : centerX;
    centerY = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : centerY;
    
    imgView.center = CGPointMake(centerX, centerY);//-]
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return [scrollView subviews].firstObject;   //返回要缩放的对象
}

- (CGSize)suitableSize:(CGSize)size imageSize:(CGSize)imgSize{   //计算UIImageView的合适大小
    
    CGFloat scale = size.width/imgSize.width < size.height/imgSize.height ? size.width/imgSize.width : size.height/imgSize.height;
    CGFloat width = imgSize.width * scale > size.width ? size.width : imgSize.width * scale;
    CGFloat height = imgSize.height * scale > size.height ? size.height : imgSize.height * scale;
    return CGSizeMake(width, height);
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
