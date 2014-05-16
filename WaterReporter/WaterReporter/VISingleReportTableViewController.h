//
//  VISingleReportTableViewController.h
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/16/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Report;

@interface VISingleReportTableViewController : UITableViewController

@property (nonatomic, strong) Report *report;

@end
