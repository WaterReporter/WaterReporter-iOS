//
//  VIFirstViewController.h
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/15/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBXMapKit/MBXMapKit.h>
#import "VITutorialViewController.h"
#import "VILoginTableViewController.h"

@interface VILocationViewController : UIViewController<MKMapViewDelegate>

@property (strong, nonatomic) NSArray *userArray;
@property (strong, nonatomic) MBXMapView *mapView;
@property BOOL userLocationUpdated;
@property (strong, nonatomic) VITutorialViewController *tutorialVC;

@end
