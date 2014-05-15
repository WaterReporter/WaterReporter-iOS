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
#define COLOR_BRAND_WHITE_BASE [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]


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

    self.title = @"Submit Report";
    
    self.templates = @[@"Pollution Report", @"Activity Report"];
    self.template = [[NSString alloc] init];

    self.activityFields = @[@"Date", @"Activity Type", @"Comments"];
    self.pollutionFields = @[@"Date", @"Pollution Type", @"Comments"];

    self.activityEnums = @[@"Water Pollution", @"Confrontation", @"Trail Relocation", @"Scenic Degradation", @"Impaired Wildlife", @"Significant Noise", @"Unpleasant Odors", @"Other"];
    self.pollutionEnums = @[@"Pipeline", @"Drilling or Fracking", @"Pit", @"Well Pad", @"Compressor Station", @"New Roads", @"Aircraft", @"Truck Traffic or Incident", @"Other"];

    [self prepareMapForReport];
    [self updateNavigationController];
    [self setupDifferentFormTypes];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) setupDifferentFormTypes
{
    //
    // Set the currently selected segment
    //
    // https://developer.apple.com/library/iOs/documentation/UIKit/Reference/UISegmentedControl_Class/Reference/UISegmentedControl.html#//apple_ref/occ/instp/UISegmentedControl/selectedSegmentIndex
    //
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:self.templates];
    [self.segmentedControl setFrame:CGRectMake(25, 10, 275, 30)];
    [self.segmentedControl setEnabled:YES];
    [self.segmentedControl addTarget:self action:@selector(segmentClicked:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.tintColor = COLOR_BRAND_BLUE_BASE;
    
    [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:COLOR_BRAND_WHITE_BASE} forState:UIControlStateSelected];
    
    self.segmentedControl.selectedSegmentIndex = 0;

}

- (void)segmentClicked:(id)sender
{
    NSInteger selectedSegment = [sender selectedSegmentIndex];
    NSString *segmentName = self.templates[selectedSegment];
    
    if([segmentName isEqualToString:@"Pollution Report"]){
//        self.fields = [[NSArray alloc] initWithArray:self.trailFields];
//        self.reportType = @"Trail Logbook";
    }
    else if([segmentName isEqualToString:@"Activity Report"]){
//        self.fields = [[NSArray alloc] initWithArray:self.wellFields];
//        self.reportType = @"Well Water Report";
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
    // We have to assigne dthe delegate here to self and then make sure that User Interaction
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

- (void) saveFormContent
{
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
//    NSDate *date = [NSDate date];
//    NSString *dateString = [dateFormatter stringFromDate:date];
//    
//    self.report = [Report MR_createEntity];
//    User *user = [User MR_findFirst];
//    
//    self.report.created = date;
//    self.report.pollution_type = self.pollutionTypeField.text;
//    self.report.comments = self.commentsTypeField.text;
//    self.report.issueType = self.issueTypeField.text;
//    self.report.activity_type = self.activityTypeField.text;
//    self.report.describe = self.describeTextField.text;
//    self.report.facilityType = self.facilityTextField.text;
//    self.report.incidentType = self.incidentTextField.text;
//    self.report.waterIssueType = self.waterIssueTextField.text;
//    self.report.status = @"crowd";
//    self.report.type = self.reportType;
//    self.report.user = user;
//    self.report.longitude = self.reportLongitude;
//    self.report.latitude = self.reportLatitude;
//    //we have to convert the image to the JPEG binary representation to store it
//    //    self.report.image = UIImageJPEGRepresentation(self.imageView.image, 1.0);
//    
//    if([self.potableTextField.text isEqualToString:@"YES"]){
//        NSNumber *number = [NSNumber numberWithInt:1];
//        self.report.potableWater = number;
//    }
//    else{
//        NSNumber *number = [NSNumber numberWithInt:0];
//        self.report.potableWater = number;
//    }
//    
//    if([self.reportType isEqualToString:@"Trail Logbook"]){
//        self.report.pollutiondate = self.datePicker.date;
//    }
//    else if([self.reportType isEqualToString:@"Well Water Report"]){
//        self.report.wellDate = self.datePicker.date;
//    }
//    else if([self.reportType isEqualToString:@"Oil & Gas Report"]){
//        self.report.oilDate = self.datePicker.date;
//    }
//    
//    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"reportSaved" object:nil];
//
}

- (void) resetFormContent
{
    NSString *dateString = [self dateTodayAsString];
    
    // Reset all fields to nil or appropriate default value
}

- (void) submitForm
{
    [self saveFormContent];
    [self.tabBarController setSelectedIndex:2];
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
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    
    if (self.report.image) {
        [ImageSaver deleteImageAtPath:self.report.image];
    }
    
    if ([ImageSaver saveImageToDisk:chosenImage andToReport:self.report]) {
        [self setImageForReport:chosenImage];
    }
    
    //    [self.tableView reloadData];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)selectCameraOrLibrary
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:@"Take A Photo"];
    [actionSheet addButtonWithTitle:@"Choose Existing Photo"];
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex])
    {
        // cancelled, do nothing
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    // obtain a human-readable option string
    NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([option isEqualToString:@"Take A Photo"])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
        
        
        
        
        //        self.cameraUI = [[UIImagePickerController alloc] init];
        //        self.cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        //        [self presentViewController:self.cameraUI animated:YES completion:nil];
    } else if ([option isEqualToString:@"Choose Existing Photo"])
    {
        //        UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
        //        self.cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //
        //        [self presentViewController:self.cameraUI animated:YES completion:nil];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
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
    tf.frame = CGRectMake(0, 0, 290, 35);
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
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
    
    if(pickerView == self.pollutionPickerView){
        NSString *selected = self.pollutionEnums[row];
        self.pollutionTypeField.text = selected;
    }
    else if(pickerView == self.activityPickerView){
        NSString *selected = self.activityEnums[row];
        self.activityTypeField.text = selected;
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

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 90)];
    
    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 55, 290, 35)];
    [cameraButton setTitle:@"Add a photo to your report" forState:UIControlStateNormal];
    cameraButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:13.0];
    cameraButton.backgroundColor = [UIColor colorWithRed:148.0/255.0f green:195.0/255.0f blue:22.0/255.0f alpha:1.0f];
    [cameraButton addTarget:self action:@selector(selectCameraOrLibrary) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *locationButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, 290, 35)];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fieldCell"];
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

    
    if([self.fields[indexPath.row] isEqualToString:@"Date"]){
        [cell setAccessoryView:self.pollutionDateField];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
        NSDate *date = [NSDate date];
        NSString *dateString = [dateFormatter stringFromDate:date];
        
        self.pollutionDateField.inputView = self.datePicker;
        self.pollutionDateField.inputAccessoryView = self.toolbar;
        self.pollutionDateField.text = dateString;
    }
    else if ([self.fields[indexPath.row] isEqualToString:@"Date"]){
        [cell setAccessoryView:self.activityDateField];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
        NSDate *date = [NSDate date];
        NSString *dateString = [dateFormatter stringFromDate:date];
        self.activityDateField.inputView = self.datePicker;
        self.activityDateField.inputAccessoryView = self.toolbar;
        self.activityDateField.text = dateString;
    }
    
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end