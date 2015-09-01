//
//  VITutorialViewController.m
//  Fractracker
//
//  Created by Joshua Isaac Powell on 5/14/14.
//  Copyright (c) 2014 Viable. All rights reserved.
//

#import "VITutorialViewController.h"

#define COLOR_BRAND_BLUE_BASE [UIColor colorWithRed:20.0/255.0 green:165.0/255.0 blue:241.0/255.0 alpha:1.0]

@implementation VITutorialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.view.backgroundColor = [UIColor colorWithRed:38.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:1.0];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+37)];
    
    VIChildViewController *initialViewController = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.pageController.view.clipsToBounds = NO;
    self.view.clipsToBounds = NO;
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    UIButton *endTutorialButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-40, self.view.frame.size.width, 40)];
    [endTutorialButton setTitle:@"Already know how? Get started" forState:UIControlStateNormal];
    [endTutorialButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    endTutorialButton.backgroundColor = [UIColor colorWithRed:38.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:1.0];
    [endTutorialButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [endTutorialButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    [endTutorialButton addTarget:self action:@selector(dismissTutorial) forControlEvents:UIControlEventTouchUpInside];
    
    [self.pageController.view addSubview:endTutorialButton];
    [self.pageController.view bringSubviewToFront:endTutorialButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (VIChildViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    VIChildViewController *childViewController = [[VIChildViewController alloc] init];
    childViewController.index = index;
    
    return childViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(VIChildViewController *)viewController index];
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(VIChildViewController *)viewController index];
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    if (index == 10) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 10;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

- (void)dismissTutorial
{
    [[[self presentingViewController] presentingViewController] dismissViewControllerAnimated:NO completion:nil];
}

@end
