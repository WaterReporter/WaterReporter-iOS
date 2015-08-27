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
        NSString *url = [NSString stringWithFormat:@"%@%@", @"http://api.waterreporter.org/v1/data/report/", self.reportID];
        
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
    NSString *avatar = @"http://dev.waterreporter.org/images/badget--MissingUser.png";
    
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
    // Image
    //
    NSArray *images = report[@"properties"][@"images"];
    
    if (images && images.count) {
        
        NSURL *photo;
        
        if (report[@"properties"][@"images"][0][@"properties"][@"square"]) {
            photo = [NSURL URLWithString:report[@"properties"][@"images"][0][@"properties"][@"square"]];
        } else {
            photo = [NSURL URLWithString:report[@"properties"][@"images"][0][@"properties"][@"original"]];
        }
    
        NSData * imageData = [[NSData alloc] initWithContentsOfURL:photo];
        UIImage *image = [UIImage imageWithData:imageData scale:1.0];
        self.originalImage = [UIImage imageWithCGImage:[image CGImage]
                                                 scale:1.0
                                           orientation: UIImageOrientationUp];
        
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
    
    
    // Comment
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
    NSString *reportURLString = [NSString stringWithFormat:@"http://www.waterreporter.org/reports/%@", self.reportID];
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

@end
