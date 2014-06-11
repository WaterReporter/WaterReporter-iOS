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

@interface VISingleReportTableViewController ()<UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
@end

@implementation VISingleReportTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.reportID) {
        NSLog(@"WE NEED TO LOAD A REPORT >> %@", self.reportID);

        NSString *url = [NSString stringWithFormat:@"%@%@%@", @"http://api.commonscloud.org/v2/type_2c1bd72acccf416aada3a6824731acc9/", self.reportID, @".json"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
            
            NSString *attachmentURL = [NSString stringWithFormat:@"%@%@%@", @"http://api.commonscloud.org/v2/type_2c1bd72acccf416aada3a6824731acc9/", self.reportID, @"/attachment_76fc17d6574c401d9a20d18187f8083e.json"];
            [manager GET:attachmentURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
                NSLog(@"Photos? %@", responseObject[@"response"]);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                NSLog(@"Error: %@", error);
            }];

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
        [commentLabel sizeToFit];
        commentLabel.text = self.report.comments;
        
        [self.view addSubview:commentLabel];
    }
    
}

- (void) setupStaticSingleViewDetails:(NSDictionary *)report
{
    
    NSLog(@"Single Report Content: %@", report[@"response"]);
    
    self.title = @"Activity Report";

    if ([[report[@"response"] objectForKey:@"is_a_pollution_report?"] boolValue]) {
        self.title = @"Pollution Report";
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
//
//    // Activity or Pollution Type
//    CGRect categoryTypeFrame;
//    
//    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
//        categoryTypeFrame = CGRectMake(20, 60, self.view.frame.size.width-160, 40);
//    }else{
//        categoryTypeFrame = CGRectMake(10, 32, 302, 20);
//    }
//    
//    UILabel *categoryTypeLabel = [[UILabel alloc] initWithFrame:categoryTypeFrame];
//    
//    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
//        categoryTypeLabel.font = [UIFont systemFontOfSize:34.0];
//    }else{
//        categoryTypeLabel.font = [UIFont systemFontOfSize:17.0];
//    }
//    
//    if ([self.report.report_type isEqualToString:@"Activity Report"]) {
//        categoryTypeLabel.text = self.report.activity_type;
//    }
//    else if ([self.report.report_type isEqualToString:@"Pollution Report"]) {
//        categoryTypeLabel.text = self.report.pollution_type;
//    }
//    
//    [self.view addSubview:categoryTypeLabel];
//    
//    
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

//    NSData *jpgData = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:self.report.image]];
//    self.originalImage = [UIImage imageWithData:jpgData];
//    UIImage *resizedImage;
//    
//    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
//        resizedImage = [self.originalImage resizedImageByMagick:@"745x550#"];
//    }else{
//        resizedImage = [self.originalImage resizedImageByMagick:@"300x235#"];
//    }
//    
//    self.imageView = [[UIImageView alloc] initWithImage:resizedImage];
//    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
//        self.imageView.frame = CGRectMake(10, 320, resizedImage.size.width, resizedImage.size.height);
//    }else{
//        self.imageView.frame = CGRectMake(10, 120, resizedImage.size.width, resizedImage.size.height);
//    }
//    
//    [self.imageView setUserInteractionEnabled:YES];
//    
//    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage)];
//    [singleTap setNumberOfTapsRequired:1];
//    [self.imageView addGestureRecognizer:singleTap];
//    [self.view addSubview:self.imageView];
//    
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
        [commentLabel sizeToFit];
        commentLabel.text = report[@"response"][@"comments"];
        NSLog(@"comments %@", report[@"response"][@"comments"]);

        [self.view addSubview:commentLabel];
    }
    
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

    NSString *reportTitle = [NSString stringWithFormat:@"I submitted a new %@ with WaterReporter", self.report.report_type];
    NSString *reportURLString = [NSString stringWithFormat:@"http://www.waterreporter.org/reports/%@", self.report.feature_id];
    NSURL *reportURL = [NSURL URLWithString:reportURLString];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[reportTitle, reportURL] applicationActivities:nil];
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
