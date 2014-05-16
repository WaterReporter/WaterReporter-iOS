//
//  VIFirstViewController.h
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/15/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBXMapKit/MBXMapKit.h>

@interface VILocationViewController : UIViewController<MKMapViewDelegate>

@property (strong, nonatomic) MBXMapView *mapView;
@property BOOL userLocationUpdated;

@end
