//
//  VISingleReportTableViewController.h
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/16/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PhotoViewController.h"
#import "Lockbox.h"
#import "Report.h"
#import "User.h"
#import "UIImage+ResizeMagick.h"
#import <AFNetworking/AFNetworking.h>
#import "MBProgressHUD.h"

@class Report;

@interface VISingleReportTableViewController : UITableViewController

@property (nonatomic, strong) NSString *reportID;
@property (nonatomic, strong) Report *report;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) UILabel *loadingLabel;

@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) AFJSONRequestSerializer *serializer;

@property (strong, nonatomic) NSArray *groups;
@property (strong, nonatomic) NSArray *usersGroups;

@property (nonatomic, strong) MBProgressHUD *hud;

- (void) setupStaticSingleViewDetails:(NSDictionary *)report;

@end
