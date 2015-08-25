//
//  VILoginTableViewController.h
//  Fractracker
//
//  Created by Ryan Hamley on 4/17/14.
//  Copyright (c) 2014 Viable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "User.h"

@interface VILoginTableViewController : UITableViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) UIToolbar *toolbar;

@property (strong, nonatomic) UITextField *firstNameField;
@property (strong, nonatomic) UITextField *lastNameField;
@property (strong, nonatomic) UITextField *emailField;
@property (strong, nonatomic) UITextField *passwordField;

@property (strong, nonatomic) UITextField *userTypeField;
@property (strong, nonatomic) UIPickerView *userTypePickerView;
@property (strong, nonatomic) NSArray *userTypeEnums;

@property (strong, nonatomic) NSArray *fieldArray;
@property (strong, nonatomic) UIImageView *imageView;

- (UITextField *) makeTextField:(NSString *)text
                    placeholder:(NSString *)placeholder;
- (IBAction) textFieldFinished:(id)sender;
- (void) submitForm;

@end
