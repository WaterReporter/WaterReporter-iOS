//
//  NSString+MD5.m
//  WaterReporter
//
//  Created by Viable Industries on 5/19/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import "NSString+MD5.h"

@implementation NSString (MD5)

- (NSString *) MD5String
{
    const char *cstr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, strlen(cstr), result);
    NSString *hash = [NSString stringWithFormat:
                     @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                     result[0], result[1], result[2], result[3],
                     result[4], result[5], result[6], result[7],
                     result[8], result[9], result[10], result[11],
                     result[12], result[13], result[14], result[15]
                     ];
    NSString *lowerCaseHash = [hash lowercaseString];
    
    return lowerCaseHash;
}

@end
