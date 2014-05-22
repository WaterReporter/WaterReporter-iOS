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
    
    // Set View Title
    self.title = @"My Location";

    // Add the content we need to our LocationViewController
    [self setupMapboxMapView];
    [self updateTabBarAppearance];
    
    //show app walkthrough on first launch
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self preparePageController];
    }
    
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
    CGRect mapFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    NSString *mapId = @"developedsimple.hno186oj";
    
    self.mapView = [[MBXMapView alloc] initWithFrame:mapFrame mapID:mapId];
    self.mapView.backgroundColor = [UIColor colorWithWhite:242.0/255.0f alpha:1.0f];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    //create region to display on map
    CLLocationCoordinate2D location = self.mapView.userLocation.location.coordinate;
    CLLocationDistance regionWidth = 1000;
    CLLocationDistance regionHeight = 1000;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, regionWidth, regionHeight);

    [self.mapView setRegion:region animated:YES];
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

}

- (void) styleMyReportsTab
{
    // Load the correct Tab
    UITabBarItem *tabMyReports = [self.navigationController.tabBarController.tabBar.items objectAtIndex:2];
    
    // Default Tab Button Apperance
    tabMyReports.image = [UIImage imageNamed:@"ReportsTabBarButtonDefault"];
    
    // Tapped Tab Button Apperance
    tabMyReports.selectedImage = [UIImage imageNamed:@"ReportsTabBarButtonSelected"];
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
    NSLog(@"loadMapMarkers");
    
    NSString *bearerToken = @"Bearer WhFE64dQI2fuTk1vMpc5pFQHPA6Ayk";
    NSString *url = @"http://api.commonscloud.org/v2/type_d37400ebcba841cfa4c0b03764940b13.geojson?results_per_page=1000";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:bearerToken forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject){
        self.markers = [[NSArray alloc] initWithArray:responseObject[@"features"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadMapMarkersFinishedLoading" object:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        NSLog(@"Error: %@", error);
    }];
}

- (void)drawMapMarkers
{
    NSMutableArray *mutableAnnotationArray = [[NSMutableArray alloc] init];
    
    for(NSDictionary *marker in self.markers){
        
//        MKAnnotationView *annotationView = [[MKAnnotationView alloc] init];
//        annotationView.canShowCallout = YES;
//        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        double latitude;
        double longitude;
        CLLocationCoordinate2D coordinate;
        
        if(marker[@"geometry"] != (id)[NSNull null]){
            if([marker[@"geometry"][@"type"] isEqualToString:@"Point"]){
                latitude = [marker[@"geometry"][@"coordinates"][1] doubleValue];
                longitude = [marker [@"geometry"][@"coordinates"][0] doubleValue];
                coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                self.annotationTitle = @"Marker from if statement";
                annotation.coordinate = coordinate;
                annotation.title = self.annotationTitle;
                [mutableAnnotationArray addObject:annotation];
            }
            else{
                latitude = [marker[@"geometry"][@"geometries"][0][@"coordinates"][1] doubleValue];
                longitude = [marker[@"geometry"][@"geometries"][0][@"coordinates"][0] doubleValue];
                coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                self.annotationTitle = @"Marker from else statement";
                annotation.coordinate = coordinate;
                annotation.title = self.annotationTitle;
                [mutableAnnotationArray addObject:annotation];
            }
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
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"Tap");
}

@end
