//
//  Report.h
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/15/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Report : NSManagedObject

@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * feature_id;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSDate * report_date;
@property (nonatomic, retain) NSString * report_description;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * geometry;
@property (nonatomic, retain) User *owner;

@end
