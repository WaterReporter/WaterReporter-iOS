//
//  VIFirstViewController.h
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/15/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBXMapKit/MBXMapKit.h>
#import <AFNetworking/AFNetworking.h>
#import "VITutorialViewController.h"
#import "VILoginTableViewController.h"
#import "VIPointAnnotation.h"
#import "VISingleReportTableViewController.h"

@interface VILocationViewController : UIViewController<MKMapViewDelegate>

@property (strong, nonatomic) NSArray *userArray;
@property (strong, nonatomic) MBXMapView *mapView;
@property BOOL userLocationUpdated;
@property (strong, nonatomic) VITutorialViewController *tutorialVC;
@property (strong, nonatomic) NSArray *markers;
@property (strong, nonatomic) NSString *annotationTitle;
@property BOOL annotationPinType;
@property BOOL loadingMapForForm;

@property (retain, nonatomic) NSString *networkStatus;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;

- (void)showSingleReport:(NSString *)reportID;

@end
