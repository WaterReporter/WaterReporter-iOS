//
//  VIReportsTableViewController.h
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/15/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "Report.h"
#import "VISingleReportTableViewController.h"
#import "VILoginTableViewController.h"
#import "VIGroupsTableViewController.h"
#import "User.h"

@interface VIReportsTableViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) BOOL isRefreshing;
@property (strong, nonatomic) NSMutableArray *reports;
@property (retain, nonatomic) NSString *networkStatus;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) AFJSONRequestSerializer *serializer;

@property (strong, nonatomic) VIGroupsTableViewController *groupView;
@property (strong, nonatomic) UINavigationController *groupNavigationController;

-(void) updateReportFeatureID:(Report *)report response_id:(NSNumber *)feature_id;

@end
