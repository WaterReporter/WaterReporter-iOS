//
//  VITutorialViewController.m
//  WaterReporter
//
//  Created by Ryan Hamley on 5/18/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import "VITutorialViewController.h"

@interface VITutorialViewController ()

@end

@implementation VITutorialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    VIChildViewController *initialViewController = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    UIButton *endTutorialButton = [[UIButton alloc] initWithFrame:CGRectMake(212, 538, 100, 20)];
    [endTutorialButton setTitle:@"Get Started" forState:UIControlStateNormal];
    [endTutorialButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    endTutorialButton.backgroundColor = [UIColor clearColor];
    [endTutorialButton addTarget:self action:@selector(dismissTutorial) forControlEvents:UIControlEventTouchUpInside];
    
    [self.pageController.view addSubview:endTutorialButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (VIChildViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    VIChildViewController *childViewController = [[VIChildViewController alloc] init];
    childViewController.index = index;
    
    return childViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(VIChildViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(VIChildViewController *)viewController index];
    
    index++;
    
    if (index == 4) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 4;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

//- (void)loadLogin
//{
//    VILoginTableViewController *modal = [[VILoginTableViewController alloc] init];
//    UINavigationController *modalNav = [[UINavigationController alloc] initWithRootViewController:modal];
//    [self presentViewController:modalNav animated:YES completion:nil];
//}

- (void)dismissTutorial
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
