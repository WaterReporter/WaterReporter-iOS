//
//  VIGroupsTableViewController.h
//  Water-Reporter
//
//  Created by Joshua Powell on 1/28/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "VITutorialViewController.h"
#import "User.h"

@class VITutorialViewController;

@interface VIGroupsTableViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) VITutorialViewController *tutorialView;

@property (strong, nonatomic) NSArray *groups;
@property (strong, nonatomic) NSMutableArray *groupsFiltered;
@property (strong, nonatomic) NSArray *usersGroups;
@property (strong, nonatomic) UIToolbar *toolbar;

@property (nonatomic, strong) UILabel *loadingLabel;
@property (nonatomic, strong) MBProgressHUD *hud;

@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) AFJSONRequestSerializer *serializer;

@property (nonatomic, strong) UISearchController *searchController;

@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@property BOOL viewControllerActivatedFromProfilePage;

- (BOOL)userIsMemberOfGroup:(id)groupId;
-(void)joinSelectedGroup:(NSDictionary *)group;
-(void)leaveSelectedGroup:(NSDictionary *)group;

@end
