//
//  ViewController.h
//  MapKitTest
//
//  Created by Twisal on 15/10/28.
//  Copyright © 2015年 Twisal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface ViewController : UIViewController<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *centerImageView;//用来选位置的图片
@property (weak, nonatomic) IBOutlet UILabel *adressLabel;// 用来显示图地址

- (IBAction)touchedLocationBtn:(id)sender;

@end

