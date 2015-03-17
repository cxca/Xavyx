//
//  UITableViewController+ProfileViewController.h
//  Xavyx
//
//  Created by Xavy on 3/11/15.
//  Copyright (c) 2015 Carlos Chaparro. All rights reserved.
//
//
//  xavyx
//
//  Created by Xavy on 3/4/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainCell.h"
#import "AppDelegate.h"
#import "API.h"
#import "PictureCountdownTimer.h"
#import "UIImage+Resize.h"
#import "XBSnappingPoint.h"
#import "FixOriantation.h"
#import "CommentsTableViewController.h"
#import "CommentsViewController.h"
#import "FetchComments.h"
#import "DSLTransitionFromFirstToSecond.h"
#import "DSLTransitionFromSecondToFirst.h"
#import "SFHFKeychainUtils.h"
#import "AccountManagementViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface ProfileViewController : UITableViewController <UINavigationControllerDelegate, UIPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource,TableCellDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>
{
    NSTimer *timer;
    IBOutlet UILabel *clockLabel;
    NSURLSession *_session;
}

@property (nonatomic, strong) NSURLSessionUploadTask *uploadTask;
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
//@property (strong, nonatomic) NSData *resumeData;

@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

-(void)pullToRefresh;

@property (strong, nonatomic) UITextField *titleTextField;

-(MainCell*)tableViewCell:(NSString*)IdPhoto;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactivePopTransition;

@end
