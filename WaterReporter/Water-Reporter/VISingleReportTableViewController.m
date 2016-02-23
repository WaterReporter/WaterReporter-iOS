//
//  VISingleReportTableViewController.m
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/16/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import "VISingleReportTableViewController.h"
#import "PhotoViewController.h"
#import "ImageSaver.h"
#import "Report.h"
#import "User.h"

#define COLOR_BRAND_BLUE_BASE [UIColor colorWithRed:20.0/255.0 green:165.0/255.0 blue:241.0/255.0 alpha:1.0]
#define COLOR_BRAND_WHITE_BASE [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]

#define kWaterReporterUserAccessToken @"kWaterReporterUserAccessToken"

@interface VISingleReportTableViewController ()<UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
@end

@implementation VISingleReportTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    // Setup up the loading indicator
    //
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    
    CGRect loadingFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.loadingLabel = [[UILabel alloc] initWithFrame:loadingFrame];
    self.loadingLabel.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.loadingLabel];
    
    [self.view bringSubviewToFront:self.loadingLabel];
    [self.view bringSubviewToFront:self.hud];

    if (self.reportID) {
        NSString *url = [NSString stringWithFormat:@"%@%@", @"http://stg.api.waterreporter.org/v1/data/report/", self.reportID];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            [self setupStaticSingleViewDetails:responseObject];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error){
            NSLog(@"Error: %@", error);
        }];
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.opaque = NO;
    
    NSURL *baseURL = [NSURL URLWithString:@"http://stg.api.waterreporter.org/"];
    self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    self.serializer = [AFJSONRequestSerializer serializer];
    
    [self.serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    self.manager.requestSerializer = self.serializer;
    
    [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [Lockbox stringForKey:kWaterReporterUserAccessToken]] forHTTPHeaderField:@"Authorization"];
    
    [self loadUsersGroups];
    [self loadGroups];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(shareReport)];
}

- (void) setupStaticSingleViewDetails:(NSDictionary *)report
{
    
    //
    // Setup Title
    //
    NSString *reportType = @"Unknown";

    if (report[@"properties"][@"territory"] != [NSNull null]) {
        if (report[@"properties"][@"territory"][@"properties"][@"huc_6_name"] != [NSNull null]) {
            reportType = report[@"properties"][@"territory"][@"properties"][@"huc_6_name"];
        }
    }
    
    self.title = [NSString stringWithFormat:@"%@ Watershed", reportType];
    
    //
    // Draw Title
    //
    CGRect reportTypeFrame;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        reportTypeFrame = CGRectMake(20, 28, 400, 32);
    }else{
        reportTypeFrame = CGRectMake(10, 14, 302, 16);
    }
    
    UILabel *reportTypeLabel = [[UILabel alloc] initWithFrame:reportTypeFrame];
    reportTypeLabel.text = @"Report submitted in the";
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        reportTypeLabel.font = [UIFont systemFontOfSize:24.0];
    }else{
        reportTypeLabel.font = [UIFont systemFontOfSize:12.0];
    }
    
    reportTypeLabel.textColor = [UIColor lightGrayColor];
    
    [self.view addSubview:reportTypeLabel];
    
    //
    // Prepare and Load Avatar Into View
    //
    NSString *avatar = @"https://www.waterreporter.org/images/badget--MissingUser.png";
    
    if(report[@"properties"][@"owner"] != [NSNull null] && report[@"properties"][@"owner"][@"properties"][@"picture"] != [NSNull null]){
        avatar = report[@"properties"][@"owner"][@"properties"][@"picture"];
    }
    
    [self loadAvatar:avatar];
    

    //
    // Actual Report title now
    //
    if (self.title) {
        NSString *category = self.title;
        
        CGRect categoryTypeFrame;
        
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
            categoryTypeFrame = CGRectMake(20, 60, self.view.frame.size.width-160, 40);
        }else{
            categoryTypeFrame = CGRectMake(10, 32, 302, 20);
        }
        
        UILabel *categoryTypeLabel = [[UILabel alloc] initWithFrame:categoryTypeFrame];
        
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
            categoryTypeLabel.font = [UIFont systemFontOfSize:34.0];
        }else{
            categoryTypeLabel.font = [UIFont systemFontOfSize:17.0];
        }
        
        categoryTypeLabel.text = category;
        
        [self.view addSubview:categoryTypeLabel];
        [self.view sendSubviewToBack:categoryTypeLabel];
    }
    
    
    // Date
    CGRect submittedDateFrame;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        submittedDateFrame = CGRectMake(20, 100, 302, 30);
    }else{
        submittedDateFrame = CGRectMake(10, 54, 302, 15);
    }
    
    UILabel *submittedDateLabel = [[UILabel alloc] initWithFrame:submittedDateFrame];
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        submittedDateLabel.font = [UIFont systemFontOfSize:24.0];
    }else{
        submittedDateLabel.font = [UIFont systemFontOfSize:12.0];
    }
    
    submittedDateLabel.textColor = [UIColor lightGrayColor];

    NSString *dateString = report[@"properties"][@"report_date"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:posix];
    
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    [dateFormatter setDateFormat:@"LLLL d, yyyy"];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    submittedDateLabel.text = [NSString stringWithFormat:@"on %@", formattedDateString];
    
    [self.view addSubview:submittedDateLabel];

    //
    // Comment
    //
    if (report[@"properties"][@"report_description"]) {
        CGRect commentFrame;
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
            commentFrame = CGRectMake(20, 160, self.view.frame.size.width-40, 60);
        }else{
            commentFrame = CGRectMake(10, 72, 302, 60);
        }
        
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:commentFrame];
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
            commentLabel.font = [UIFont systemFontOfSize:24.0];
            commentLabel.numberOfLines = 2;
        }else{
            commentLabel.font = [UIFont systemFontOfSize:12.0];
            commentLabel.numberOfLines = 4;
        }
        commentLabel.text = report[@"properties"][@"report_description"];
        [commentLabel sizeToFit];
        
        [self.view addSubview:commentLabel];
    }
    
    //
    // Image
    //
    NSArray *images = report[@"properties"][@"images"];
    
    if (images && images.count) {
        
        NSURL *photo;
        
        if (report[@"properties"][@"images"][0][@"properties"][@"square"] != [NSNull null] && [report[@"properties"][@"images"][0][@"properties"][@"square"] length] != 0) {
            photo = [NSURL URLWithString:report[@"properties"][@"images"][0][@"properties"][@"square"]];
        } else {
            photo = [NSURL URLWithString:report[@"properties"][@"images"][0][@"properties"][@"original"]];
        }
    
        NSData * imageData = [[NSData alloc] initWithContentsOfURL:photo];
        UIImage *image = [UIImage imageWithData:imageData scale:1.0];
        self.originalImage = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation: UIImageOrientationUp];
        
        UIImage *resizedImage;
    
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
            resizedImage = [self.originalImage resizedImageByMagick:@"745x550#"];
        }else{
            resizedImage = [self.originalImage resizedImageByMagick:@"300x235#"];
        }
    
        self.imageView = [[UIImageView alloc] initWithImage:resizedImage];
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
            self.imageView.frame = CGRectMake(10, 220, resizedImage.size.width, resizedImage.size.height);
        }else{
            self.imageView.frame = CGRectMake(10, 142, resizedImage.size.width, resizedImage.size.height);
        }
    
        [self.imageView setUserInteractionEnabled:YES];
    
        UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage)];
        [singleTap setNumberOfTapsRequired:1];
        [self.imageView addGestureRecognizer:singleTap];
        [self.view addSubview:self.imageView];
    }
    
    //
    // Comment
    //
    if (report[@"properties"][@"groups"]) {
        
        float yPosition = self.imageView.frame.size.height+152;
        float rowHeight = 40;
        
        for (NSDictionary *group in report[@"properties"][@"groups"]) {
            CGRect groupsFrame;
            groupsFrame = CGRectMake(10, yPosition, 302, rowHeight);

            UILabel *groupLabel = [[UILabel alloc] initWithFrame:groupsFrame];
            groupLabel.font = [UIFont systemFontOfSize:12.0];
            groupLabel.text = group[@"properties"][@"name"];
            groupLabel.numberOfLines = 1;
            
            yPosition = yPosition+rowHeight;

            if ([self userIsMemberOfGroup:(int)group[@"id"]]) {
                NSLog(@"User is a member of group %@ already, show the leave button", group[@"id"]);
                UIButton *leaveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [leaveButton addTarget:self action:@selector(leaveSelectedGroup:) forControlEvents:UIControlEventTouchUpInside];
                
                [leaveButton setTitle:@"LEAVE" forState:UIControlStateNormal];
                [leaveButton setFrame:CGRectMake(242, 4, 48, 24)];
                leaveButton.backgroundColor = [UIColor colorWithRed:212.0f/255.0f green:212.0f/255.0f blue:212.0f/255.0f alpha:1.0];
                leaveButton.tintColor = [UIColor colorWithRed:22.0f/255.0f green:22.0f/255.0f blue:22.0f/255.0f alpha:1.0];
                
                [leaveButton setTitleColor:[UIColor colorWithRed:22.0f/255.0f green:22.0f/255.0f blue:22.0f/255.0f alpha:1.0] forState:UIControlStateSelected];
                
                [leaveButton.titleLabel setFont:[UIFont boldSystemFontOfSize:11.0f]];
                
                [groupLabel addSubview:leaveButton];
                [groupLabel bringSubviewToFront:leaveButton];
            }
            else {
                NSLog(@"User is not a member of group %@, show the join button", group[@"id"]);
                UIButton *joinButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [joinButton addTarget:self action:@selector(joinSelectedGroup:) forControlEvents:UIControlEventTouchUpInside];
                
                [joinButton setTitle:@"JOIN" forState:UIControlStateNormal];
                [joinButton setFrame:CGRectMake(242, 4, 48, 24)];
                joinButton.backgroundColor = [UIColor colorWithRed:0.4 green:0.74 blue:0.17 alpha:1];
                joinButton.tintColor = [UIColor colorWithRed:252.0f/255.0f green:252.0f/255.0f blue:252.0f/255.0f alpha:1.0];
                
                [joinButton setTitleColor:[UIColor colorWithRed:252.0f/255.0f green:252.0f/255.0f blue:252.0f/255.0f alpha:1.0] forState:UIControlStateSelected];
                
                [joinButton.titleLabel setFont:[UIFont boldSystemFontOfSize:11.0f]];
                
                [groupLabel addSubview:joinButton];
                [groupLabel bringSubviewToFront:joinButton];
            }
            
            [self.view addSubview:groupLabel];
        }

    }
    
    [self.loadingLabel removeFromSuperview];
    [self.hud hide:YES];
}

- (void) showImage
{
    PhotoViewController *photoVC = [[PhotoViewController alloc] init];
    
    photoVC.image = self.originalImage;
    
    [self.navigationController pushViewController:photoVC animated:YES];
}

- (void) loadAvatar:(NSString *)imageUrl
{
    NSURL *imageURL = [NSURL URLWithString:imageUrl];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];

    UIImageView *avatarView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData]];
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        avatarView.frame = CGRectMake(630, 30, 120, 120);
        avatarView.layer.cornerRadius = 60;
    }else{
        avatarView.frame = CGRectMake(260, 14, 52, 52);
        avatarView.layer.cornerRadius = 26;
    }
    
    avatarView.clipsToBounds = YES;
    
    [self.view addSubview:avatarView];
    [self.view sendSubviewToBack:avatarView];
}

- (void) shareReport
{
    
    NSString *reportTitle = [NSString stringWithFormat:@"I submitted a new %@ with WaterReporter", self.title];
    NSString *reportURLString = [NSString stringWithFormat:@"https://www.waterreporter.org/reports/%@", self.reportID];
    NSURL *reportURL = [NSURL URLWithString:reportURLString];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[reportTitle, reportURL] applicationActivities:nil];
    
    [activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        // back to normal color
    	[[UINavigationBar appearance] setBarTintColor:COLOR_BRAND_BLUE_BASE];
        [[UINavigationBar appearance] setTintColor:COLOR_BRAND_WHITE_BASE];
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : COLOR_BRAND_WHITE_BASE}];
    }];
    [self presentViewController:activityViewController animated:YES completion:^{
        // change color temporary
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            [self loadGroups];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failure responseObject %@", error);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failure responseObject %@", error);
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
            [self loadGroups];
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
