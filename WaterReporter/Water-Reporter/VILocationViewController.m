//
//  VIFirstViewController.m
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/15/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import "VILocationViewController.h"

#import "Lockbox.h"

#define kWaterReporterUserAccessToken        @"kWaterReporterUserAccessToken"

@implementation VILocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [self setupLocationManager];
    
    // Set View Title
    self.title = @"Explore";

    // Add the content we need to our LocationViewController
    [self setupMapboxMapView:@"developedsimple.mf7anga9"];
    [self updateTabBarAppearance];
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (!self.loadingMapForForm) {
        [self loadMapMarkers];

        UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshMap)];

        self.navigationItem.leftBarButtonItem = refreshButton;

        UIBarButtonItem *toggleButton = [[UIBarButtonItem alloc] initWithTitle:@"Satellite" style:UIBarButtonItemStylePlain target:self action:@selector(toggleMap)];

        self.navigationItem.rightBarButtonItem = toggleButton;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawMapMarkers) name:@"loadMapMarkersFinishedLoading" object:nil];
    }
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
    }];

}

- (BOOL)connected {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

- (void) setupReachability
{
    //Create weak version of self to avoid retain cycle in switch statement
    __weak typeof(self) weakSelf = self;
    
    NSOperationQueue *operationQueue = self.manager.operationQueue;
    [self.manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [operationQueue setSuspended:NO];
                weakSelf.networkStatus = @"reachable";
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [operationQueue setSuspended:YES];
                weakSelf.networkStatus = @"unreachable";
                break;
        }
    }];
    
    
}

- (void) refreshMap
{
    [self loadMapMarkers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawMapMarkers) name:@"loadMapMarkersFinishedLoading" object:nil];
}

- (void) toggleMap
{
    
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Trails"]) {
        //
        // Change the text of the toggle button
        //
        self.navigationItem.rightBarButtonItem.title = @"Satellite";
        
        //
        // Change the basemap to Trails Map
        //
        self.mapView.mapID = @"developedsimple.mf7anga9";

    } else if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"Satellite"]) {
        //
        // Change the text of the toggle button
        //
        self.navigationItem.rightBarButtonItem.title = @"Trails";
        
        //
        // Change the basemap to Satellite Map
        //
        self.mapView.mapID = @"developedsimple.mn44k8he";
    }
    
}

- (void) viewDidAppear:(BOOL)animated
{
    
    NSString *accessToken = [Lockbox stringForKey:kWaterReporterUserAccessToken];
    
    if (!accessToken) {
        VILoginTableViewController *modal = [[VILoginTableViewController alloc] init];
        UINavigationController *modalNav = [[UINavigationController alloc] initWithRootViewController:modal];
        [self presentViewController:modalNav animated:NO completion:nil];
    }
    
    [self refreshMap];
}

- (void) setupMapboxMapView:(NSString *)mapId
{
    
    [self.mapView removeFromSuperview];

    // Setup mapView
    if (!mapId) {
        mapId = @"developedsimple.mf7anga9";
    }
    
    self.mapView = [[MBXMapView alloc] initWithFrame:self.view.bounds mapID:mapId];
    self.mapView.backgroundColor = [UIColor colorWithWhite:242.0/255.0f alpha:1.0f];
    self.mapView.delegate = self;
    
    self.mapView.showsUserLocation = YES;
    
    //create region to display on map
    if (CLLocationCoordinate2DIsValid(self.mapView.userLocation.location.coordinate)) {
    } else {
        [self setupLocationManager];
    }

    CLLocationCoordinate2D location = self.mapView.userLocation.location.coordinate;
    
    CLLocationDistance regionWidth = 1000;
    CLLocationDistance regionHeight = 1000;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, regionWidth, regionHeight);
    
    [self.mapView setRegion:region animated:YES];
    
    [self.view addSubview:self.mapView];
}

- (void) setupLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    
    self.currentLocation = newLocation;
    
    if(self.currentLocation != nil){
        [self.locationManager stopUpdatingLocation];
    }
    
    NSLog(@"Lat and Long were empty needed to set them to %f %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    
}


- (void) updateTabBarAppearance
{

    // Update the styles of each of our tabs
    [self styleMyLocationTab];
    [self styleFormTab];
    [self styleMyReportsTab];

    // Make sure our tab bar is opaque
    self.tabBarController.tabBar.translucent = NO;

}

- (void) styleMyLocationTab
{
    // Load the correct Tab
    UITabBarItem *tabMyLocation = [self.navigationController.tabBarController.tabBar.items objectAtIndex:0];
    
    // Default Tab Button Apperance
    tabMyLocation.image = [UIImage imageNamed:@"LocationTabBarButtonDefault"];
    
    // Tapped Tab Button Apperance
    tabMyLocation.selectedImage = [UIImage imageNamed:@"LocationTabBarButtonSelected"];
    
    tabMyLocation.title = @"Explore";
}

- (void) styleFormTab
{
    // Default Tab Button Appearance
    UIImage *tabSubmitDefault = [UIImage imageNamed:@"SubmitTabBarButtonDefault"];
    
    // Tapped Tab Button Appearance
    UIImage *tabSubmitSelected = [UIImage imageNamed:@"SubmitTabBarButtonSelected"];
    
    //
    // Override button positioning and add appropriate action to perform when tapped/touched
    //
    // The only reason we need to take this extra step is because it's an oversized button that
    // isn't really part of the tab bar
    //
    UIButton *tabSubmitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tabSubmitButton addTarget:self action:@selector(displayFormTableViewControllerTab) forControlEvents:UIControlEventTouchUpInside];
    tabSubmitButton.frame = CGRectMake(self.tabBarController.tabBar.center.x-36.0, -4.0, 82.0, 62.0);
    [tabSubmitButton setBackgroundImage:tabSubmitDefault forState:UIControlStateNormal];
    [tabSubmitButton setBackgroundImage:tabSubmitSelected forState:UIControlStateHighlighted];

    [self.tabBarController.tabBar addSubview:tabSubmitButton];
    [self.tabBarController.tabBar bringSubviewToFront:tabSubmitButton];

}

- (void) styleMyReportsTab
{
    // Load the correct Tab
    UITabBarItem *tabMyReports = [self.navigationController.tabBarController.tabBar.items objectAtIndex:2];
    
    // Default Tab Button Apperance
    tabMyReports.image = [UIImage imageNamed:@"ReportsTabBarButtonDefault"];
    
    // Tapped Tab Button Apperance
    tabMyReports.selectedImage = [UIImage imageNamed:@"ReportsTabBarButtonSelected"];

    tabMyReports.title = @"Profile";
}

- (void)displayFormTableViewControllerTab
{
    [self.tabBarController setSelectedIndex:1];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    //center on userLocation the first time it's found
    if(!self.userLocationUpdated){
        [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:NO];
    }
    
    self.userLocationUpdated = YES;
}

- (void)loadMapMarkers
{
  
    NSString *url = @"http://stg.api.waterreporter.org/v1/data/organization";
    
    NSLog(@"Load map markers");
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    [manager.requestSerializer setValue:@"no-cache, must-revalidate, max-age=0" forHTTPHeaderField:@"Cache-control"];
    
    NSString *accessToken = [Lockbox stringForKey:kWaterReporterUserAccessToken];
    
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", accessToken] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        self.markers = [[NSArray alloc] initWithArray:responseObject[@"features"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadMapMarkersFinishedLoading" object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        
        NSInteger statusCode = operation.response.statusCode;
        
        if (statusCode == 403) {
            [Lockbox setString:@"" forKey:kWaterReporterUserAccessToken];
            
            VILoginTableViewController *modal = [[VILoginTableViewController alloc] init];
            UINavigationController *modalNav = [[UINavigationController alloc] initWithRootViewController:modal];
            [self presentViewController:modalNav animated:NO completion:nil];
        }
    }];
}

- (void)drawMapMarkers
{
    NSMutableArray *mutableAnnotationArray = [[NSMutableArray alloc] init];

    [self.mapView removeAnnotations:self.mapView.annotations];
    
    for(NSDictionary *marker in self.markers){
        VIPointAnnotation *annotation = [[VIPointAnnotation alloc] init];
        double latitude;
        double longitude;
        CLLocationCoordinate2D coordinate;
        
        if(marker[@"geometry"] != (id)[NSNull null]){
            
            //
            // Prepare Map Coordinates for display
            //
            if([marker[@"geometry"][@"type"] isEqualToString:@"Point"]){
                latitude = [marker[@"geometry"][@"coordinates"][1] doubleValue];
                longitude = [marker [@"geometry"][@"coordinates"][0] doubleValue];
            }
            else{
                latitude = [marker[@"geometry"][@"geometries"][0][@"coordinates"][1] doubleValue];
                longitude = [marker[@"geometry"][@"geometries"][0][@"coordinates"][0] doubleValue];
            }
            coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            
            annotation.coordinate = coordinate;
            
            //
            // Prepare Title for display
            //
            annotation.reportID = marker[@"id"];
            NSString *reportType = @"Unknown";
            
            if (marker[@"properties"][@"territory"] != [NSNull null]) {
                if (marker[@"properties"][@"territory"][@"properties"][@"huc_6_name"] != [NSNull null]) {
                    reportType = marker[@"properties"][@"territory"][@"properties"][@"huc_6_name"];
                }
            }
            
            annotation.title = [NSString stringWithFormat:@"%@ Watershed Report", reportType];
            
            //
            // Prepare the Date for display
            //
            NSString *dateString = marker[@"properties"][@"report_date"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];

            NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            [dateFormatter setLocale:posix];
            
            NSDate *date = [dateFormatter dateFromString:dateString];
            
            [dateFormatter setDateFormat:@"LLLL d, yyyy"];

            NSString *formattedDateString = [dateFormatter stringFromDate:date];
            
            annotation.subtitle = [NSString stringWithFormat:@"Submitted on %@", formattedDateString];
            
            //
            //
            //
            [mutableAnnotationArray addObject:annotation];
        }
    }
    NSArray *annotationArray = [[NSArray alloc] initWithArray:mutableAnnotationArray];
    [self.mapView addAnnotations:annotationArray];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[MKUserLocation class]]){
        return nil;
    }
    
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"location"];
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    if([annotation isKindOfClass:[VIPointAnnotation class]]){
        
        VIPointAnnotation *thisAnnotation = (VIPointAnnotation *)annotation;
        annotationView.annotation = thisAnnotation;
        
        return annotationView;
    }

    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"Pin tapped: didSelectAnnotationView");
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"Pin tapped: calloutAccessoryControlTapped");
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EE, d LLLL yyyy HH:mm:ss Z"];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    if([view.annotation isKindOfClass:[VIPointAnnotation class]]){
        
        VIPointAnnotation *thisAnnotation = (VIPointAnnotation *)view.annotation;
        
        [self showSingleReport:(NSString *)thisAnnotation.reportID];

    }
}

- (void)showSingleReport:(NSString *)reportID
{
    VISingleReportTableViewController *singleReportTableViewController = [[VISingleReportTableViewController alloc] init];
    
    singleReportTableViewController.reportID = reportID;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    [self.navigationController pushViewController:singleReportTableViewController animated:YES];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


@end
