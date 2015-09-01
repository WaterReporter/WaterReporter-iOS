//  ImageSaver.m
//  Magical_Record
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.

#import "ImageSaver.h"
#import "Report.h"

@implementation ImageSaver

+ (BOOL)saveImageToDisk:(UIImage*)image andToReport:(Report *)report {
	NSData *imgData   = UIImageJPEGRepresentation(image, 0.5);
	NSString *name    = [[NSUUID UUID] UUIDString];
	NSString *path	  = [NSString stringWithFormat:@"Documents/%@.jpg", name];
	NSString *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    
	if ([imgData writeToFile:jpgPath atomically:YES]) {
            report.image = path;
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
//            [self addSkipBackupAttributeToItemAtURL:path];
            NSLog(@"Path: %@", path);
            NSLog(@"JPGPath: %@", jpgPath);
	} else {
		[[[UIAlertView alloc] initWithTitle:@"Error"
									message:@"There was an error saving your photo. Try again."
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles: nil] show];
		return NO;
	}
	return YES;
}

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error) {
        // Do anything needed to handle the error or display it to the user
    } else {
        // .... do anything you want here to handle
        // .... when the image has been saved in the photo album
    }
}

+ (void)deleteImageAtPath:(NSString *)path {
	NSError *error;
	NSString *imgToRemove = [NSHomeDirectory() stringByAppendingPathComponent:path];
	[[NSFileManager defaultManager] removeItemAtPath:imgToRemove error:&error];
}

@end
