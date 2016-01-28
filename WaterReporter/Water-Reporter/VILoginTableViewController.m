//
//  VILoginTableViewController.m
//  Fractracker
//
//  Created by Viable Industries on 4/17/14.
//  Copyright (c) 2014 Viable. All rights reserved.
//

#import "VILoginTableViewController.h"
#import "Lockbox.h"

#define kWaterReporterUserAccessToken @"kWaterReporterUserAccessToken"

@implementation VILoginTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];

    if (self) {
        self.title = @"Log in";
    }
    
    NSURL *baseURL = [NSURL URLWithString:@"http://stg.api.waterreporter.org/"];
    
    self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    self.serializer = [AFJSONRequestSerializer serializer];

    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.manager.responseSerializer = [AFJSONResponseSerializer serializer];

    [Lockbox setString:nil forKey:kWaterReporterUserAccessToken];

    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    NSString *accessToken = [Lockbox stringForKey:kWaterReporterUserAccessToken];
    
    NSLog(@"ACCESSTOKEN VALUE? %@", accessToken);

    if ([accessToken length] != 0) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    //
    //
    self.user = [User MR_createEntity];
    
    self.fieldArray = @[@"Email", @"Password", @"Submit"];

    //
    //
    //
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:242.0/255.0f alpha:1.0f];
    
    self.tableView.opaque = NO;
    
    
    //
    //
    //
    UIBarButtonItem *submitItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitForm)];
    
    self.navigationItem.rightBarButtonItem = submitItem;
    
    UIBarButtonItem *registerItem = [[UIBarButtonItem alloc] initWithTitle:@"Register" style:UIBarButtonItemStylePlain target:self action:@selector(displayRegistrationForm)];
    
    self.navigationItem.leftBarButtonItem = registerItem;

    //
    //
    //
    [self setupFormToolbar];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SettingsShowTutorialOnLaunch"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) setupFormToolbar
{
    self.toolbar = [[UIToolbar alloc] init];
    self.toolbar.barStyle = UIBarStyleDefault;
    self.toolbar.opaque = NO;
    self.toolbar.tintColor = nil;
    [self.toolbar sizeToFit];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.fieldArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fieldCell"];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fieldCell"];
    }
    
    //
    // We need this to ensure that we don't get a goofy gray overlay when we tap
    // in a weird place within the field.
    //
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor = [UIColor clearColor];

    if([self.fieldArray[indexPath.row] isEqualToString:@"Email"]){
        self.emailField = [self makeTextField:self.user.email placeholder:self.fieldArray[indexPath.row]];
        self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
        [cell addSubview:self.emailField];
    }
    else if ([self.fieldArray[indexPath.row] isEqualToString:@"Password"]) {
        self.passwordField = [self makeTextField:self.user.password placeholder:self.fieldArray[indexPath.row]];
        self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.passwordField.keyboardType = UIKeyboardTypeDefault;
        self.passwordField.secureTextEntry = YES;
        [cell addSubview:self.passwordField];
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (section == 0){
        return 96.0f;
    }
    
    return 0.0f;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        // 1. The view for the header
        UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 96)];
        
        // 2. Set a custom background color and a border
        headerView.backgroundColor = [UIColor clearColor];
        headerView.layer.borderWidth = 0.0;
        
        
        // 3. Add a label
        UILabel* headerLabel = [[UILabel alloc] init];
        headerLabel.frame = CGRectMake(0, 24, tableView.frame.size.width, 48);
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor = [UIColor colorWithRed:20.0/255.0 green:165.0/255.0 blue:241.0/255.0 alpha:1.0];
        headerLabel.font = [UIFont  systemFontOfSize:18.0];
        headerLabel.text = @"Do you have an account?\nIf so, you can login below.";
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.numberOfLines = 2;
        
        // 4. Add the label to the header view
        [headerView addSubview:headerLabel];
        
        // 5. Finally return
        return headerView;
    }
    
    return nil;
}

- (UITextField *) makeTextField:(NSString *)text
                    placeholder:(NSString *)placeholder
{
    UITextField *tf = [[UITextField alloc] init];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 35)];
    tf.leftView = paddingView;
    tf.leftViewMode = UITextFieldViewModeAlways;

    tf.text = text;
    tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
//    tf.frame = CGRectMake(10, 10, 300, 35);
    tf.frame = CGRectMake(10, 0, self.view.bounds.size.width-20, 35);
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
    tf.adjustsFontSizeToFitWidth = YES;
    tf.textColor = [UIColor colorWithWhite:242.0/255.0 alpha:1.0];
    tf.borderStyle = UITextBorderStyleNone;
    tf.backgroundColor = [UIColor whiteColor];
    tf.font = [UIFont systemFontOfSize:14.0];
    tf.textColor = [UIColor darkGrayColor];
    
    [tf setReturnKeyType:UIReturnKeyDone];

    
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

//regular expression function to validate user email
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void) displayRegistrationForm
{
    VIRegistrationViewController *modal = [[VIRegistrationViewController alloc] init];
    UINavigationController *modalNav = [[UINavigationController alloc] initWithRootViewController:modal];
    [self presentViewController:modalNav animated:NO completion:nil];
}

- (void) retrieveUserData {
    
    [self.manager GET:@"http://stg.api.waterreporter.org/v1/data/me" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //
        // Use the response data to fill in our default user information
        // and save it to our local database.
        //
        self.user.user_id = responseObject[@"id"];
        self.user.first_name = responseObject[@"first_name"];
        self.user.last_name = responseObject[@"last_name"];
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userSaved" object:nil];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"verifyUserGroups::error: %@", error);
    }];

}

- (void) submitForm
{
    
    __block BOOL isAccessTokenSaved = NO;
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    //
    // Disable the Submit button to ensure only one request is sent
    //
    self.navigationItem.rightBarButtonItem.enabled = NO;

    if ([self.passwordField.text length] == 0 && ![self NSStringIsValidEmail:self.emailField.text]) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Please fill out your email address and password to login" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else if ([self.passwordField.text length] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Don't forget to enter your password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else if([self NSStringIsValidEmail:self.emailField.text]){
        
        //
        // Setup up the loading indicator
        //
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        
        [self.view bringSubviewToFront:self.hud];

        NSString *url = @"http://stg.api.waterreporter.org/v1/auth/remote";


        //
        // Create our URL Parameters
        //
        [json setObject:self.emailField.text forKey:@"email"];
        [json setObject:self.passwordField.text forKey:@"password"];

        [json setObject:@"token" forKey:@"response_type"];
        [json setObject:@"Ru8hamw7ixuCtsHs23Twf4UB12fyIijdQcLssqpd" forKey:@"client_id"];
        [json setObject:@"http://stg.waterreporter.org/authorize" forKey:@"redirect_uri"];
        [json setObject:@"user" forKey:@"scope"];
        [json setObject:@"json" forKey:@"state"];

        
        [self.manager POST:url parameters:(NSDictionary *)json success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSString *accessToken = responseObject[@"access_token"];

            isAccessTokenSaved = [Lockbox setString:accessToken forKey:kWaterReporterUserAccessToken];

            self.serializer = [AFJSONRequestSerializer serializer];
            
            [self.serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [self.serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            self.manager.requestSerializer = self.serializer;
            
            [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [Lockbox stringForKey:kWaterReporterUserAccessToken]] forHTTPHeaderField:@"Authorization"];
            
            //
            // After retrieving the accessToken, we need to save the basic user information so that we can later
            // access it for submitting reports, accessing profile informaiton, and checking groups.
            //
            [self retrieveUserData];
            

            //
            // Hide the HUD/Loading Icon
            //
            [self.hud hide:YES];
        
            self.tutorialVC = [[VITutorialViewController alloc] init];
            [self presentViewController:self.tutorialVC animated:YES completion:nil];
        
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            NSInteger statusCode = operation.response.statusCode;
            NSInteger errorCode = error.code;
            
            NSString *statusMessage = @"";
            
            if (statusCode == 403) {
                statusMessage = @"The email or password you provided was incorrect";
            } else if (errorCode == -1009 || errorCode == -1004) {
                statusMessage = @"We're having trouble with your internet connection, please make sure you have data coverage.";
            } else {
                statusMessage = @"We're not sure what went wrong, please make sure you have data coverage.";
                NSLog(@"ERROR::::%@", error);
            }

            //
            // Hide the HUD/Loading Icon
            //
            [self.hud hide:YES];
            
            //
            // Re-enabled the Submit button so the user can change the incorrect items
            // and resubmit the form.
            //
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
            //
            // Let the user know why there was an error
            //
            [[[UIAlertView alloc] initWithTitle:@"Uh-oh" message:statusMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }];
        

    }
    //else display an alert that user must enter valid email
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh" message:@"Your email address looks wrong, better double check it" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}
@end
