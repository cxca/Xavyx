//
//  TableCellDelegte.h
//  Xavyx
//
//  Created by Xavy on 4/17/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#ifndef Xavyx_TableCellDelegate_h
#define Xavyx_TableCellDelegate_h

@protocol TableCellDelegate
@optional
- (void)deleteButtonTappedOnCell:(id)sender;
- (void)flagButtonTappedOnCell:(id)sender;
- (void)likeButtonTappedOnCell:(id)sender;
- (void)commentsButtonTappedOnCell:(id)sender;
-(void)likeCommentButtonTappedOnCell:(id)sender;

- (void)mainImageButtonTappedOnCell:(id)sender;

@end

#endif
