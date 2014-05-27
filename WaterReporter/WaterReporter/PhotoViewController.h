//  PhotoViewController.h
//  BeerTracker
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.

#import <UIKit/UIKit.h>
#import "UIImage+ResizeMagick.h"

@interface PhotoViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) UIImage *image;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@end
