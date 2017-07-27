//
//  CLLocation+Sino.h
//

#import <CoreLocation/CoreLocation.h>


@interface CLLocation (Sino)

+ (CLLocationCoordinate2D)transform:(CLLocationCoordinate2D)latLng;

@end