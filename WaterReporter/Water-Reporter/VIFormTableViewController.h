//
//  VISecondViewController.h
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/15/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MBXMapKit/MBXMapKit.h>
#import "VILocationViewController.h"
#import "Report.h"
#import "User.h"

@interface VIFormTableViewController : UITableViewController<UIPickerViewDelegate, UIPickerViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,CLLocationManagerDelegate,MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

// Template Information
@property (strong, nonatomic) Report *report;
@property (strong, nonatomic) NSString *reportType;
@property (nonatomic) NSMutableArray *reports;

@property (strong, nonatomic) NSString *template;
@property (strong, nonatomic) NSArray *templates;

@property (strong, nonatomic) UIToolbar *toolbar;

// Template fields
@property (strong, nonatomic) NSArray *fields;

@property (strong, nonatomic) NSArray *pollutionFields;
@property (strong, nonatomic) NSArray *activityFields;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UITextField *pollutionDateField;
@property (strong, nonatomic) UITextField *activityDateField;

@property (strong, nonatomic) UITextField *pollutionTypeField;
@property (strong, nonatomic) UIPickerView *pollutionPickerView;
@property (strong, nonatomic) NSArray *pollutionEnums;

@property (strong, nonatomic) UITextField *activityTypeField;
@property (strong, nonatomic) UIPickerView *activityPickerView;
@property (strong, nonatomic) NSArray *activityEnums;

@property (strong, nonatomic) UITextField *commentsField;
@property (strong, nonatomic) UITextField *geometryField;
@property (strong, nonatomic) UITextField *imageField;


// Location Information
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) VILocationViewController *mapVC;
@property (strong, nonatomic) UITapGestureRecognizer *gestureRecognizer;
@property (strong, nonatomic) UINavigationController *mapNavigationController;
@property (nonatomic) float temporaryLatitude;
@property (nonatomic) float temporaryLongitude;
@property (nonatomic) float reportLatitude;
@property (nonatomic) float reportLongitude;
@property (strong,nonatomic) MKPinAnnotationView *updatedLocationPin;

// Media Information
@property (strong, nonatomic) UIImagePickerController *cameraUI;
@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) NSString *path;

- (void) activityViewTapGestureRecognized:(UITapGestureRecognizer*)gestureRecognizer;
- (void) pollutionViewTapGestureRecognized:(UITapGestureRecognizer*)gestureRecognizer;

@end
