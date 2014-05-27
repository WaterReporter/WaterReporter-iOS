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
#import "ImageSaver.h"
#import "Report.h"
#import "User.h"
#import "Gravatar.h"
#import "UIImage+ResizeMagick.h"

@class Report;

@interface VISingleReportTableViewController : UITableViewController

@property (nonatomic, strong) Report *report;
@property (nonatomic, strong) Gravatar *gravatar;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *originalImage;

@end
