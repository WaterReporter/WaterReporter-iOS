//
//  VIReportsTableViewController.h
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/15/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Report.h"
#import "VISingleReportTableViewController.h"

@interface VIReportsTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *reports;

@end
