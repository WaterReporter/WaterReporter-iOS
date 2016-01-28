//
//  VIGroupsTableViewController.h
//  Water-Reporter
//
//  Created by Joshua Powell on 1/28/16.
//  Copyright © 2016 Viable Industries, L.L.C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "User.h"

@interface VIGroupsTableViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) NSArray *groups;
@property (strong, nonatomic) UIToolbar *toolbar;

@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) AFJSONRequestSerializer *serializer;

@property (nonatomic, strong) UISearchController *searchController;

@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;

-(void)cancelGroups;
-(void)joinSelectedGroup:(id)sender;

@end
