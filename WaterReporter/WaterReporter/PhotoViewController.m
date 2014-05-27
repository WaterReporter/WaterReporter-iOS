//  PhotoViewController.m
//  BeerTracker
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.


#import "PhotoViewController.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

- (void)viewDidLoad {
    
	[super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.scrollView setContentSize:CGSizeMake(self.image.size.width, self.image.size.height)];
    
    self.imageView = [[UIImageView alloc] initWithImage:self.image]; // this makes the image view
    [self.imageView setFrame:CGRectMake(0, 64, self.image.size.width, self.image.size.height)];
    
    [self.scrollView addSubview:self.imageView];

    self.scrollView.minimumZoomScale = 0.1;
    self.scrollView.maximumZoomScale = 6.0;
    self.scrollView.contentSize = CGSizeMake(self.image.size.width, self.image.size.height);
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view = self.scrollView;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
