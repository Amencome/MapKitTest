//
//  GPSLocation.h
//  Demo
//  封装的定位类
//  Created by Twisal on 15/9/21.
//  Copyright (c) 2015年 Twisal. All rights reserved.
//

#import <Foundation/Foundation.h>
//定位库的头文件
#import <CoreLocation/CoreLocation.h>
@interface GPSLocation : NSObject<CLLocationManagerDelegate>
@property(nonatomic,strong)CLLocationManager *locMgr;
+(GPSLocation *)sharedGPSLocation;
- (void)startLocation;
@end
