//
//  VIGroupsTableViewController.m
//  Water-Reporter
//
//  Created by Joshua Powell on 1/28/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "VIGroupsTableViewController.h"
#import "Lockbox.h"

#define kWaterReporterUserAccessToken @"kWaterReporterUserAccessToken"

@implementation VIGroupsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Join Groups";

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
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchBar.scopeButtonTitles = @[];
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
    
    //
    //
    //
    NSURL *baseURL = [NSURL URLWithString:@"http://stg.api.waterreporter.org/"];
    self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    self.serializer = [AFJSONRequestSerializer serializer];
    
    [self.serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    self.manager.requestSerializer = self.serializer;
    
    [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [Lockbox stringForKey:kWaterReporterUserAccessToken]] forHTTPHeaderField:@"Authorization"];
    NSLog(@"self.viewControllerActivatedFromProfilePage %hhd", self.viewControllerActivatedFromProfilePage);
    
    //
    //
    //
    if (self.viewControllerActivatedFromProfilePage == 1) {
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelGroups)];
        
        self.navigationItem.rightBarButtonItem = cancelItem;
    } else {
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelGroups)];
        
        self.navigationItem.rightBarButtonItem = cancelItem;
    }

    
    //
    // Create Navigation Toolbar
    //
    [self setupToolbar];
    
    //
    // Load the Groups list
    //
    [self loadGroups];
    [self loadUsersGroups];
}

- (void) setupToolbar
{
    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.barStyle = UIBarStyleDefault;
    self.toolbar.opaque = NO;
    self.toolbar.tintColor = nil;
    [self.toolbar sizeToFit];
}

- (void) loadGroups
{
    [self.manager GET:@"http://stg.api.waterreporter.org/v1/data/organization?results_per_page=100" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.groups = responseObject[@"features"];
        
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Could not retrieve organization");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Groups Error" message:@"Groups are temporarily unavailable" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void) loadUsersGroups
{
    User *user = [User MR_findFirst];
    
    NSString *userEndpoint = [NSString stringWithFormat:@"%@%@", @"http://stg.api.waterreporter.org/v1/data/user/", [user valueForKey:@"user_id"]];

    [self.manager GET:userEndpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"loadUsersGroups responseObject %@", responseObject);
        self.usersGroups = responseObject[@"properties"][@"groups"];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Could not retrieve organizations");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Groups Error" message:@"Groups are temporarily unavailable" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)cancelGroups
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
}

- (void)viewWillAppear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.sel
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndex:indexPath];
    
    return cell;
}

- (NSString*) dateTodayAsString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    NSDate *date = [NSDate date];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

-(void)joinSelectedGroup:(id)sender
{
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonOriginInTableView];
    
    NSLog(@"joinSelectedGroup %@", self.groups[indexPath.row][@"id"]);
    
    User *user = [User MR_findFirst];
    
    NSLog(@"user: %@", user);
    NSLog(@"email: %@", [user valueForKey:@"email"]);
    NSLog(@"user_id: %@", [user valueForKey:@"user_id"]);
    
    NSString *userEndpoint = [NSString stringWithFormat:@"%@%@", @"http://stg.api.waterreporter.org/v1/data/user/", [user valueForKey:@"user_id"]];
    
    [self.manager GET:userEndpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableDictionary *json= [[NSMutableDictionary alloc] init];
        
        //
        // Prepare Group Object and Assign to Groups
        //
        NSMutableArray *groups = [[NSMutableArray alloc] init];
        for (NSDictionary *group in responseObject[@"properties"][@"groups"]) {
            NSMutableDictionary *newGroup = [[NSMutableDictionary alloc] init];
            [newGroup setValue:group[@"id"] forKey:@"id"];
            [groups addObject:newGroup];
        }
        NSLog(@"returned groups %@", groups);
        
        NSMutableDictionary *newGroup = [[NSMutableDictionary alloc] init];
        [newGroup setValue:self.groups[indexPath.row][@"id"] forKey:@"organization_id"];
        [newGroup setValue:[user valueForKey:@"user_id"] forKey:@"user_id"];
        [newGroup setValue:[self dateTodayAsString] forKey:@"joined_on"];
        [groups addObject:newGroup];
        
        NSLog(@"modified groups %@", groups);
        
        //
        // Prepare Organization Object and Assign to Organizations
        //
        //        NSMutableArray *organization = [[NSMutableArray alloc] init];
        //        [organization addObjectsFromArray:responseObject[@"properties"][@"organization"]];
        //        NSLog(@"returned organizations %@", organization);
        //
        //        NSMutableDictionary *newOrganization = [[NSMutableDictionary alloc] init];
        //        [newOrganization setValue:self.groups[indexPath.row][@"id"] forKey:@"id"];
        //        [organization addObject:newOrganization];
        //
        //        NSLog(@"modified organization %@", organization);
        
        
        [json setValue:groups forKey:@"groups"];
        
        [self.manager PATCH:userEndpoint parameters:(NSDictionary *)json success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *message = [NSString stringWithFormat:@"You have successfully joined the %@ group", self.groups[indexPath.row][@"properties"][@"name"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:message delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];

            [self loadUsersGroups];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failure responseObject %@", error);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure responseObject %@", error);
    }];
    
}

-(void)leaveSelectedGroup:(id)sender
{
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonOriginInTableView];
    
    NSLog(@"leaveSelectedGroup %@", self.groups[indexPath.row][@"id"]);
    
    User *user = [User MR_findFirst];
    
    NSString *userEndpoint = [NSString stringWithFormat:@"%@%@", @"http://stg.api.waterreporter.org/v1/data/user/", [user valueForKey:@"user_id"]];
    
    [self.manager GET:userEndpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableDictionary *json= [[NSMutableDictionary alloc] init];
        
        //
        // Prepare Group Object and Assign to Groups
        //
        NSMutableArray *groups = [[NSMutableArray alloc] init];
        NSLog(@"returned groups %@", groups);

        for (NSDictionary *group in responseObject[@"properties"][@"groups"]) {
            if (group[@"properties"][@"organization_id"] != self.groups[indexPath.row][@"id"]) {
                NSMutableDictionary *newGroup = [[NSMutableDictionary alloc] init];
                [newGroup setValue:group[@"id"] forKey:@"id"];
                [groups addObject:newGroup];
            }
        }
        NSLog(@"modified groups %@", groups);
        
        //
        // Prepare Organization Object and Assign to Organizations
        //
        //        NSMutableArray *organization = [[NSMutableArray alloc] init];
        //        [organization addObjectsFromArray:responseObject[@"properties"][@"organization"]];
        //        NSLog(@"returned organizations %@", organization);
        //
        //        NSMutableDictionary *newOrganization = [[NSMutableDictionary alloc] init];
        //        [newOrganization setValue:self.groups[indexPath.row][@"id"] forKey:@"id"];
        //        [organization addObject:newOrganization];
        //
        //        NSLog(@"modified organization %@", organization);
        
        
        [json setValue:groups forKey:@"groups"];
        
        [self.manager PATCH:userEndpoint parameters:(NSDictionary *)json success:^(AFHTTPRequestOperation *operation, id responseObject) {

            NSString *message = [NSString stringWithFormat:@"You have successfully left the %@ group", self.groups[indexPath.row][@"properties"][@"name"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:message delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];

            [self loadUsersGroups];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failure responseObject %@", error);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure responseObject %@", error);
    }];
    
}

- (void)configureCell:(UITableViewCell*)cell atIndex:(NSIndexPath*)indexPath
{
    
    NSString *group = self.groups[indexPath.row][@"properties"][@"name"];
    NSLog(@"configureCell %@", group);
    
    cell.textLabel.font = [UIFont systemFontOfSize:13.0];
    cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:group attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:128.0/255.0 alpha:1.0]}];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([self userIsMemberOfGroup:(int)self.groups[indexPath.row][@"id"]]) {
        NSLog(@"User is a member of group %@ already, show the leave button", self.groups[indexPath.row][@"id"]);
        UIButton *leaveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [leaveButton addTarget:self action:@selector(leaveSelectedGroup:) forControlEvents:UIControlEventTouchUpInside];
        
        [leaveButton setTitle:@"LEAVE" forState:UIControlStateNormal];
        [leaveButton setFrame:CGRectMake(0, 0, 48, 24)];
        leaveButton.backgroundColor = [UIColor colorWithRed:212.0f/255.0f green:212.0f/255.0f blue:212.0f/255.0f alpha:1.0];
        leaveButton.tintColor = [UIColor colorWithRed:22.0f/255.0f green:22.0f/255.0f blue:22.0f/255.0f alpha:1.0];
        
        [leaveButton setTitleColor:[UIColor colorWithRed:22.0f/255.0f green:22.0f/255.0f blue:22.0f/255.0f alpha:1.0] forState:UIControlStateSelected];
        
        [leaveButton.titleLabel setFont:[UIFont boldSystemFontOfSize:11.0f]];
        
        cell.accessoryView = leaveButton;
    }
    else {
        NSLog(@"User is not a member of group %@, show the join button", self.groups[indexPath.row][@"id"]);
        UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [joinButton addTarget:self action:@selector(joinSelectedGroup:) forControlEvents:UIControlEventTouchUpInside];
        
        [joinButton setTitle:@"JOIN" forState:UIControlStateNormal];
        [joinButton setFrame:CGRectMake(0, 0, 48, 24)];
        joinButton.backgroundColor = [UIColor colorWithRed:0.4 green:0.74 blue:0.17 alpha:1];
        joinButton.tintColor = [UIColor colorWithRed:252.0f/255.0f green:252.0f/255.0f blue:252.0f/255.0f alpha:1.0];
        
        [joinButton setTitleColor:[UIColor colorWithRed:252.0f/255.0f green:252.0f/255.0f blue:252.0f/255.0f alpha:1.0] forState:UIControlStateSelected];
        
        [joinButton.titleLabel setFont:[UIFont boldSystemFontOfSize:11.0f]];
        
        cell.accessoryView = joinButton;
    }
    
}

- (BOOL)userIsMemberOfGroup:(NSInteger)groupId {
    
    NSLog(@"userIsMemberOfGroup %@", self.usersGroups);
    
    for (NSDictionary *group in self.usersGroups) {
        NSLog(@"groupId %ld is equal to group[properties][organization_id] %@??", (long)groupId, group[@"properties"][@"organization_id"]);
        
        if (groupId == (int)group[@"properties"][@"organization_id"]) {
            return true;
        }
    }
    
    return false;
}


@end