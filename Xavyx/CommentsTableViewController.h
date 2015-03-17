//
//  CommentsTableViewController.h
//  Xavyx
//
//  Created by Xavy on 4/13/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"
#import "AppDelegate.h"
#import "CommentsTableViewCell.h"

@interface CommentsTableViewController : UITableViewController
{
    IBOutlet UIView *viewTable;
    IBOutlet UIView *viewForm;
    IBOutlet UITextView *chatBox;
    IBOutlet UIButton   *chatButton;
    NSTimer *timer;
}
@property (strong, nonatomic) UIView *commentView;
@property (strong, nonatomic) NSString *idPhoto;

//CommentField
@property (nonatomic, retain) UIView *viewTable;
@property (nonatomic, retain) UIView *viewForm;
@property (nonatomic, retain) UITextView *chatBox;
@property (nonatomic, retain) UIButton *chatButton;

- (IBAction)chatButtonClick:(id)sender;

@end
