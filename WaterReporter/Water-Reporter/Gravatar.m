//
//  Gravatar.m
//  WaterReporter
//
//  Created by Ryan Hamley on 5/19/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import "Gravatar.h"

@implementation Gravatar

-(id) init
{
    self = [self initWithJSON];
    
    return self;
}

-(id) initWithJSON
{
    self = [super init];
    
    //create url for HTTP request
    User *user = [User MR_findFirst];
    NSString *encodedEmail = [user.email MD5String];
    NSString *url = [NSString stringWithFormat:@"%@%@", @"http://www.gravatar.com/avatar/", encodedEmail];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
    
    if(self){
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
            self.avatar = responseObject;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"initWithJSONFinishedLoading" object:nil];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            NSLog(@"Error: %@", error);
        }];
        
        [operation start];
    }
    
    [Gravatar saveAvatar:self];
    
    return self;
}

- (id)initWithEmail:(NSString *)email
{
    self = [super init];
    
    //create url for HTTP request
    NSString *encodedEmail = [email MD5String];
    NSString *url = [NSString stringWithFormat:@"%@%@", @"http://www.gravatar.com/avatar/", encodedEmail];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
    
    if(self){
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
            self.avatar = responseObject;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"initWithJSONFinishedLoading" object:nil];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error){
            NSLog(@"Error: %@", error);
        }];
        
        [operation start];
    }
    
    [Gravatar saveAvatar:self];
    
    return self;
}

- (Gravatar *) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if(self){
        self.avatar = [aDecoder decodeObjectForKey:@"avatar"];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
}

+ (NSString *) getPathToArchive
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    
    NSString *docsDir = [paths objectAtIndex:0];
    
    return [docsDir stringByAppendingString:@"avatar.model"];
}

+ (void) saveAvatar:(Gravatar *)anAvatar
{
    [NSKeyedArchiver archiveRootObject:anAvatar toFile:[Gravatar getPathToArchive]];
}

+ (Gravatar *) getAvatar
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[Gravatar getPathToArchive]];
}

@end
