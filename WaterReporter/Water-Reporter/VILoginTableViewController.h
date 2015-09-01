//
//  VILoginTableViewController.h
//  Fractracker
//
//  Created by Viable Industries on 4/17/14.
//  Copyright (c) 2014 Viable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "User.h"
#import "MBProgressHUD.h"
#import "VIRegistrationViewController.h"

@interface VILoginTableViewController : UITableViewController <UITextFieldDelegate>

    @property (strong, nonatomic) User *user;
    @property (strong, nonatomic) UIToolbar *toolbar;

    @property (strong, nonatomic) UITextField *emailField;
    @property (strong, nonatomic) UITextField *passwordField;

    @property (strong, nonatomic) NSArray *fieldArray;

    @property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
    @property (strong, nonatomic) AFJSONRequestSerializer *serializer;

    @property (nonatomic, strong) MBProgressHUD *hud;

    - (UITextField *) makeTextField:(NSString *)text placeholder:(NSString *)placeholder;
    - (IBAction) textFieldFinished:(id)sender;
    - (void) submitForm;

@end
