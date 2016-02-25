//
//  VIRegistrationViewController.h
//  Water-Reporter
//
//  Created by Joshua Powell on 8/27/15.
//  Copyright (c) 2015 Viable Industries, L.L.C. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "User.h"
#import "MBProgressHUD.h"
#import "VIGroupsTableViewController.h"

@class VIGroupsTableViewController;

@interface VIRegistrationViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) UIToolbar *toolbar;

//@property (strong, nonatomic) VITutorialViewController *tutorialVC;

@property (strong, nonatomic) UITextField *firstNameField;
@property (strong, nonatomic) UITextField *lastNameField;
@property (strong, nonatomic) UITextField *emailField;
@property (strong, nonatomic) UITextField *passwordField;

@property (strong, nonatomic) NSArray *fieldArray;

- (UITextField *) makeTextField:(NSString *)text placeholder:(NSString *)placeholder;
- (IBAction) textFieldFinished:(id)sender;
- (void) submitForm;

@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) AFJSONRequestSerializer *serializer;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (strong, nonatomic) VIGroupsTableViewController *groupsView;

@end
