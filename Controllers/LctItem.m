//
//  LctItem.m
//  LogisticsDriver
//
//  Created by Blues on 17/3/19.
//  Copyright © 2017年 wenchanglin. All rights reserved.
//

#import "LctItem.h"

@implementation LctItem {

    CLLocationManager *_lctManager;
    BOOL _isLocation;
    UIView *_bkView;
    UIImageView *_lctIv;
    UILabel *_cityLb;
    UIActivityIndicatorView *_actView;
}

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self){
         [self createView];
         [self locationCurrentUser];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self createView];
        [self locationCurrentUser];
    }
    return self;
}


- (void)createView {
    
    _bkView = [[UIView alloc] initWithFrame:self.bounds];
    _bkView.backgroundColor = [UIColor clearColor];
    _lctIv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 13.f, 11.f, 15.f)];
    _lctIv.image = [UIImage imageNamed:@"hv_location_white"];
    [_bkView addSubview:_lctIv];
    _cityLb = [[UILabel alloc] initWithFrame:CGRectMake(18.f, 10.f, 60.f, 20.f)];
    _cityLb.textColor = [UIColor whiteColor];
    _cityLb.backgroundColor = [UIColor clearColor];
    _cityLb.font = [UIFont boldSystemFontOfSize:15.f];
    [_bkView addSubview:_cityLb];
    _actView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(16.f, 10.f, 20.f, 20.f)];
    _actView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    _actView.hidesWhenStopped = YES;
    [_actView startAnimating];
    _actView.backgroundColor = [UIColor clearColor];
    [_bkView addSubview:_actView];
    [self addSubview:_bkView];
}

#pragma mark - LocationManager
- (void)locationCurrentUser {
    
    if (!_lctManager) {
        _isLocation = YES;
        _lctManager = [[CLLocationManager alloc] init];
        _lctManager.desiredAccuracy = kCLLocationAccuracyBest;
        _lctManager.distanceFilter = 10000.f;
        _lctManager.delegate = self;
        [_lctManager requestWhenInUseAuthorization];
        [_lctManager startUpdatingLocation];
    }
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *location = [locations firstObject];
    if (_isLocation && location) {
         _isLocation = NO;
        [self updateMyLocationLatitude:location.coordinate.latitude longtitude:location.coordinate.longitude];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error){
            if (array.count){
                CLPlacemark *placemark = [array objectAtIndex:0];
                NSString *city = placemark.locality;
                if (!city) {
                    city = placemark.administrativeArea;
                }
                if (NotNilAndNull(city)) {
                    [_actView stopAnimating];
                     _cityLb.text = city;
                    [[NSUserDefaults standardUserDefaults] setObject:city forKey:@"location"];
                }
            }
        }];
    }
    [_lctManager stopUpdatingLocation];
}

#pragma mark - UpdateMyLocation
- (void)updateMyLocationLatitude:(double)latitude longtitude:(double)longtitude {
    
    NSDictionary *param = @{@"uid":[LYHelper getCurrentUserID],
                            @"x":@(latitude),
                            @"y":@(longtitude)
                            };
    [[LYAPIManager sharedInstance] POST:@"transportion/driver/uploadCoordinateData" parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([result[@"errcode"] integerValue] == 0) {
            NSLog(@"位置信息更新成功");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}



@end
