//
//  CommentsViewController.h
//  Xavyx
//
//  Created by Xavy on 4/16/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"
#import "AppDelegate.h"
#import "CommentsTableViewCell.h"
#import "PictureCountdownTimer.h"
#import "TableCellDelegate.h"

@interface CommentsViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, TableCellDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UIView *viewTable;
    IBOutlet UIView *viewForm;
    IBOutlet UITextView *chatBox;
    IBOutlet UIButton   *chatButton;
    NSTimer *timer;
}
@property (strong, nonatomic) UIView *commentView;
@property (strong, nonatomic) NSString *idPhoto;
@property (strong, nonatomic) NSDictionary *postDictionary;
@property (strong, nonatomic) UIImage *mainImage;
@property (strong, nonatomic) UIImage *profileImage;
//CommentField
@property (nonatomic, strong) UIView *viewTable;
@property (nonatomic, strong) UIView *viewForm;
@property (nonatomic, strong) UITextView *chatBox;
@property (nonatomic, strong) UIButton *chatButton;

- (IBAction)chatButtonClick:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *streamCurrentDateTime;
@end
