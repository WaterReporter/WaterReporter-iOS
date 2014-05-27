//
//  VIChildViewController.m
//  Fractracker
//
//  Created by Ryan Hamley on 5/15/14.
//  Copyright (c) 2014 Viable. All rights reserved.
//

#import "VIChildViewController.h"

#define COLOR_BRAND_BLUE_BASE [UIColor colorWithRed:20.0/255.0 green:165.0/255.0 blue:241.0/255.0 alpha:1.0]

@interface VIChildViewController ()

@end

@implementation VIChildViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSArray *slides = @[[UIImage imageNamed:@"slide_1"], [UIImage imageNamed:@"slide_2"], [UIImage imageNamed:@"slide_3"], [UIImage imageNamed:@"slide_4"], [UIImage imageNamed:@"slide_5"], [UIImage imageNamed:@"slide_6"]];
    
    self.view.backgroundColor = COLOR_BRAND_BLUE_BASE;
    UIImage *background = slides[self.index];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: background];
    
    [self.view addSubview: imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
