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

-(void)joinSelectedGroup:(id)sender
{
    CGPoint buttonOriginInTableView = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonOriginInTableView];
    
    NSLog(@"joinSelectedGroup %@", self.groups[indexPath.row][@"id"]);
    
    User *user = [User MR_findFirst];
    
    NSString *userEndpoint = [NSString stringWithFormat:@"%@%@", @"http://stg.api.waterreporter.org/v1/data/user/", [user valueForKey:@"user_id"]];
    
    [self.manager GET:userEndpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *userGroups = [NSArray arrayWithArray:responseObject[@"properties"][@"groups"]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"verifyUserGroups::error: %@", error);
    }];
}

- (void)configureCell:(UITableViewCell*)cell atIndex:(NSIndexPath*)indexPath
{
    
    NSString *group = self.groups[indexPath.row][@"properties"][@"name"];
    
    cell.textLabel.font = [UIFont systemFontOfSize:13.0];
    cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:group attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:128.0/255.0 alpha:1.0]}];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //
    //
    //
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


@end