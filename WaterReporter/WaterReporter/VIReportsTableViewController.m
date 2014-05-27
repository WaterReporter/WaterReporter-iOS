//
//  VIReportsTableViewController.m
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/15/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import "VIReportsTableViewController.h"

#define COLOR_BRAND_BLUE_BASE [UIColor colorWithRed:20.0/255.0 green:165.0/255.0 blue:241.0/255.0 alpha:1.0]
#define COLOR_BRAND_WHITE_BASE [UIColor colorWithWhite:242.0/255.0f alpha:1.0f]

@interface VIReportsTableViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation VIReportsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"My Reports";

    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self setupReachability];
    
}

- (void) checkNetworkAvailability
{
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    NSLog(@"Network Status %@", self.networkStatus);

}

- (void) setupReachability
{
    NSURL *baseURL = [NSURL URLWithString:@"http://api.commonscloud.org/"];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    
    NSOperationQueue *operationQueue = manager.operationQueue;
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [operationQueue setSuspended:NO];
                self.networkStatus = @"reachable";
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [operationQueue setSuspended:YES];
                self.networkStatus = @"unreachable";
                break;
        }
    }];

}

- (void) submitAllUnsubmittedReports
{
    
    for (Report *report in self.reports) {
        if (!report.feature_id) {
            NSLog(@"Report Needs Submitted to Server: %@", report);
        }
        else {
            NSLog(@"Report Submitted, Feature ID: %@", report.feature_id);
        }
    }
    
}

- (void) postReport:(Report*)report
{
    NSLog(@"Post to server %@", report);
}

- (void) viewWillAppear:(BOOL)animated
{
    self.reports = [Report MR_findAllSortedBy:@"created" ascending:NO];
    
    [self checkNetworkAvailability];
    
    if ([self.networkStatus isEqualToString:@"reachable"]) {
        [self submitAllUnsubmittedReports];
    }

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.reports.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	[self configureCell:cell atIndex:indexPath];
    
    return cell;
}



- (void)configureCell:(UITableViewCell*)cell atIndex:(NSIndexPath*)indexPath
{

    Report *report = self.reports[indexPath.row];
    NSString *reportType = report.report_type;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:report.date];

    NSString *text = @"";
    
    if([reportType isEqualToString:@"Activity Report"]){
        text = [NSString stringWithFormat: @"Activity Report on %@", dateString];
    }
    else if([reportType isEqualToString:@"Pollution Report"]){
        text = [NSString stringWithFormat: @"Pollution Report on %@", dateString];
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    cell.textLabel.font = [UIFont systemFontOfSize:13.0];
    cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:128.0/255.0 alpha:1.0]}];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VISingleReportTableViewController *singleReportTableViewController = [[VISingleReportTableViewController alloc] init];
    
    Report *report = self.reports[indexPath.row];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    singleReportTableViewController.report = report;
    
    [self.navigationController pushViewController:singleReportTableViewController animated:YES];
}

@end
