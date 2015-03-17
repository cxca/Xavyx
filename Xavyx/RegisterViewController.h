//
//  RegisterViewController.h
//  xavyx
//
//  Created by Xavy on 3/2/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBEncryptorAES.h"
#import "API.h"
#import "AppDelegate.h"
#import "LoginRegisterViewController.h"

@interface RegisterViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *eMailTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

//Action
- (IBAction)termsButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *submitButtonOutlet;
- (IBAction)submitButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelButtonOutlet;
- (IBAction)cancelButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
