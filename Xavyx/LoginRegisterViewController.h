//
//  LoginRegisterViewController.h
//  XavyxArt
//
//  Created by Xavy on 2/3/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <CommonCrypto/CommonDigest.h>

#import "FBEncryptorAES.h"
#import "API.h"
#import "SFHFKeychainUtils.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "RegisterViewController.h"
#import <FacebookSDK/FacebookSDK.h>


@interface LoginRegisterViewController : UIViewController <UITextFieldDelegate, FBLoginViewDelegate>

//Button Outlets
@property (weak, nonatomic) IBOutlet UIButton *loginButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *registerButtonOutlet;

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButtonOutlet;

//Buttons Action
- (IBAction)loginButton:(id)sender;
- (IBAction)forgotPasswordButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
