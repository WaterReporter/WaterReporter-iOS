//
//  VILoginTableViewController.m
//  Fractracker
//
//  Created by Ryan Hamley on 4/17/14.
//  Copyright (c) 2014 Viable. All rights reserved.
//

#import "VILoginTableViewController.h"
#define COLOR_BRAND_BLUE_BASE [UIColor colorWithRed:20.0/255.0 green:165.0/255.0 blue:241.0/255.0 alpha:1.0]

@interface VILoginTableViewController ()

@end

@implementation VILoginTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];

    if (self) {
        self.title = @"Log in";
    }
    
    NSURL *baseURL = [NSURL URLWithString:@"http://api.waterreporter.org/"];
    self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    self.serializer = [AFJSONRequestSerializer serializer];

    [self.serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    self.manager.requestSerializer = self.serializer;

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.user = [User MR_createEntity];
    
    self.fieldArray = @[@"Email", @"Password", @"Submit"];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:242.0/255.0f alpha:1.0f];
    
    self.tableView.opaque = NO;
    
    UIBarButtonItem *submitItem = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submitForm)];

    self.navigationItem.rightBarButtonItem = submitItem;
    
    [self setupFormToolbar];
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
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(resignTextField)];
    self.toolbar.items = [[NSArray alloc] initWithObjects:doneButton, nil];
    
}

- (void) resignTextField
{
    [self.userTypeField endEditing:YES];
    [self.userTypeField resignFirstResponder];
    
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
        self.passwordField.keyboardType = UIKeyboardTypeDefault;
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
        headerLabel.textColor = COLOR_BRAND_BLUE_BASE;
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

- (void) submitForm
{
    //save user data & dismiss modal
    
    if([self NSStringIsValidEmail:self.emailField.text]){
        
        NSMutableDictionary *json= [[NSMutableDictionary alloc] init];
        
        [json setObject:self.emailField.text forKey:@"email"];
        [json setObject:self.passwordField.text forKey:@"password"];
        
        
        [self.manager POST:@"http://api.waterreporter.org/login" parameters:(NSDictionary *)json success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"response"][@"user"][@"authentication_token"] forKey:@"waterReporterTemporaryToken"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.manager.requestSerializer setAuthorizationHeaderFieldWithToken:[[NSUserDefaults standardUserDefaults] stringForKey:@"waterReporterTemporaryToken"]];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        
        //        [self dismissViewControllerAnimated:YES completion:nil];
        
        

    }
    //else display an alert that user must enter valid email
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh" message:@"Your email address looks wrong, better double check it" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}
@end
