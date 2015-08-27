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

@interface VIReportsTableViewController : UITableViewController

@property (nonatomic) BOOL isRefreshing;
@property (strong, nonatomic) NSMutableArray *reports;
@property (retain, nonatomic) NSString *networkStatus;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) AFJSONRequestSerializer *serializer;

-(void) updateReportFeatureID:(Report *)report response_id:(NSNumber *)feature_id;

@end
