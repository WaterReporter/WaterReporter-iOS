//
//  VIPointAnnotation.h
//  WaterReporter
//
//  Created by Ryan Hamley on 5/23/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface VIPointAnnotation : MKPointAnnotation

@property (strong, nonatomic) NSNumber *reportID;
@property BOOL pollutionReport;

@end
