//  ImageSaver.h
//  Magical_Record
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.

#import <Foundation/Foundation.h>
@class Report;

@interface ImageSaver : NSObject

+ (NSString*)saveImageToDisk:(UIImage*)image andToReport:(Report*)report;
+ (void)deleteImageAtPath:(NSString*)path;
@end
