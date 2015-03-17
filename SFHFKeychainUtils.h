//
//  SFHFKeychainUtils.h
//  xavyx
//
//  Created by Xavy on 2/28/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFHFKeychainUtils : NSObject
{
    
}
+ (NSString *) getPasswordForUsername: (NSString *) username andServiceName: (NSString *) serviceName error: (NSError **) error;
+ (BOOL) storeUsername: (NSString *) username andPassword: (NSString *) password forServiceName: (NSString *) serviceName updateExisting: (BOOL) updateExisting error: (NSError **) error;
+ (BOOL) deleteItemForUsername: (NSString *) username andServiceName: (NSString *) serviceName error: (NSError **) error;


@end
