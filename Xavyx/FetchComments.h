//
//  FetchComments.h
//  Xavyx
//
//  Created by Xavy on 4/15/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "API.h"

@interface FetchComments : NSObject

-(NSString*)fetchCommentCounts:(NSString*)idPhoto;

@end
