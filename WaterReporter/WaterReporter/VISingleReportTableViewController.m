//
//  VISingleReportTableViewController.m
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/16/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import "VISingleReportTableViewController.h"
#import "PhotoViewController.h"
#import "ImageSaver.h"
#import "Report.h"
#import "user.h"

@interface VISingleReportTableViewController ()<UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
@end

@implementation VISingleReportTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.opaque = NO;
    
    self.title = self.report.report_type;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
