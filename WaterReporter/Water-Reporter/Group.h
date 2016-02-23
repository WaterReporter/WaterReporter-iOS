//
//  Group.h
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/15/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Group;

@interface Group : NSManagedObject

@property (nonatomic) NSNumber *id;
@property (nonatomic) NSNumber *user_id;
@property (nonatomic) NSNumber *organization_id;
@property (nonatomic, retain) NSString *joined_on;
@property (nonatomic, retain) NSString *is_admin;
@property (nonatomic, retain) NSString *is_member;

@end
