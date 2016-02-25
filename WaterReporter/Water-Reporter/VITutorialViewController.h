//
//  VITutorialViewController.h
//  Fractracker
//
//  Created by Joshua Isaac Powell on 5/14/14.
//  Copyright (c) 2014 Viable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "VIChildViewController.h"
#import "User.h"

@interface VITutorialViewController : UIViewController <UIPageViewControllerDataSource>

@property UIPageViewController *pageController;

@property NSUInteger pageIndex;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) AFJSONRequestSerializer *serializer;

@end
