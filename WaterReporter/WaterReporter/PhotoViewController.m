//  PhotoViewController.m
//  BeerTracker
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.


#import "PhotoViewController.h"

@interface PhotoViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PhotoViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    
	self.imageView = [[UIImageView alloc] initWithImage:self.image];
    NSLog(@"Image: %@", self.image);
    UIImage *resizedImage = [self.image resizedImageByMagick:@"300x350"];
    self.imageView.frame = CGRectMake(10, 70, resizedImage.size.width, resizedImage.size.height);
    [self.view addSubview:self.imageView];
    self.view.backgroundColor = [UIColor whiteColor];
}

@end
