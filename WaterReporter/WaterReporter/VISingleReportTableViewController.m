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
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.opaque = NO;
    
    self.title = self.report.report_type;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(shareReport)];

    // Title
    CGRect reportTypeFrame;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        reportTypeFrame = CGRectMake(10, 0, 400, 100);
    }else{
        reportTypeFrame = CGRectMake(10, 16, 302, 16);
    }
    
    UILabel *reportTypeLabel = [[UILabel alloc] initWithFrame:reportTypeFrame];
    reportTypeLabel.text = self.report.report_type;
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        reportTypeLabel.font = [UIFont systemFontOfSize:42.0];
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
        categoryTypeFrame = CGRectMake(10, 80, 302, 35);
    }else{
        categoryTypeFrame = CGRectMake(10, 32, 302, 20);
    }
    
    UILabel *categoryTypeLabel = [[UILabel alloc] initWithFrame:categoryTypeFrame];
    
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
        categoryTypeLabel.font = [UIFont systemFontOfSize:32.0];
    }else{
        categoryTypeLabel.font = [UIFont systemFontOfSize:12.0];
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
        submittedDateFrame = CGRectMake(10, 120, 302, 35);
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
            commentFrame = CGRectMake(10, 25, 402, 300);
        }else{
            commentFrame = CGRectMake(10, 50, 302, 60);
        }
        
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:commentFrame];
        if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad) {
            commentLabel.font = [UIFont systemFontOfSize:24.0];
        }else{
            commentLabel.font = [UIFont systemFontOfSize:12.0];
        }
        commentLabel.numberOfLines = 4;
        
        commentLabel.text = self.report.comments;
        
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
        avatarView.frame = CGRectMake(260, 17, 52, 52);
        avatarView.layer.cornerRadius = 26;
    }
    avatarView.clipsToBounds = YES;
    [self.view addSubview:avatarView];
}

- (void) shareReport
{

    NSString *reportTitle = self.report.report_type;
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
