//
//  ViewController.m
//  MapKitTest
//
//  Created by Twisal on 15/10/28.
//  Copyright © 2015年 Twisal. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()
{
    NSString *_longitude;//用户经度
    NSString *_latitude;//用户纬度
    BOOL isAppear;//地图是否显示完成
    
}
@property (nonatomic, strong) CLGeocoder* geocoder;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayUserLocation:) name:@"inceptCoordinate" object:nil];
    _mapView.mapType = MKMapTypeStandard;
    _mapView.userTrackingMode = MKUserTrackingModeFollow;//是否跟踪
    _mapView.rotateEnabled = NO;
    isAppear = NO;

}
- (void)displayUserLocation:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    CLLocationCoordinate2D cl = CLLocationCoordinate2DMake([dict[@"latitude"] floatValue], [dict[@"longitude"] floatValue]);
    _mapView.centerCoordinate = cl;

}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//        //    //只要加上这段代码他就会出现一个图片
//        CLLocationCoordinate2D coords = _mapView.userLocation.location.coordinate;
//        //地图的缩放比例
//        MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
//        //构造地图显示范围
//        MKCoordinateRegion region = MKCoordinateRegionMake(coords, span);
//        [_mapView setRegion:region animated:YES];
    isAppear = YES;
    _centerImageView.hidden = NO;
}
#pragma mark mapViewDelegate
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLLocationCoordinate2D coord = [userLocation coordinate];
    NSLog(@"mapView经度:%f,纬度:%f",coord.latitude,coord.longitude);
    _longitude = [NSString stringWithFormat:@"%f" ,coord.longitude];
    _latitude = [NSString stringWithFormat:@"%f" ,coord.latitude];
}
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"定位失败：%@",error);
}
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    _adressLabel.text = @"正在获取你选择的地点...";
    NSLog(@"将要变化");
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    [_geocoder cancelGeocode];
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (_longitude != nil && isAppear == YES) {
        CLLocationCoordinate2D cl =  mapView.centerCoordinate;
        NSLog(@"转换前：%f,%f",cl.latitude,cl.longitude);
        typeof(ViewController *)weakSelf = self;
        CLLocationCoordinate2D earthCL = [self gcj2wgs:cl ];
        //FIXME:不知什么原因有时候 PBRequester failed with Error Error Domain=NSURLErrorDomain Code=-1001 "The request timed out."所以加了线程，然并卵
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [weakSelf reverseGeocode1:earthCL.latitude  longitude:earthCL.longitude];
         dispatch_async(dispatch_get_main_queue(), ^{
             [UIView animateWithDuration:0.8 animations:^{
                 _centerImageView.center = CGPointMake(weakSelf.view.center.x, weakSelf.view.center.y-25);
             } completion:^(BOOL finished) {
                 _centerImageView.center = CGPointMake(weakSelf.view.center.x, weakSelf.view.center.y-15);
             }];
         });
        });
    }
}
#pragma mark 反地理编码
- (void)reverseGeocode1:(double)_lat longitude:(double)_long
{
    NSLog(@"转换后:%f,%f",_lat,_long);
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    //注意初使化location参数 double转换，这里犯过错，    此外一般会用 全局_currLocation，在定位后得到
    CLLocation* location = [[CLLocation alloc] initWithLatitude:_lat longitude:_long];
    [_geocoder reverseGeocodeLocation:location
                    completionHandler:^(NSArray* placemarks, NSError* error) {
                        CLPlacemark* placemark = [placemarks firstObject];
                        NSLog(@"详细信息:%@", placemark.addressDictionary);
                        if(placemark.addressDictionary == nil){
                            _adressLabel.text = @"地图君没有识别此地。。。";
                        }else {
                        _adressLabel.text = [NSString stringWithFormat:@"%@",placemark.addressDictionary[@"Name"]];
                        }
                    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 火星坐标转换成地球坐标
const double a = 6378245.0;
const double ee = 0.00669342162296594323;
- (BOOL)outOfChina:(CLLocationCoordinate2D) coordinate
{
    if (coordinate.longitude < 72.004 || coordinate.longitude > 137.8347)
        return YES;
    if (coordinate.latitude < 0.8293 || coordinate.latitude > 55.8271)
        return YES;
    return NO;
}
double transformLat(double x, double y)
{
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0;
    return ret;
}

static double transformLon(double x, double y)
{
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x));
    ret += (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0;
    return ret;
}
// 地球坐标系 (WGS-84) <- 火星坐标系 (GCJ-02)

- (CLLocationCoordinate2D) gcj2wgs:(CLLocationCoordinate2D) coordinate
{
    if ([self outOfChina:coordinate]) {
        return coordinate;
    }
    CLLocationCoordinate2D c2 = [self wgs2gcj:coordinate];
    return CLLocationCoordinate2DMake(2 * coordinate.latitude - c2.latitude, 2 * coordinate.longitude - c2.longitude);
}
// 地球坐标系 (WGS-84) -> 火星坐标系 (GCJ-02)

- (CLLocationCoordinate2D) wgs2gcj:(CLLocationCoordinate2D) coordinate
{
    if ([self outOfChina:coordinate]) {
        return coordinate;
    }
    double wgLat = coordinate.latitude;
    double wgLon = coordinate.longitude;
    double dLat = transformLat(wgLon - 105.0, wgLat - 35.0);
    double dLon = transformLon(wgLon - 105.0, wgLat - 35.0);
    double radLat = wgLat / 180.0 * M_PI;
    double magic = sin(radLat);
    magic = 1 - ee * magic * magic;
    double sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (a / sqrtMagic * cos(radLat) * M_PI);
    return CLLocationCoordinate2DMake(wgLat + dLat, wgLon + dLon);
    
}
//点击用户位置按钮
- (IBAction)touchedLocationBtn:(id)sender {
    [_mapView setCenterCoordinate:_mapView.userLocation.coordinate animated:YES];
}
@end

