//
//  ForgotPasswordViewController.h
//  xavyx
//
//  Created by Xavy on 3/8/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBEncryptorAES.h"
#import "API.h"

@interface ForgotPasswordViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *cancelButtonOutlet;

- (IBAction)submitButtonAction:(id)sender;
- (IBAction)cancelButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@end
