//
//  VIFirstViewController.m
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/15/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import "VILocationViewController.h"

@interface VILocationViewController ()

@end

@implementation VILocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // Set View Title
    self.title = @"My Location";

    // Add the content we need to our LocationViewController
    [self setupMapboxMapView];
    [self updateTabBarAppearance];
    
    //show app walkthrough on first launch
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SettingsShowTutorialOnLaunch"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SettingsShowTutorialOnLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self preparePageController];
    }
    
    if (!self.loadingMapForForm) {
        [self loadMapMarkers];

        UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(refreshMap)];
        
        self.navigationItem.leftBarButtonItem = refreshButton;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawMapMarkers) name:@"loadMapMarkersFinishedLoading" object:nil];
    
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

- (void)refreshMap
{
    [self loadMapMarkers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawMapMarkers) name:@"loadMapMarkersFinishedLoading" object:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    self.userArray = [User MR_findAll];
    
    if(self.userArray.count == 0){

        VILoginTableViewController *modal = [[VILoginTableViewController alloc] init];
        UINavigationController *modalNav = [[UINavigationController alloc] initWithRootViewController:modal];
        [self presentViewController:modalNav animated:YES completion:nil];
    }
    
}

- (void) preparePageController
{
    self.tutorialVC = [[VITutorialViewController alloc] init];
    [self presentViewController:self.tutorialVC animated:YES completion:nil];
}

- (void) setupMapboxMapView
{
    // Setup our Mapbox based MapView using Apple's Mapkit
    NSString *mapId = @"developedsimple.hno186oj";
    
    self.mapView = [[MBXMapView alloc] initWithFrame:self.view.bounds mapID:mapId];
    self.mapView.backgroundColor = [UIColor colorWithWhite:242.0/255.0f alpha:1.0f];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    //create region to display on map
    CLLocationCoordinate2D location;
    
    if (self.mapView.userLocation.location) {
        location = self.mapView.userLocation.location.coordinate;
        
        CLLocationDistance regionWidth = 1000;
        CLLocationDistance regionHeight = 1000;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, regionWidth, regionHeight);
        
        [self.mapView setRegion:region animated:YES];
    } else {
        CLLocation *staticLocation = [[CLLocation alloc] initWithLatitude:39.4397 longitude:-76.9764];
        location = staticLocation.coordinate;
        [self.mapView setCenterCoordinate:location zoomLevel:6.0 animated:YES];
    }
    
    [self.view addSubview:self.mapView];
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
    
    tabMyLocation.title = @"My Location";
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

    tabMyReports.title = @"My Reports";
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
        [self.mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    }
    
    self.userLocationUpdated = YES;
}

- (void)loadMapMarkers
{
    NSString *url = @"http://api.commonscloud.org/v2/type_2c1bd72acccf416aada3a6824731acc9.geojson?results_per_page=1000";
    
    NSLog(@"Load map markers");
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"no-cache, must-revalidate, max-age=0" forHTTPHeaderField:@"Cache-control"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        self.markers = [[NSArray alloc] initWithArray:responseObject[@"features"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadMapMarkersFinishedLoading" object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh" message:@"It looks like you don't have access to a data network right now." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        NSLog(@"Error: %@", error);
    }];
}

- (void)drawMapMarkers
{
    NSMutableArray *mutableAnnotationArray = [[NSMutableArray alloc] init];
    
    for(NSDictionary *marker in self.markers){
        VIPointAnnotation *annotation = [[VIPointAnnotation alloc] init];
        double latitude;
        double longitude;
        CLLocationCoordinate2D coordinate;
        
        if(marker[@"geometry"] != (id)[NSNull null]){
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
            annotation.reportID = marker[@"id"];
            NSString *reportType = @"Activity";
            annotation.pollutionReport = NO;
            
            if (marker[@"properties"][@"is_a_pollution_report?"] && marker[@"properties"][@"is_a_pollution_report?"] != [NSNull null]){
                if ([marker[@"properties"][@"is_a_pollution_report?"] integerValue] == 1) {
                    reportType = @"Pollution";
                    annotation.pollutionReport = YES;
                }
            }
                        
            annotation.title = [NSString stringWithFormat:@"%@ Report", reportType];
            annotation.subtitle = [NSString stringWithFormat:@"Submitted on %@", marker[@"properties"][@"date"]];
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
        
        if (thisAnnotation.pollutionReport) {
            annotationView.image = [UIImage imageNamed:@"pin-yellow"];
        } else {
            annotationView.image = [UIImage imageNamed:@"pin-green"];
        }

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


@end
