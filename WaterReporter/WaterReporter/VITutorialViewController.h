//
//  VITutorialViewController.h
//  WaterReporter
//
//  Created by Ryan Hamley on 5/18/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VILoginTableViewController.h"
#import "VIChildViewController.h"

@interface VITutorialViewController : UIViewController <UIPageViewControllerDataSource>

@property UIPageViewController *pageController;

@end
