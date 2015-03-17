//
//  MainCell.h
//  xavyx
//
//  Created by Xavy on 3/10/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableCellDelegate.h"

@interface MainCell : UITableViewCell <UIGestureRecognizerDelegate>


@property (weak, nonatomic) IBOutlet UIView *imageViewClock;

@property (weak, nonatomic) IBOutlet UILabel *clockLabel;
@property (weak, nonatomic) IBOutlet UILabel *flagLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *flagButtonOutlet;
- (IBAction)flagButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *likeButtonOutlet;
- (IBAction)likeButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *postedDate;
@property (weak, nonatomic) IBOutlet UIButton *deleteButtonOutlet;
- (IBAction)deleteButtonAction:(id)sender;

@property (nonatomic, strong) id  delegate;

//version 1.0.1
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentCountLabel;
- (IBAction)commentsButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *followImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewMain;
@end
