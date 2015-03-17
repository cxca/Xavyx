//
//  MainCell.m
//  xavyx
//
//  Created by Xavy on 3/10/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import "MainCell.h"

@implementation MainCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)flagButtonAction:(id)sender {
    [self.delegate flagButtonTappedOnCell:self];
}
- (IBAction)likeButtonAction:(id)sender {
    [self.delegate likeButtonTappedOnCell:self];

}
- (IBAction)deleteButtonAction:(id)sender {
    [self.delegate deleteButtonTappedOnCell:self];
}
- (IBAction)commentsButtonAction:(id)sender
{
    [self.delegate commentsButtonTappedOnCell:self];
}



@end
