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
    NSLog(@"viewDidLoad");
 
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    self.title = @"My Reports";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    NSURL *baseURL = [NSURL URLWithString:@"http://api.commonscloud.org/"];
    self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    
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
        if (!report.feature_id) {
            [self postReport:report];
        }
    }
    
}

- (void) postReport:(Report*)report
{
    
    NSLog(@"postReport");

    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:report.image];
    NSURL *imageURL = [NSURL fileURLWithPath:filePath];
    
    User *user = [User MR_findFirst];

    //
    // After we save it to the system, we should send the user over to the "My Submission" tab
    // and clear all the form fields
    //
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:report.date];
    NSString *createdString = [dateFormatter stringFromDate:report.created];
    
    NSString *relationship;
    NSString *is_a_pollution_report = @"false";
    
    if ([report.report_type isEqualToString:@"Activity Report"]) {
        relationship = @"[{\"id\":1}]";
    } else if ([report.report_type isEqualToString:@"Pollution Report"]) {
        relationship = @"[{\"id\":2}]";
        is_a_pollution_report = @"true";
    }

    
    NSMutableDictionary *json= [[NSMutableDictionary alloc] init];

    [json setObject:createdString forKey:@"created"];
    [json setObject:@"public" forKey:@"status"];
    [json setObject:user.email forKey:@"useremail_address"];
    [json setObject:user.name forKey:@"username"];
    [json setObject:user.user_type forKey:@"usertitle"];
    [json setValue:report.geometry forKey:@"geometry"];
    [json setObject:dateString forKey:@"date"];
    [json setObject:report.comments forKey:@"comments"];
    [json setObject:user.email forKey:@"useremail_address"];
    [json setObject:user.name forKey:@"username"];
    [json setObject:is_a_pollution_report forKey:@"is_a_pollution_report?"];
    [json setObject:user.user_type forKey:@"usertitle"];
    [json setObject:relationship forKey:@"type_8f432efc18c545ea9578b4bdea860b4c"];
    
    if ([report.report_type isEqualToString:@"Pollution Report"]) {
        [json setObject:[self findPollutionType:report.pollution_type] forKey:@"type_05a300e835024771a51a6d3114e82abc"];
    }

    if ([report.report_type isEqualToString:@"Activity Report"]) {
        [json setObject:[self findActivityType:report.activity_type] forKey:@"type_0e9423a9a393481f82c4f22ff5954567"];
    }
    
    [self.manager POST:@"http://api.commonscloud.org/v2/type_2c1bd72acccf416aada3a6824731acc9.json" parameters:(NSDictionary *)json constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSError *error;
        [formData appendPartWithFileURL:imageURL name:@"attachment_76fc17d6574c401d9a20d18187f8083e" fileName:filePath mimeType:@"image/png" error:&error];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self updateReportFeatureID:report response_id:[responseObject valueForKey:@"resource_id"]];
        
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
}

- (NSString *) findPollutionType:(NSString *)type
{
    
    NSNumber *typeId;
    
    if ([type isEqualToString:@"Discolored water"]) {
        typeId = @1;
    }
    else if ([type isEqualToString:@"Eroded stream banks"]) {
        typeId = @2;
    }
    else if ([type isEqualToString:@"Excessive trash"]) {
        typeId = @3;
    }
    else if ([type isEqualToString:@"Excessive algae"]) {
        typeId = @17;
    }
    else if ([type isEqualToString:@"Exposed soil"]) {
        typeId = @4;
    }
    else if ([type isEqualToString:@"Faulty construction entryway"]) {
        typeId = @5;
    }
    else if ([type isEqualToString:@"Faulty silt fences"]) {
        typeId = @6;
    }
    else if ([type isEqualToString:@"Fish kill"]) {
        typeId = @7;
    }
    else if ([type isEqualToString:@"Foam"]) {
        typeId = @8;
    }
    else if ([type isEqualToString:@"Livestock in stream"]) {
        typeId = @9;
    }
    else if ([type isEqualToString:@"Oil and grease"]) {
        typeId = @10;
    }
    else if ([type isEqualToString:@"Other"]) {
        typeId = @11;
    }
    else if ([type isEqualToString:@"Pipe discharge"]) {
        typeId = @12;
    }
    else if ([type isEqualToString:@"Sewer overflow"]) {
        typeId = @13;
    }
    else if ([type isEqualToString:@"Stormwater"]) {
        typeId = @14;
    }
    else if ([type isEqualToString:@"Winter manure application"]) {
        typeId = @15;
    }
    else {
        typeId = @11;
    }
    
    return [NSString stringWithFormat:@"[{\"id\":%@}]", typeId];
}

- (NSString *) findActivityType:(NSString *)type
{
    
    NSNumber *typeId;
    
    if ([type isEqualToString:@"Canoeing"]) {
        typeId = @1;
    }
    else if ([type isEqualToString:@"Diving"]) {
        typeId = @2;
    }
    else if ([type isEqualToString:@"Fishing"]) {
        typeId = @3;
    }
    else if ([type isEqualToString:@"Flatwater kayaking"]) {
        typeId = @4;
    }
    else if ([type isEqualToString:@"Hiking"]) {
        typeId = @5;
    }
    else if ([type isEqualToString:@"Living the dream"]) {
        typeId = @6;
    }
    else if ([type isEqualToString:@"Rock climbing"]) {
        typeId = @7;
    }
    else if ([type isEqualToString:@"Sailing"]) {
        typeId = @8;
    }
    else if ([type isEqualToString:@"Scouting wildlife"]) {
        typeId = @9;
    }
    else if ([type isEqualToString:@"Snorkeling"]) {
        typeId = @10;
    }
    else if ([type isEqualToString:@"Stand-up paddleboarding"]) {
        typeId = @11;
    }
    else if ([type isEqualToString:@"Stream cleanup"]) {
        typeId = @12;
    }
    else if ([type isEqualToString:@"Surfing"]) {
        typeId = @13;
    }
    else if ([type isEqualToString:@"Swimming"]) {
        typeId = @14;
    }
    else if ([type isEqualToString:@"Tubing"]) {
        typeId = @15;
    }
    else if ([type isEqualToString:@"Water skiing"]) {
        typeId = @16;
    }
    else if ([type isEqualToString:@"Whitewater kayaking"]) {
        typeId = @17;
    }
    else if ([type isEqualToString:@"Whitewater rafting"]) {
        typeId = @18;
    }
    else {
        typeId = @6;
    }
    
    return [NSString stringWithFormat:@"[{\"id\":%@}]", typeId];
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
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    singleReportTableViewController.report = report;
    
    [self.navigationController pushViewController:singleReportTableViewController animated:YES];
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
