//
//  Gravatar.h
//  WaterReporter
//
//  Created by Viable Industries on 5/19/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import "User.h"
#import "NSString+MD5.h"

@interface Gravatar : NSObject

@property (strong, nonatomic) UIImage *avatar;

-(id) initWithJSON;

- (id)initWithEmail:(NSString *)email;

+ (NSString *) getPathToArchive;

+ (void) saveAvatar:(Gravatar *)anAvatar;

+ (Gravatar *) getAvatar;


@end
