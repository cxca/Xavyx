//
//  AppDelegate.h
//  Xavyx
//
//  Created by Xavy on 2/3/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Xavyx-Prefix.pch"
#import "API.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//Register Login
@property (strong, nonatomic) NSString *emailReg;
@property (strong, nonatomic) NSString *passReg;



@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (assign, nonatomic) NSInteger UserId;

@property (assign, nonatomic) NSInteger controllerView;


@property (strong, nonatomic) NSString *fullName;
@property (assign, nonatomic) NSInteger udid;


//Type if notification is received
@property (assign, nonatomic) BOOL notificationAction;
@property (strong, nonatomic) NSString *actionType;
@property (strong, nonatomic) NSString *actionId;
@property (strong, nonatomic) NSString *actionIdPhoto;
@property (nonatomic,strong) NSData* deviceToken;

@end
