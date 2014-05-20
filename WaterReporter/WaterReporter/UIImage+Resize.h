//
//  UIImage+Resize.h
//  WaterReporter
//
//  Created by Ryan Hamley on 5/20/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)

+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)size;

+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)size
               cornerRadius:(CGFloat)cornerRadius;

+ (UIImage *)cropImageWithInfo:(NSDictionary *)info;

@end
