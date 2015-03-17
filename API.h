//
//  API.h
//  XavyxArt
//
//  Created by Xavy on 2/27/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "AFNetworking.h"
@protocol HTTPClientDelegate;
//API call completion block with result as json
typedef void (^JSONResponseBlock)(NSDictionary* json);

//the web location of the service
#define kAPIHost @"http://yourdomain.com"//<http://yourdomain.com>
#define kAPIPath @"xavyx"//<path>

@interface API : AFHTTPSessionManager
@property (nonatomic, weak) id<HTTPClientDelegate>delegate;

@property (strong, nonatomic) NSDictionary* user;

+(API*)sharedClient; 
//check whether there's an authorized user
-(BOOL)isAuthorized;
//send an API command to the server
-(void)commandWithParams:(NSMutableDictionary*)params onCompletion:(JSONResponseBlock)completionBlock;
-(NSURL*)urlForImageWithId:(NSNumber*)IdPhoto isThumb:(BOOL)isThumb;


@end
