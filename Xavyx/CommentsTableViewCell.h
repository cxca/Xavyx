//
//  CommentsTableViewCell.h
//  Xavyx
//
//  Created by Xavy on 4/14/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableCellDelegate.h"

@interface CommentsTableViewCell : UITableViewCell

@property (nonatomic, strong) id  delegate;

//Post Cell
- (IBAction)flagButtonAction:(id)sender;

- (IBAction)postLikeButtonAction:(id)sender;

- (IBAction)postDeleteButtonAction:(id)sender;

//Comments Cell
@property (weak, nonatomic) IBOutlet UILabel *postedDateLabel;
//- (IBAction)likeButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
-(void)commentTextViewSetFrame:(NSInteger)height;
@end
