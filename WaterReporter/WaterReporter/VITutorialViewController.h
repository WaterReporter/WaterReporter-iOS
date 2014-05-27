//
//  VITutorialViewController.h
//  Fractracker
//
//  Created by Joshua Isaac Powell on 5/14/14.
//  Copyright (c) 2014 Viable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VIChildViewController.h"

@interface VITutorialViewController : UIViewController <UIPageViewControllerDataSource>

@property UIPageViewController *pageController;

@property NSUInteger pageIndex;
@property (strong, nonatomic) UIPageControl *pageControl;

@end
