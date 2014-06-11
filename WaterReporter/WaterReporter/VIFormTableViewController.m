//
//  VISecondViewController.m
//  WaterReporter
//
//  Created by Joshua Isaac Powell on 5/15/14.
//  Copyright (c) 2014 Viable Industries, L.L.C. All rights reserved.
//

#import "ImageSaver.h"
#import "PhotoViewController.h"
#import "VIFormTableViewController.h"

#define COLOR_BRAND_BLUE_BASE [UIColor colorWithRed:20.0/255.0 green:165.0/255.0 blue:241.0/255.0 alpha:1.0]
#define COLOR_BRAND_WHITE_BASE [UIColor colorWithWhite:242.0/255.0f alpha:1.0f]

@interface VIFormTableViewController ()

@end

@implementation VIFormTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"";
    
    self.templates = @[@"Pollution Report", @"Activity Report"];
    self.template = [[NSString alloc] init];

    self.activityFields = @[@"Date", @"Activity Type", @"Comments"];
    self.pollutionFields = @[@"Date", @"Pollution Type", @"Comments"];

    self.activityEnums = @[@"Canoeing",@"Diving",@"Fishing",@"Flatwater kayaking",@"Hiking",@"Living the dream",@"Rock climbing",@"Sailing",@"Scouting wildlife",@"Snorkeling",@"Stand-up paddleboarding",@"Stream cleanup",@"Surfing",@"Swimming",@"Tubing",@"Water skiing",@"Whitewater kayaking",@"Whitewater rafting"];
    self.pollutionEnums = @[@"Discolored water", @"Eroded stream banks", @"Excessive algae", @"Excessive trash", @"Exposed soil", @"Faulty construction entryway", @"Faulty silt fences", @"Fish kill", @"Foam", @"Livestock in stream", @"Oil and grease", @"Other", @"Pipe discharge", @"Sewer overflow", @"Stormwater", @"Winter manure application"];

    // We need to make sure we are defining this class or else our Table View will throw
    // an error telling us we didn't define it for reuse. In addition make sure that we
    // style the table to fit the rest of the application
    [self.tableView registerClass: [UITableViewCell class] forCellReuseIdentifier:@"reportCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = COLOR_BRAND_WHITE_BASE;
    self.tableView.opaque = NO;

    [self prepareMapForReport];
    [self updateNavigationController];
    [self setupFormTypes];
    [self setupFormFields];

    [self.tableView reloadData];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) setupFormFields
{
    NSString *dateString = [self dateTodayAsString];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];

    // Setup Toolbar to dismiss keyboards and pickers
    [self setupFormToolbar];
    
    // Setup all date fields
    [self setupDatePicker];
    
    self.activityDateField = [self makeTextField:dateString placeholder:@"Date"];
    self.pollutionDateField = [self makeTextField:dateString placeholder:@"Date"];

    // Setup picker fields
    self.activityTypeField = [self makeTextField:self.report.activity_type placeholder:@"Activity Type"];
    self.activityTypeField.clearButtonMode = UITextFieldViewModeAlways;
    [self.activityTypeField setUserInteractionEnabled:YES];

    self.activityPickerView = [[UIPickerView alloc] init];
    [self.activityPickerView sizeToFit];
    [self.activityPickerView setDelegate:self];
    [self.activityPickerView setDataSource:self];
    self.activityPickerView.showsSelectionIndicator = YES;
    self.activityPickerView.backgroundColor = [UIColor whiteColor];
    [self.activityPickerView setUserInteractionEnabled:YES];

    UITapGestureRecognizer *activityGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(activityViewTapGestureRecognized:)];
    activityGestureRecognizer.cancelsTouchesInView = NO;
    [activityGestureRecognizer setNumberOfTapsRequired:1];
    [self.activityPickerView addGestureRecognizer:activityGestureRecognizer];

    self.pollutionTypeField = [self makeTextField:self.report.pollution_type placeholder:@"Pollution Type"];
    self.pollutionTypeField.clearButtonMode = UITextFieldViewModeAlways;
    [self.pollutionTypeField setUserInteractionEnabled:YES];

    self.pollutionPickerView = [[UIPickerView alloc] init];
    [self.pollutionPickerView sizeToFit];
    [self.pollutionPickerView setDelegate:self];
    [self.pollutionPickerView setDataSource:self];
    self.pollutionPickerView.showsSelectionIndicator = YES;
    self.pollutionPickerView.backgroundColor = [UIColor whiteColor];
    [self.pollutionPickerView setUserInteractionEnabled:YES];

    UITapGestureRecognizer *pollutionGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pollutionViewTapGestureRecognized:)];
    pollutionGestureRecognizer.cancelsTouchesInView = NO;
    [pollutionGestureRecognizer setNumberOfTapsRequired:1];
    [pollutionGestureRecognizer setNumberOfTouchesRequired:1];
    [self.pollutionPickerView addGestureRecognizer:pollutionGestureRecognizer];

    
    // Setup generic text fields
    self.commentsField = [self makeTextField:self.report.comments placeholder:@"Comments"];
    self.commentsField.clearButtonMode = UITextFieldViewModeAlways;
    

}

- (void) activityViewTapGestureRecognized:(UITapGestureRecognizer*)gestureRecognizer
{
    NSLog(@"activityViewTapGestureRecognized tapped");

    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    CGRect frame = self.activityPickerView.frame;
    CGRect selectorFrame = CGRectInset( frame, 0.0, self.activityPickerView.bounds.size.height * 0.85 / 2.0 );
    
    if( CGRectContainsPoint( selectorFrame, touchPoint) )
    {
        NSString *selected = [self.activityEnums objectAtIndex:[self.activityPickerView selectedRowInComponent:0]];
        self.activityTypeField.text = selected;
    }
}

- (void) pollutionViewTapGestureRecognized:(UITapGestureRecognizer*)gestureRecognizer
{
    NSLog(@"pollutionViewTapGestureRecognized tapped");
    
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    CGRect frame = self.pollutionPickerView.frame;
    CGRect selectorFrame = CGRectInset( frame, 0.0, self.pollutionPickerView.bounds.size.height * 0.85 / 2.0 );
    
    if( CGRectContainsPoint( selectorFrame, touchPoint) )
    {
        NSString *selected = [self.pollutionEnums objectAtIndex:[self.pollutionPickerView selectedRowInComponent:0]];
        self.pollutionTypeField.text = selected;
    }
}

- (void) setupFormToolbar
{
    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.barStyle = UIBarStyleDefault;
    self.toolbar.opaque = NO;
    self.toolbar.tintColor = nil;
    [self.toolbar sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(resignTextField)];
    self.toolbar.items = [[NSArray alloc] initWithObjects:doneButton, nil];

}

- (void) setupDatePicker
{
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.datePicker sizeToFit];
    [self.datePicker setDate:[self dateTodayAsDate] animated:YES];
    [self.datePicker addTarget:self action:@selector(dateSelection:) forControlEvents:UIControlEventValueChanged];

}

- (void) fetchAllReports {
    self.reports = [[Report findAllSortedBy:@"created" ascending:NO] mutableCopy];
}


- (void) setupFormTypes
{
    //
    // Set the currently selected segment
    //
    // https://developer.apple.com/library/iOs/documentation/UIKit/Reference/UISegmentedControl_Class/Reference/UISegmentedControl.html#//apple_ref/occ/instp/UISegmentedControl/selectedSegmentIndex
    //
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:self.templates];
    [self.segmentedControl setFrame:CGRectMake(25, 10, self.view.bounds.size.width-47, 30)];
    [self.segmentedControl setEnabled:YES];
    [self.segmentedControl addTarget:self action:@selector(segmentClicked:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.tintColor = COLOR_BRAND_BLUE_BASE;
    
    [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:COLOR_BRAND_WHITE_BASE} forState:UIControlStateSelected];
    
    self.segmentedControl.selectedSegmentIndex = 0;
    self.fields = [[NSArray alloc] initWithArray:self.pollutionFields];
    self.reportType = @"Pollution Report";
}

- (void)segmentClicked:(id)sender
{
    NSInteger selectedSegment = [sender selectedSegmentIndex];
    NSString *segmentName = self.templates[selectedSegment];
    
    if([segmentName isEqualToString:@"Pollution Report"]){
        self.fields = [[NSArray alloc] initWithArray:self.pollutionFields];
        self.reportType = @"Pollution Report";
    }
    else if([segmentName isEqualToString:@"Activity Report"]){
        self.fields = [[NSArray alloc] initWithArray:self.activityFields];
        self.reportType = @"Activity Report";
    }

    
    self.segmentedControl.selectedSegmentIndex = selectedSegment;
    
    [self.tableView reloadData];
    
}

- (void) prepareMapForReport
{
    
    //
    // Setup a Gesture Recognizer so that we can interact with the map and listen for
    // when the user taps the screen to update their location
    //
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateCurrentLocation:)];
    
    gestureRecognizer.numberOfTapsRequired = 1;
    gestureRecognizer.numberOfTouchesRequired = 1;
    
    //
    // We need to have the Map and Gestures loaded when the user asks for them
    //
    self.mapVC = [[VILocationViewController alloc] init];
    self.mapVC.loadingMapForForm = YES;
    
    //
    // Add buttons so the user can Save their changes or Cancel their changes
    //
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveUpdatedLocation)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissMap)];
    
    //
    // We need to make sure that our Map View is loaded within our navigation view so that
    // we have access to the Navigation Bar
    //
    // !!!! IMPORTANT REMINDER !!!
    //
    // We have to assign the delegate here to self and then make sure that User Interaction
    // is enabled on the parent controller, in this case self.mapNavigationController, otherwise
    // our tap gesture will be ignored.
    //
    self.mapNavigationController = [[UINavigationController alloc] initWithRootViewController:self.mapVC];
    self.mapNavigationController.delegate = self;
    self.mapNavigationController.view.userInteractionEnabled = YES;
    
    self.mapVC.title = @"Change your location";
    self.mapVC.navigationItem.leftBarButtonItem = cancelButton;
    self.mapVC.navigationItem.rightBarButtonItem = saveButton;
    
    [self.mapNavigationController.view addGestureRecognizer:gestureRecognizer];
    
}


- (void) updateNavigationController
{
    // Save the form, clear the fields, send user to My Reports
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(submitForm)];
    self.navigationItem.rightBarButtonItem = saveButton;

    // Cancel the form and clear the fields, send user to My Location
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelForm)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    

}

- (NSString*) dateTodayAsString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    NSDate *date = [NSDate date];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

- (NSDate*) dateTodayAsDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    NSDate *date = [NSDate date];
    
    return date;
}

- (void) saveFormContent
{

    //
    // After we save it to the system, we should send the user over to the "My Submission" tab
    // and clear all the form fields
    //
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    NSDate *date = [NSDate date];
    
    self.report = [Report MR_createEntity];
    User *user = [User MR_findFirst];
    
    self.report.uuid = [[NSUUID UUID] UUIDString];
    self.report.feature_id = nil;
    self.report.created = date;
    self.report.comments = self.commentsField.text;
    self.report.activity_type = self.activityTypeField.text;
    self.report.pollution_type = self.pollutionTypeField.text;
    self.report.status = @"public";
    self.report.report_type = self.reportType;
    self.report.owner = user;
    self.report.geometry = [self createGeoJSONPoint];
    self.report.date = self.datePicker.date;
    
    self.report.image = self.path;
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reportSaved" object:nil];

}

- (void) resetFormContent
{
    NSString *dateString = [self dateTodayAsString];
    
    self.activityDateField.text = dateString;
    self.activityTypeField.text = nil;
    self.pollutionDateField.text = dateString;
    self.pollutionTypeField.text = nil;
    self.commentsField.text = nil;
    self.path = nil;
    
    NSLog(@"%@", self.report.image);
}

- (void) submitForm
{

    if (self.path) {
        [self saveFormContent];
        [self resetFormContent];
        [self.tabBarController setSelectedIndex:2];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You forgot a photo" message:@"It looks like you forgot to add a photo to your report, why not do that before submitting." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void) cancelForm
{
    [self resetFormContent];
    [self.tabBarController setSelectedIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*) createGeoJSONPoint
{
    
    NSString *before = @"{\"type\": \"GeometryCollection\",\"geometries\": [{\"type\": \"Point\",\"coordinates\": [";
    NSString *after = @"]}]}";
    NSString *geojson = [NSString stringWithFormat: @"%@%f,%f%@", before, self.reportLongitude, self.reportLatitude, after];

    return geojson;
}

#pragma mark - Media Interactions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	PhotoViewController *upcoming = segue.destinationViewController;
	upcoming.image = self.imageView.image;
}

- (void)setImageForReport:(UIImage*)img {
	self.imageView.image		   = img;
	self.imageView.backgroundColor = [UIColor clearColor];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    NSData *imgData   = UIImageJPEGRepresentation(chosenImage, 0.5);
	NSString *name    = [[NSUUID UUID] UUIDString];
	self.path	  = [NSString stringWithFormat:@"Documents/%@.jpg", name];
	NSString *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:self.path];
    [imgData writeToFile:jpgPath atomically:YES];
    
    UIImageWriteToSavedPhotosAlbum(chosenImage, self, @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), nil);

    [self.tableView reloadData];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error) {
        // Do anything needed to handle the error or display it to the user
    } else {
        // .... do anything you want here to handle
        // .... when the image has been saved in the photo album
    }
}

- (void)selectCameraOrLibrary
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:@"Take A Photo"];
    [actionSheet addButtonWithTitle:@"Choose Existing Photo"];
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    
    [actionSheet showInView:[self.view window]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    // obtain a human-readable option string
    NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([option isEqualToString:@"Take A Photo"]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else if ([option isEqualToString:@"Choose Existing Photo"]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - Location data source

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    
    self.currentLocation = newLocation;
    
    if(self.currentLocation != nil){
        [self.locationManager stopUpdatingLocation];
    }
    
    self.reportLongitude = self.currentLocation.coordinate.longitude;
    self.reportLatitude = self.currentLocation.coordinate.latitude;
    NSLog(@"Lat and Long were empty needed to set them to %f %f", self.reportLatitude, self.reportLongitude);
    
}

- (void)openMapView
{
    //
    // Open up the View Controller and display the map
    //
    [self presentViewController:self.mapNavigationController animated:YES completion:nil];
}

- (void) saveUpdatedLocation
{
    
    NSLog(@"Using temporary values %f %f", self.temporaryLatitude, self.temporaryLongitude);
    
    
    self.reportLatitude = self.temporaryLatitude;
    self.reportLongitude = self.temporaryLongitude;
    
    NSLog(@"To set the reportLat/Long values to %f %f", self.reportLatitude, self.reportLongitude);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissMap
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)updateCurrentLocation:(UIGestureRecognizer*)gestureRecognizer
{
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapVC.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapVC.mapView convertPoint:touchPoint toCoordinateFromView:self.mapVC.mapView];
    
    //
    // Before we go adding anything else to the map, let's remove any existing
    // annotations that the user might have already placed. After all, we don't
    // need to keep track of where they tapped before, just where their current
    // tap was. This is simply a visual indicator to them so they can fine tune
    // where they tapped.
    //
    [self.mapVC.mapView removeAnnotation:self.updatedLocationPin.annotation];
    
    MKPointAnnotation *updatedPin = [[MKPointAnnotation alloc] init];
    updatedPin.coordinate = touchMapCoordinate;
    [self.mapVC.mapView addAnnotation:updatedPin];
    
    self.updatedLocationPin = [[MKPinAnnotationView alloc] initWithAnnotation:updatedPin reuseIdentifier:@"Map Pin"];
    self.updatedLocationPin.pinColor = MKPinAnnotationColorRed;
    self.updatedLocationPin.canShowCallout = YES;
    
    [self.mapVC.mapView addAnnotation:self.updatedLocationPin.annotation];
    
    
    //
    // Update the temporary placeholders so that when the user tabs the 'Save'
    // button the temporary values will be transferred to the Report and properly
    // saved along with the submission
    //
    self.temporaryLatitude = touchMapCoordinate.latitude;
    self.temporaryLongitude = touchMapCoordinate.longitude;
}

#pragma mark - Form Information

- (UITextField *) makeTextField:(NSString *)text
                    placeholder:(NSString *)placeholder
{
    UITextField *tf = [[UITextField alloc] init];
    UIColor *color = [UIColor lightGrayColor];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 10)];
    
    tf.leftView = paddingView;
    tf.leftViewMode = UITextFieldViewModeAlways;
    tf.text = text;
    tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:color}];
//    tf.frame = CGRectMake(0, 0, 290, 35);
    tf.frame = CGRectMake(0, 0, self.view.bounds.size.width-30, 35);
    tf.autocorrectionType = UITextAutocorrectionTypeDefault;
    tf.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    tf.adjustsFontSizeToFitWidth = YES;
    tf.textColor = [UIColor colorWithRed:56.0f/255.0f green:84.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
    tf.borderStyle = UITextBorderStyleNone;
    tf.backgroundColor = [UIColor whiteColor];
    tf.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:14.0];
    tf.textColor = [UIColor darkGrayColor];
    
    [tf addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    return tf;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
}

- (IBAction) textFieldFinished:(id)sender
{
    [sender resignFirstResponder];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    
    if(pickerView == self.activityPickerView){
        NSString *selected = self.activityEnums[row];
        self.activityTypeField.text = selected;
    }
    else if(pickerView == self.pollutionPickerView){
        NSString *selected = self.pollutionEnums[row];
        self.pollutionTypeField.text = selected;
    }
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSUInteger numRows;
    
    if(pickerView == self.pollutionPickerView){
        numRows = self.pollutionEnums.count;
    }
    else if(pickerView == self.activityPickerView){
        numRows = self.activityEnums.count;
    }
    
    return numRows;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSString *title;
    
    if(pickerView == self.pollutionPickerView){
        title = [@"" stringByAppendingFormat:@"%@",self.pollutionEnums[row]];
    }
    else if(pickerView == self.activityPickerView){
        title = [@"" stringByAppendingFormat:@"%@",self.activityEnums[row]];
    }
    
    return title;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}

- (void) dateSelection:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    
    if([self.reportType isEqualToString:@"Activity Report"]){
        NSString *dateString = [dateFormatter stringFromDate:self.datePicker.date];
        self.activityDateField.text = dateString;
    }
    else if([self.reportType isEqualToString:@"Pollution Report"]){
        NSString *dateString = [dateFormatter stringFromDate:self.datePicker.date];
        self.pollutionDateField.text = dateString;
    }

}

- (void) resignTextField
{
    [self.activityDateField endEditing:YES];
    [self.activityDateField resignFirstResponder];

    [self.pollutionDateField endEditing:YES];
    [self.pollutionDateField resignFirstResponder];

    [self.activityTypeField endEditing:YES];
    [self.activityTypeField resignFirstResponder];

    [self.pollutionTypeField endEditing:YES];
    [self.pollutionTypeField resignFirstResponder];
}


#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
    [headerView addSubview:self.segmentedControl];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 90)];
    
    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 55, self.view.bounds.size.width-30, 35)];
    [cameraButton setTitle:@"Add a photo to your report" forState:UIControlStateNormal];
    cameraButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:13.0];
    cameraButton.backgroundColor = [UIColor colorWithRed:148.0/255.0f green:195.0/255.0f blue:22.0/255.0f alpha:1.0f];
    [cameraButton addTarget:self action:@selector(selectCameraOrLibrary) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *locationButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, self.view.bounds.size.width-30, 35)];
    NSString *locationLabel = @"Add a different location";
    UIColor *locationButtonColor = [UIColor darkGrayColor];
    if (isnan(self.reportLongitude) && isnan(self.reportLatitude)){
        locationLabel = @"Set a location for your report";
        locationButtonColor = [UIColor colorWithRed:148.0/255.0f green:195.0/255.0f blue:22.0/255.0f alpha:1.0f];
    }
    [locationButton setTitle:locationLabel forState:UIControlStateNormal];
    locationButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:13.0];
    locationButton.backgroundColor = locationButtonColor;
    [locationButton addTarget:self action:@selector(openMapView) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:cameraButton];
    [footerView addSubview:locationButton];
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 90.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.fields count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reportCell" forIndexPath:indexPath];

    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reportCell"];
    }
    
    //
    // We need this to ensure that we don't get a goofy gray overlay when we tap
    // in a weird place within the field.
    //
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
	[self configureCell:cell atIndex:indexPath];

    return cell;
}

- (void)configureCell:(UITableViewCell*)cell atIndex:(NSIndexPath*)indexPath {
    
//    Report *report = self.reports[indexPath.row];
    
    if([self.fields[indexPath.row] isEqualToString:@"Date"] && [self.reportType isEqualToString:@"Pollution Report"]){
        NSLog(@"Pollution Date Field");
        
        [cell setAccessoryView:self.pollutionDateField];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
        NSDate *date = [NSDate date];
        NSString *dateString = [dateFormatter stringFromDate:date];
        
        self.pollutionDateField.inputView = self.datePicker;
        self.pollutionDateField.inputAccessoryView = self.toolbar;
        self.pollutionDateField.text = dateString;
    }
    else if([self.fields[indexPath.row] isEqualToString:@"Date"] && [self.reportType isEqualToString:@"Activity Report"]){
        NSLog(@"Activity Date Field");

        [cell setAccessoryView:self.activityDateField];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
        NSDate *date = [NSDate date];
        NSString *dateString = [dateFormatter stringFromDate:date];
        self.activityDateField.inputView = self.datePicker;
        self.activityDateField.inputAccessoryView = self.toolbar;
        self.activityDateField.text = dateString;
    }
    else if([self.fields[indexPath.row] isEqualToString:@"Activity Type"]){
        [cell setAccessoryView:self.activityTypeField];
        self.activityTypeField.inputView = self.activityPickerView;
        self.activityTypeField.inputAccessoryView = self.toolbar;
    }
    else if([self.fields[indexPath.row] isEqualToString:@"Pollution Type"]){
        [cell setAccessoryView:self.pollutionTypeField];
        self.pollutionTypeField.inputView = self.pollutionPickerView;
        self.pollutionTypeField.inputAccessoryView = self.toolbar;
    }
    else if([self.fields[indexPath.row] isEqualToString:@"Comments"]){
        [cell setAccessoryView:self.commentsField];
        [self.commentsField setReturnKeyType:UIReturnKeyDone];
    }

}

@end