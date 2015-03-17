//
//  AccountManagementViewController.h
//  xavyx
//
//  Created by Xavy on 3/22/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "API.h"
#import "SFHFKeychainUtils.h"
#import "FixOriantation.h"
#import "UIImage+Resize.h"
#import "FBEncryptorAES.h"


@interface AccountManagementViewController : UIViewController <UIScrollViewDelegate,UIAlertViewDelegate, UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *deleteView;
@property (weak, nonatomic) IBOutlet UILabel *deleteLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButtonOutlet;
- (IBAction)deleteButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButtonOutlet;
- (IBAction)profileImageButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;


@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerSelection;

@property (weak, nonatomic) IBOutlet UILabel *sortLabel;
@property (weak, nonatomic) IBOutlet UIButton *sortButton;
- (IBAction)sortButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *doneButtonOutlet;
- (IBAction)doneButtonAction:(id)sender;
@end
