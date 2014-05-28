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
#define REPORT_ENDPOINT @"http://api.commonscloud.org/v2/type_2c1bd72acccf416aada3a6824731acc9.json"

@interface VIReportsTableViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation VIReportsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"My Reports";

    self.tableView.backgroundColor = [UIColor whiteColor];
    
    NSURL *baseURL = [NSURL URLWithString:@"http://api.commonscloud.org/"];
    self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    [self setupReachability];
}

- (void) enableTableRefresh
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];

}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state {

    if ([self.networkStatus isEqualToString:@"reachable"]) {
        [self submitAllUnsubmittedReports];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh" message:@"It looks like you don't have access to a data network right now." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }

    [self.tableView reloadData];
}

- (void) checkNetworkAvailability
{
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    NSLog(@"Network Status %@", self.networkStatus);

}

- (void) setupReachability
{
    
    NSOperationQueue *operationQueue = self.manager.operationQueue;
    [self.manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
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
            [self postReport:report];
        }
    }
    
    [self.refreshControl endRefreshing];
}

- (void) postReport:(Report*)report
{
    NSLog(@"Post to server %@", report);
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];

    NSData *imgData = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:report.image]];
    
    User *user = [User MR_findFirst];

    //
    // After we save it to the system, we should send the user over to the "My Submission" tab
    // and clear all the form fields
    //
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:report.date];
    NSString *createdString = [dateFormatter stringFromDate:report.created];
    
    NSDictionary *geojson =
    [NSJSONSerialization JSONObjectWithData:[report.geometry dataUsingEncoding:NSUTF8StringEncoding]
                                    options:NSJSONReadingMutableContainers
                                      error:nil];
    
    NSLog(@"GEOJSON %@", geojson);

    
    NSMutableDictionary *json= [[NSMutableDictionary alloc] init];
    
    [json setObject:createdString forKey:@"created"];
    [json setObject:geojson forKey:@"geometry"];
    [json setObject:@"public" forKey:@"status"];
    [json setObject:dateString forKey:@"date"];
    [json setObject:report.comments forKey:@"comments"];
    [json setObject:user.email forKey:@"useremail_address"];
    [json setObject:user.name forKey:@"username"];
    [json setObject:user.user_type forKey:@"usertitle"];

    NSLog(@"json %@", json);

    
    
//    // @TODO
//    //
//    // - Set Report type
//    // - Set Activity Type
//    // - Set Pollution Type
//    // - Upload Image
    
    
    if (imgData == nil) {
        NSLog(@"No Image Data");
        [self.manager POST:REPORT_ENDPOINT parameters:json success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: %@", responseObject);
            [self updateReportFeatureID:report response_id:[responseObject valueForKey:@"resource_id"]];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    else {
        NSLog(@"Image Data");
        [self.manager POST:REPORT_ENDPOINT parameters:json constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imgData name:@"image" fileName:@"image" mimeType:@"image/jpeg"];
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Success: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    }
    
    [self.tableView reloadData];
}

-(void) updateReportFeatureID:(Report *)report response_id:(NSNumber *)feature_id
{
   
    Report *thisReport = [Report MR_findFirstByAttribute:@"uuid" withValue:report.uuid];
    thisReport.feature_id = feature_id;
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reportSaved" object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.reports = [Report MR_findAllSortedBy:@"created" ascending:NO];
    
    [self checkNetworkAvailability];
    
    if ([self.networkStatus isEqualToString:@"reachable"]) {
        [self submitAllUnsubmittedReports];
    }
    
    [self enableTableRefresh];

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
    
    if (report.feature_id) {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        UIImage *accessoryStatusImage = [UIImage imageNamed:@"ReloadAccessoryTypeDefault"];
        
        UIImageView *accessoryStatusView = [[UIImageView alloc] initWithImage:accessoryStatusImage];
        cell.accessoryView = accessoryStatusView;
    }

    cell.textLabel.font = [UIFont systemFontOfSize:13.0];
    cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:128.0/255.0 alpha:1.0]}];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VISingleReportTableViewController *singleReportTableViewController = [[VISingleReportTableViewController alloc] init];
    
    Report *report = self.reports[indexPath.row];
    
    NSLog(@"%@", report);
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    singleReportTableViewController.report = report;
    
    [self.navigationController pushViewController:singleReportTableViewController animated:YES];
}

@end
