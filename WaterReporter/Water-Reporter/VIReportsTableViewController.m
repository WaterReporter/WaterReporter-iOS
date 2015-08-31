//
//  VIReportsTableViewController.m
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/15/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import "VIReportsTableViewController.h"
#import "Lockbox.h"

#define kWaterReporterUserAccessToken        @"kWaterReporterUserAccessToken"

@implementation VIReportsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
 
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    self.title = @"Profile";
    
    //
    //
    //
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    //
    //
    //
    NSURL *baseURL = [NSURL URLWithString:@"http://api.waterreporter.org/"];
    self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    self.serializer = [AFJSONRequestSerializer serializer];
    
    [self.serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    self.manager.requestSerializer = self.serializer;
    
    NSString *accessToken = [Lockbox stringForKey:kWaterReporterUserAccessToken];
    
    [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
    

    //
    //
    //
    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:self action:@selector(userLogout)];
    
    self.navigationItem.rightBarButtonItem = logoutItem;

}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"viewDidAppear");
    [self refreshTableView];
    [self.tableView reloadData];
}

- (BOOL)connected {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

- (void) enableTableRefresh
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];

}

- (void) refreshTableView
{
    
    NSLog(@"refreshTableView");
    __weak typeof(self) weakSelf = self;
    
    if ([self shouldAttemptSubmission]) {
        NSLog(@"Submission found, we need to attempt to submit them");
        if (!self.isRefreshing) {
            self.isRefreshing = true;
            NSLog(@"Unsubmitted reports found ... do SOMETHING!!!");
            if ([self connected]) {
                NSLog(@"Connected to network, try to submit, then end refreshing and reload table data");
                [weakSelf submitReports];
            } else {
                NSLog(@"No network connection, show an alert");

                [self.refreshControl endRefreshing];
                self.isRefreshing = false;
                [self.tableView reloadData];

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh" message:@"It looks like you don't have access to a data network right now." delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
            NSLog(@"PASSED CONDITOINAL .... did anything happen??");
        } else {
            NSLog(@"PASSED the isRefreshing conditional");
        }
        NSLog(@"SKIPPED the isRefreshing conditional");
    } else {
        NSLog(@"No unsubmitted reports, end refreshing and reload table data");
        self.isRefreshing = false;
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }
}

- (int) shouldAttemptSubmission
{
    NSLog(@"shouldAttemptSubmission");
    
    if ([self countUnsubmittedReports] == 0) {
        return false;
    }
    
    return true;
}

- (int) countUnsubmittedReports
{
    NSMutableArray *reports = [[Report MR_findAllSortedBy:@"created" ascending:NO inContext:[NSManagedObjectContext MR_defaultContext]] mutableCopy];

    NSMutableArray *unsubmittedReports = [[NSMutableArray alloc] init];

    for (Report *report in reports) {
        if (!report.feature_id) {
            [unsubmittedReports addObject:report];
        }
    }
    
    NSLog(@"count of unsubmitted reports %d", unsubmittedReports.count);
    return unsubmittedReports.count;
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state {
    
    NSLog(@"refreshInvoked");
    
    [self refreshTableView];

}

- (void) submitReports
{
    
    NSLog(@"submitReports");
    

    //
    // Make sure we have the most recent list of reports before trying to submit them to the database
    //
    self.reports = [[Report MR_findAllSortedBy:@"created" ascending:NO inContext:[NSManagedObjectContext MR_defaultContext]] mutableCopy];

    for (Report *report in self.reports) {
        NSLog(@"report, %@", report);
        if (!report.feature_id) {
            [self postReport:report];
        }
    }
    
}

- (void) userLogout
{
    [Lockbox setString:@"" forKey:kWaterReporterUserAccessToken];

    [self.manager POST:@"http://api.waterreporter.org/v1/auth/logout" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        VILoginTableViewController *modal = [[VILoginTableViewController alloc] init];
        UINavigationController *modalNav = [[UINavigationController alloc] initWithRootViewController:modal];
        [self presentViewController:modalNav animated:NO completion:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}

- (void) postReport:(Report*)report
{
    
    NSLog(@"postReport");

    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:report.image];
    NSURL *imageURL = [NSURL fileURLWithPath:filePath];
    
    //
    // After we save it to the system, we should send the user over to the "My Submission" tab
    // and clear all the form fields
    //
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:report.report_date];
    
    
    [self.manager POST:@"http://api.waterreporter.org/v1/media/image" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSError *error;
        [formData appendPartWithFileURL:imageURL name:@"image" fileName:filePath mimeType:@"image/jpg" error:&error];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSMutableDictionary *json= [[NSMutableDictionary alloc] init];
        
        [json setValue:report.geometry forKey:@"geometry"];
        [json setObject:dateString forKey:@"report_date"];
        [json setObject:report.report_description forKey:@"report_description"];
        [json setObject:@"open" forKey:@"state"];
        [json setObject:@"true" forKey:@"is_public"];
        [json setObject:@[@{@"id": responseObject[@"id"]}] forKey:@"images"];
        
        NSLog(@"Attempting to post %@", json);

        [self.manager POST:@"http://api.waterreporter.org/v1/data/report" parameters:(NSDictionary *)json success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
            NSLog(@"responseObject: %@", responseObject[@"id"]);
    
            [self updateReportFeatureID:report response_id:responseObject[@"id"]];
    
            if ([self countUnsubmittedReports] == 0) {
                [self.refreshControl endRefreshing];
                self.isRefreshing = false;
                [self.tableView reloadData];
            } else {
                NSLog(@"We need to submit another one");
                [self refreshTableView];
            }
    
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [self.refreshControl endRefreshing];
            self.isRefreshing = false;
            [self.tableView reloadData];
        }];
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"IMAGE ERROR %@", error);
    }];


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
    self.reports = [[Report MR_findAllSortedBy:@"created" ascending:NO inContext:[NSManagedObjectContext MR_defaultContext]] mutableCopy];
    
    [self enableTableRefresh];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.sel
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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:report.report_date];

    NSString *text = [NSString stringWithFormat: @"Report on %@", dateString];
    
    if (![self connected] && !report.feature_id) {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (report.feature_id) {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    //
    // Else If failed or no network, then show /!\ icon
    //
    else {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner setFrame:CGRectMake(0, 0, 10, 10)];
        [spinner startAnimating];
        cell.accessoryView = spinner;
    }

    cell.textLabel.font = [UIFont systemFontOfSize:13.0];
    cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:128.0/255.0 alpha:1.0]}];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VISingleReportTableViewController *singleReportTableViewController = [[VISingleReportTableViewController alloc] init];
    
    Report *report = self.reports[indexPath.row];
    
    if (report.feature_id) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        
        singleReportTableViewController.report = report;
        singleReportTableViewController.reportID = [report.feature_id stringValue];
        
        [self.navigationController pushViewController:singleReportTableViewController animated:YES];
    } else {
        //
        // Let the user know why there was an error
        //
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Slow Down" message:@"We're still proccessing your report, you'll be able to see it shortly" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
    }
    
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView beginUpdates];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Remove Report from TableView
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 
        // Remove Report from database
        Report *report = self.reports[indexPath.row];
        [report MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reportDeleted" object:nil];

         // Remove Report from self.reports
        [self.reports removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
    [tableView endUpdates];

}

@end
