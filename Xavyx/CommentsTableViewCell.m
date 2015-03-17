//
//  CommentsTableViewCell.m
//  Xavyx
//
//  Created by Xavy on 4/14/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import "CommentsTableViewCell.h"

@implementation CommentsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)flagButtonAction:(id)sender {
    [self.delegate flagButtonTappedOnCell:self];
}
- (IBAction)postLikeButtonAction:(id)sender {
    [self.delegate likeCommentButtonTappedOnCell:self];
    
}
- (IBAction)postDeleteButtonAction:(id)sender {
    [self.delegate deleteButtonTappedOnCell:self];
}

-(void)commentTextViewSetFrame:(NSInteger)height
{
    _commentTextView.scrollEnabled = YES;
    CGRect frame = _commentTextView.frame;
    frame.size.height = height;
    _commentTextView.frame = frame;
    _commentTextView.contentSize = CGSizeMake(_commentTextView.contentSize.width, height);

}
@end
