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
#import "MBProgressHUD.h"

@interface VISingleReportTableViewController ()<UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
@end

@implementation VISingleReportTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.reportID) {
        NSString *url = [NSString stringWithFormat:@"%@%@%@", @"http://api.commonscloud.org/v2/type_2c1bd72acccf416aada3a6824731acc9/", self.reportID, @".json"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            [self setupStaticSingleViewDetails:responseObject];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error){
            NSLog(@"Error: %@", error);
        }];
    } else {
        [self setupSingleViewDetails];
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.opaque = NO;
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(shareReport)];
}

- (void) setupSingleViewDetails
{
    self.title = self.report.report_type;
    self.reportID = [self.report.feature_id stringValue];
    
    // Title
    CGRect reportTypeFrame;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        reportTypeFrame = CGRectMake(20, 28, 400, 32);
    }else{
        reportTypeFrame = CGRectMake(10, 14, 302, 16);
    }
    
    UILabel *reportTypeLabel = [[UILabel alloc] initWithFrame:reportTypeFrame];
    reportTypeLabel.text = self.report.report_type;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        reportTypeLabel.font = [UIFont systemFontOfSize:24.0];
    }else{
        reportTypeLabel.font = [UIFont systemFontOfSize:12.0];
    }
    
    reportTypeLabel.textColor = [UIColor lightGrayColor];
    
    [self.view addSubview:reportTypeLabel];
    
    //Gravatar
    if(!self.userEmail){
        self.gravatar = [[Gravatar alloc] init];
    }
    else{
        self.gravatar = [[Gravatar alloc] initWithEmail:self.userEmail];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadGravatar) name:@"initWithJSONFinishedLoading" object:nil];
    
    // Activity or Pollution Type
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
    
    if ([self.report.report_type isEqualToString:@"Activity Report"]) {
        categoryTypeLabel.text = self.report.activity_type;
    }
    else if ([self.report.report_type isEqualToString:@"Pollution Report"]) {
        categoryTypeLabel.text = self.report.pollution_type;
    }
    
    [self.view addSubview:categoryTypeLabel];
    
    
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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:self.report.date];
    
    submittedDateLabel.text = [NSString stringWithFormat:@"Submitted on %@", dateString];
    
    [self.view addSubview:submittedDateLabel];
    
    NSData *jpgData = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:self.report.image]];
    self.originalImage = [UIImage imageWithData:jpgData];
    UIImage *resizedImage;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        resizedImage = [self.originalImage resizedImageByMagick:@"745x550#"];
    }else{
        resizedImage = [self.originalImage resizedImageByMagick:@"300x235#"];
    }
    
    self.imageView = [[UIImageView alloc] initWithImage:resizedImage];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        self.imageView.frame = CGRectMake(10, 320, resizedImage.size.width, resizedImage.size.height);
    }else{
        self.imageView.frame = CGRectMake(10, 120, resizedImage.size.width, resizedImage.size.height);
    }
    
    [self.imageView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage)];
    [singleTap setNumberOfTapsRequired:1];
    [self.imageView addGestureRecognizer:singleTap];
    [self.view addSubview:self.imageView];
    
    // Comment
    if (self.report.comments) {
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
        commentLabel.text = self.report.comments;
        [commentLabel sizeToFit];
        
        [self.view addSubview:commentLabel];
    }
    
}

- (void) setupStaticSingleViewDetails:(NSDictionary *)report
{
    
    NSLog(@"Single Report Content: %@", report[@"response"]);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;

    CGRect loadingFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:loadingFrame];
    loadingLabel.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:loadingLabel];
    
    self.title = @"Activity Report";
    
    if (report[@"response"][@"is_a_pollution_report?"] && report[@"response"][@"is_a_pollution_report?"] != [NSNull null]){
        if ([report[@"response"][@"is_a_pollution_report?"] integerValue] == 1) {
            self.title = @"Pollution Report";
        }
    }

    // Title
    CGRect reportTypeFrame;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        reportTypeFrame = CGRectMake(20, 28, 400, 32);
    }else{
        reportTypeFrame = CGRectMake(10, 14, 302, 16);
    }
    
    UILabel *reportTypeLabel = [[UILabel alloc] initWithFrame:reportTypeFrame];
    reportTypeLabel.text = self.title;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        reportTypeLabel.font = [UIFont systemFontOfSize:24.0];
    }else{
        reportTypeLabel.font = [UIFont systemFontOfSize:12.0];
    }
    
    reportTypeLabel.textColor = [UIColor lightGrayColor];
    
    [self.view addSubview:reportTypeLabel];
    
    //Gravatar
    if(report[@"response"][@"useremail_address"] == [NSNull null]){
        self.gravatar = [[Gravatar alloc] initWithEmail:@"error@waterreporter.org"];
    }
    else {
        self.gravatar = [[Gravatar alloc] initWithEmail:report[@"response"][@"useremail_address"]];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadGravatar) name:@"initWithJSONFinishedLoading" object:nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    NSString *reportTypeURL = [NSString stringWithFormat:@"%@%@%@", @"http://api.commonscloud.org/v2/type_2c1bd72acccf416aada3a6824731acc9/", self.reportID, @"/type_0e9423a9a393481f82c4f22ff5954567.json"];
    
    NSLog(@"is_a_pollution_report? %@", report[@"response"][@"is_a_pollution_report?"]);
    if (report[@"response"][@"is_a_pollution_report?"] && report[@"response"][@"is_a_pollution_report?"] != [NSNull null]){
        if ([report[@"response"][@"is_a_pollution_report?"] integerValue] == 1) {
            reportTypeURL = [NSString stringWithFormat:@"%@%@%@", @"http://api.commonscloud.org/v2/type_2c1bd72acccf416aada3a6824731acc9/", self.reportID, @"/type_05a300e835024771a51a6d3114e82abc.json"];
        }
    }
    
    NSLog(@"reportTypeURL %@", reportTypeURL);
    
    [manager GET:reportTypeURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        if ([responseObject[@"response"][@"features"] count] != 0) {
            NSString *category = responseObject[@"response"][@"features"][0][@"name"];
            
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
            
            NSLog(@"Category %@", category);
            categoryTypeLabel.text = category;
            
            [self.view addSubview:categoryTypeLabel];
            [self.view sendSubviewToBack:categoryTypeLabel];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
    }];
    
    
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

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:report[@"response"][@"date"]];

    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    submittedDateLabel.text = [NSString stringWithFormat:@"Submitted on %@", dateString];
    
    [self.view addSubview:submittedDateLabel];

    // Activity or Pollution Type
    NSString *attachmentURL = [NSString stringWithFormat:@"%@%@%@", @"http://api.commonscloud.org/v2/type_2c1bd72acccf416aada3a6824731acc9/", self.reportID, @"/attachment_76fc17d6574c401d9a20d18187f8083e.json"];
    [manager GET:attachmentURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"%lu", (unsigned long)[responseObject[@"response"][@"features"] count]);
        if ([responseObject[@"response"][@"features"] count] != 0) {
            NSURL *photos = [NSURL URLWithString:responseObject[@"response"][@"features"][0][@"filepath"]];
            if (![responseObject[@"response"][@"features"][0][@"filepath"] hasPrefix:@"http://"]) {
                photos = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://", responseObject[@"response"][@"features"][0][@"filepath"]]];
            }
            
            NSLog(@"%@", photos);
            
            NSData *jpgData = [NSData dataWithContentsOfURL:photos];
            self.originalImage = [UIImage imageWithData:jpgData];
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

        [loadingLabel removeFromSuperview];
        [hud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
    }];
    
    // Comment
    if (report[@"response"][@"comments"]) {
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
        commentLabel.text = report[@"response"][@"comments"];
        [commentLabel sizeToFit];

        [self.view addSubview:commentLabel];
    }
    
    [self.view bringSubviewToFront:loadingLabel];
    [self.view bringSubviewToFront:hud];
    
}

- (void) showImage
{
    PhotoViewController *photoVC = [[PhotoViewController alloc] init];
    photoVC.image = self.originalImage;
    [self.navigationController pushViewController:photoVC animated:YES];
}

- (void) loadGravatar
{
    UIImage *avatar = self.gravatar.avatar;
    UIImageView *avatarView = [[UIImageView alloc] initWithImage:avatar];
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        avatarView.frame = CGRectMake(630, 30, 120, 120);
        avatarView.layer.cornerRadius = 60;
    }else{
        avatarView.frame = CGRectMake(260, 14, 52, 52);
        avatarView.layer.cornerRadius = 26;
    }
    avatarView.clipsToBounds = YES;
    [self.view addSubview:avatarView];
}

- (void) shareReport
{
    
    NSString *reportTitle = [NSString stringWithFormat:@"I submitted a new %@ with WaterReporter", self.title];
    NSString *reportURLString = [NSString stringWithFormat:@"http://www.waterreporter.org/reports/%@", self.reportID];
    NSURL *reportURL = [NSURL URLWithString:reportURLString];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[reportTitle, reportURL] applicationActivities:nil];

    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
