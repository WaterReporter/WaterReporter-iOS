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
    NSLog(@"self.viewControllerActivatedFromProfilePage? %hhd", self.viewControllerActivatedFromProfilePage);
    if (self.viewControllerActivatedFromProfilePage) {
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(doneGroups)];
        
        self.navigationItem.rightBarButtonItem = cancelItem;
    } else {
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Skip" style:UIBarButtonItemStyleBordered target:self action:@selector(skipGroups)];
        
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

        [self loadUsersGroups];

        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loadGroups: Could not retrieve organization");
    }];
}

- (void) loadUsersGroups
{
    User *user = [User MR_findFirstInContext:[NSManagedObjectContext MR_defaultContext]];
    
    NSString *userEndpoint = [NSString stringWithFormat:@"%@%@", @"https://api.waterreporter.org/v2/data/user/", [user valueForKey:@"user_id"]];
    
    NSLog(@"loadUsersGroups userEndpoint %@", userEndpoint);

    [self.manager GET:userEndpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"loadUsersGroups responseObject %@", responseObject);
        self.usersGroups = responseObject[@"properties"][@"groups"];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"loadUsersGroups: Could not retrieve organizations");
    }];
}

- (void)doneGroups
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)skipGroups
{
    self.tutorialView = [[VITutorialViewController alloc] init];
    self.tutorialView.viewControllerActivatedFromLoginPage = NO;
    [self presentViewController:self.tutorialView animated:YES completion:nil];
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
        [leaveButton addTarget:self action:@selector(leaveSelectedGroupAction:) forControlEvents:UIControlEventTouchUpInside];
        
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
        [joinButton addTarget:self action:@selector(joinSelectedGroupAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [joinButton setTitle:@"JOIN" forState:UIControlStateNormal];
        [joinButton setFrame:CGRectMake(0, 0, 48, 24)];
        joinButton.backgroundColor = [UIColor colorWithRed:0.4 green:0.74 blue:0.17 alpha:1];
        joinButton.tintColor = [UIColor colorWithRed:252.0f/255.0f green:252.0f/255.0f blue:252.0f/255.0f alpha:1.0];
        
        [joinButton setTitleColor:[UIColor colorWithRed:252.0f/255.0f green:252.0f/255.0f blue:252.0f/255.0f alpha:1.0] forState:UIControlStateSelected];
        
        [joinButton.titleLabel setFont:[UIFont boldSystemFontOfSize:11.0f]];
        
        cell.accessoryView = joinButton;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath::Group %@", self.groups[indexPath.row][@"properties"][@"name"]);
    
    NSDictionary *group = self.groups[indexPath.row];
    
    if ([self userIsMemberOfGroup:(int)group[@"id"]]) {
        [self leaveSelectedGroup:group];
    } else {
        [self joinSelectedGroup:group];
    }
}

//
//
//
//
// GROUP FUNCTIONALITY
//
//
//
//
-(void)temporaryLoadingAccessoryView:(id)sender {
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonOriginInTableView];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner setFrame:CGRectMake(0, 0, 10, 10)];
    [spinner startAnimating];
    cell.accessoryView = spinner;
}

-(void)joinSelectedGroupAction:(id)sender {
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonOriginInTableView];
    
    [self temporaryLoadingAccessoryView:sender];
    [self joinSelectedGroup:self.groups[indexPath.row]];
}

-(void)joinSelectedGroup:(NSDictionary *)group
{
    NSLog(@"joinSelectedGroup %@", group[@"id"]);
    
    User *user = [User MR_findFirst];
    
    NSString *userEndpoint = [NSString stringWithFormat:@"%@%@", @"https://api.waterreporter.org/v2/data/user/", [user valueForKey:@"user_id"]];
    
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
        [newGroup setValue:group[@"id"] forKey:@"organization_id"];
        [newGroup setValue:[user valueForKey:@"user_id"] forKey:@"user_id"];
        [newGroup setValue:[self dateTodayAsString] forKey:@"joined_on"];
        [groups addObject:newGroup];
        
        NSLog(@"modified groups %@", groups);
        
        [json setValue:groups forKey:@"groups"];
        
        [self.manager PATCH:userEndpoint parameters:(NSDictionary *)json success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *message = [NSString stringWithFormat:@"You have successfully joined the %@ group", group[@"properties"][@"name"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:message delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
            
            [self loadUsersGroups];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasUpdatedUserGroups"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failure responseObject %@", error);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure responseObject %@", error);
    }];
    
}

-(void)leaveSelectedGroupAction:(id)sender {
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonOriginInTableView];
    
    [self temporaryLoadingAccessoryView:sender];
    [self leaveSelectedGroup:self.groups[indexPath.row]];
}

-(void)leaveSelectedGroup:(NSDictionary *)group
{
    NSLog(@"leaveSelectedGroup %@", group[@"id"]);
    
    User *user = [User MR_findFirst];
    
    NSString *userEndpoint = [NSString stringWithFormat:@"%@%@", @"https://api.waterreporter.org/v2/data/user/", [user valueForKey:@"user_id"]];
    
    [self.manager GET:userEndpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableDictionary *json= [[NSMutableDictionary alloc] init];
        
        //
        // Prepare Group Object and Assign to Groups
        //
        NSMutableArray *groups = [[NSMutableArray alloc] init];
        NSLog(@"returned groups %@", groups);
        
        for (NSDictionary *thisGroup in responseObject[@"properties"][@"groups"]) {
            if (thisGroup[@"properties"][@"organization_id"] != group[@"id"]) {
                NSMutableDictionary *newGroup = [[NSMutableDictionary alloc] init];
                [newGroup setValue:thisGroup[@"id"] forKey:@"id"];
                [groups addObject:newGroup];
            }
        }
        NSLog(@"modified groups %@", groups);
        
        [json setValue:groups forKey:@"groups"];
        
        [self.manager PATCH:userEndpoint parameters:(NSDictionary *)json success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *message = [NSString stringWithFormat:@"You have successfully left the %@ group", group[@"properties"][@"name"]];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" message:message delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
            
            [self loadUsersGroups];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasUpdatedUserGroups"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failure responseObject %@", error);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure responseObject %@", error);
    }];
    
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