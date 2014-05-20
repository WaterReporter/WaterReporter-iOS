//
//  VIChildViewController.m
//  WaterReporter
//
//  Created by Ryan Hamley on 5/20/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import "VIChildViewController.h"

@interface VIChildViewController ()

@end

@implementation VIChildViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSArray *slides = @[[UIImage imageNamed:@"Slide1"], [UIImage imageNamed:@"Slide2"], [UIImage imageNamed:@"Slide3"], [UIImage imageNamed:@"Slide4"]];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIImage *background = slides[self.index];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: background];
    //    imageView.userInteractionEnabled = YES;
    //
    //    UIButton *endTutorialButton = [[UIButton alloc] initWithFrame:CGRectMake(115, 510, 100, 20)];
    //    [endTutorialButton setTitle:@"Get Started" forState:UIControlStateNormal];
    //    [endTutorialButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    //    endTutorialButton.backgroundColor = [UIColor clearColor];
    //    [endTutorialButton addTarget:self action:@selector(loadLogin) forControlEvents:UIControlEventTouchUpInside];
    //
    //    [imageView addSubview:endTutorialButton];
    [self.view addSubview: imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadLogin
{
    NSLog(@"Load Login");
    VILoginTableViewController *modal = [[VILoginTableViewController alloc] init];
    UINavigationController *modalNav = [[UINavigationController alloc] initWithRootViewController:modal];
    [self presentViewController:modalNav animated:YES completion:nil];
}

@end
