//
//  VIRegistrationViewController.m
//  Water-Reporter
//
//  Created by Joshua Powell on 8/27/15.
//  Copyright (c) 2015 Viable Industries, L.L.C. All rights reserved.
//

#import "VIRegistrationViewController.h"
#import "Lockbox.h"

#define kWaterReporterUserAccessToken        @"kWaterReporterUserAccessToken"

@implementation VIRegistrationViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        self.title = @"Register";
    }
    
    NSURL *baseURL = [NSURL URLWithString:@"http://api.waterreporter.org/"];
    
    self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    self.serializer = [AFJSONRequestSerializer serializer];
    
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [Lockbox setString:nil forKey:kWaterReporterUserAccessToken];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.user = [User MR_createEntity];
    
    self.fieldArray = @[@"First Name", @"Last Name", @"Email", @"Password", @"Submit"];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:242.0/255.0f alpha:1.0f];
    
    self.tableView.opaque = NO;
    
    UIBarButtonItem *submitItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitForm)];
    
    self.navigationItem.rightBarButtonItem = submitItem;

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(closeForm)];
    
    self.navigationItem.leftBarButtonItem = cancelItem;

    [self setupFormToolbar];
}

- (void) closeForm
{
    //
    // Hide the modal
    //
    [self dismissViewControllerAnimated:YES completion:nil];

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
    
    if([self.fieldArray[indexPath.row] isEqualToString:@"First Name"]){
        self.firstNameField = [self makeTextField:self.user.first_name placeholder:self.fieldArray[indexPath.row]];
        self.firstNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.firstNameField.keyboardType = UIKeyboardTypeEmailAddress;
        [cell addSubview:self.firstNameField];
    }
    else if([self.fieldArray[indexPath.row] isEqualToString:@"Last Name"]){
        self.lastNameField = [self makeTextField:self.user.last_name placeholder:self.fieldArray[indexPath.row]];
        self.lastNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.lastNameField.keyboardType = UIKeyboardTypeEmailAddress;
        [cell addSubview:self.lastNameField];
    }
    else if([self.fieldArray[indexPath.row] isEqualToString:@"Email"]){
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
        headerLabel.text = @"Don't have an account yet?\nFill out the fields below.";
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

- (void) submitForm
{
    
    __block BOOL isAccessTokenSaved = NO;
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    if ([self.firstNameField.text length] == 0 || [self.lastNameField.text length] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Please tell us your first and last name" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    else if ([self.passwordField.text length] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Don't forget to choose a password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    else if([self NSStringIsValidEmail:self.emailField.text]){
        
        //
        // Setup up the loading indicator
        //
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeIndeterminate;
        
        [self.view bringSubviewToFront:self.hud];
        
        //
        // Disable the Submit button to ensure only one request is sent
        //
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        NSString *url = @"http://api.waterreporter.org/v1/user/register";
        
        //
        // Create our URL Parameters
        //
        [json setObject:self.emailField.text forKey:@"email"];
        [json setObject:self.passwordField.text forKey:@"password"];
        
        [json setObject:@"token" forKey:@"response_type"];
        [json setObject:@"SG92Aa2ejWqiYW4kI08r6lhSyKwnK1gDN2xrryku" forKey:@"client_id"];
        [json setObject:@"http://127.0.0.1:9000/authorize" forKey:@"redirect_uri"];
        [json setObject:@"user" forKey:@"scope"];
        [json setObject:@"json" forKey:@"state"];
        
        [self.manager POST:url parameters:(NSDictionary *)json success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"REGISTRATION SUCCESSFULL %@", responseObject);
            
            self.user.user_id = [NSNumber numberWithInt:[responseObject[@"response"][@"user"][@"id"] integerValue]];
            self.user.first_name = self.firstNameField.text;
            self.user.last_name = self.lastNameField.text;
            self.user.email = self.emailField.text;
            
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
            [self.manager POST:@"http://api.waterreporter.org/v1/auth/remote" parameters:(NSDictionary *)json success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSString *accessToken = responseObject[@"access_token"];
                
                isAccessTokenSaved = [Lockbox setString:accessToken forKey:kWaterReporterUserAccessToken];
                
                NSLog(@"Log successful %@ %@", accessToken, responseObject);
                
                //
                // Save User's first and last name
                //
                NSMutableDictionary *userInformation = [[NSMutableDictionary alloc] init];

                [userInformation setObject:self.user.first_name forKey:@"first_name"];
                [userInformation setObject:self.user.last_name forKey:@"last_name"];
                
                NSString *userUpdateURL = [NSString stringWithFormat:@"%@%@", @"http://api.waterreporter.org/v1/data/user/", self.user.user_id];
                
                [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [Lockbox stringForKey:kWaterReporterUserAccessToken]] forHTTPHeaderField:@"Authorization"];

                [self.manager PATCH:userUpdateURL parameters:(NSDictionary *)userInformation success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"responseObject %@", responseObject);

                    //
                    // Hide the HUD/Loading Icon
                    //
                    [self.hud hide:YES];
                    
                    //
                    // Hide the login and display the tutorial
                    //
                    self.tutorialVC = [[VITutorialViewController alloc] init];
                    [self presentViewController:self.tutorialVC animated:YES completion:nil];

                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error %@", error);
                }];

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
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh" message:statusMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                
                [alert show];
            }];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSInteger errorCode = error.code;
            
            NSString *statusMessage = @"";
            
            if (errorCode == -1009 || errorCode == -1004) {
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh" message:statusMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [alert show];
        }];
        
    }
    //else display an alert that user must enter valid email
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Uh-oh" message:@"Your email address looks wrong, better double check it" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}
@end
