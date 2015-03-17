//
//  AppDelegate.m
//  Xavyx
//
//  Created by Xavy on 2/3/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//
#define email @"email"

#import "AppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "SFHFKeychainUtils.h"



@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef ANDROID
    [UIScreen mainScreen].currentMode =
    [UIScreenMode emulatedMode:UIScreenIPhone3GEmulationMode];
#endif
    
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
  
    NSString *osVersion = [[UIDevice currentDevice]systemVersion];
    
    if(osVersion.doubleValue >= 8.0)
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication]
         registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    self.controllerView = 0;

    return YES;
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self autoLoginIn];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"XavyxArt" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"XavyxArt.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


/*
 * ------------------------------------------------------------------------------------------
 *  BEGIN APNS CODE
 * ------------------------------------------------------------------------------------------
 */

/**
 * Fetch and Format Device Token and Register Important Information to Remote Server
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{

#if !TARGET_IPHONE_SIMULATOR
        
    // Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
    NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    
    // Set the defaults to disabled unless we find otherwise...
    NSString *pushBadge = @"disabled";
    NSString *pushAlert = @"disabled";
    NSString *pushSound = @"disabled";
    
    // Check what Registered Types are turned on. This is a bit tricky since if two are enabled, and one is off, it will return a number 2... not telling you which
    // one is actually disabled. So we are literally checking to see if rnTypes matches what is turned on, instead of by number. The "tricky" part is that the
    // single notification types will only match if they are the ONLY one enabled.  Likewise, when we are checking for a pair of notifications, it will only be
    // true if those two notifications are on.  This is why the code is written this way
    if(rntypes == UIRemoteNotificationTypeBadge){
        pushBadge = @"enabled";
    }
    else if(rntypes == UIRemoteNotificationTypeAlert){
        pushAlert = @"enabled";
    }
    else if(rntypes == UIRemoteNotificationTypeSound){
        pushSound = @"enabled";
    }
    else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)){
        pushBadge = @"enabled";
        pushAlert = @"enabled";
    }
    else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)){
        pushBadge = @"enabled";
        pushSound = @"enabled";
    }
    else if(rntypes == ( UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
        pushAlert = @"enabled";
        pushSound = @"enabled";
    }
    else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
        pushBadge = @"enabled";
        pushAlert = @"enabled";
        pushSound = @"enabled";
    }
        
    // Store the deviceToken in the current installation and save it to Parse.
    self.deviceToken = deviceToken;
    
#endif
}

/**
 * Failed to Register for Remote Notifications
 */

 - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
 
 #if !TARGET_IPHONE_SIMULATOR
 
     NSLog(@"Error in registration. Error: %@", error);
 
 #endif
 }

/**
 * Remote Notification Received while application was open.
 */

 - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
 #if !TARGET_IPHONE_SIMULATOR

     
     NSLog(@"Type %@",[[userInfo objectForKey:@"aps"] objectForKey:@"action"]);
     NSLog(@"Type %@",[[userInfo objectForKey:@"aps"] objectForKey:@"id"]);

     self.actionType = [NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"action"]];
     self.actionId = [NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"id"]];
     
     NSLog(@"remote notification: %@",[userInfo description]);
     NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
     
     NSString *alert = [apsInfo objectForKey:@"alert"];
     NSLog(@"Received Push Alert: %@", alert);
     
     NSString *sound = [apsInfo objectForKey:@"sound"];
     NSLog(@"Received Push Sound: %@", sound);
     AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
     
     NSString *badge = [apsInfo objectForKey:@"badge"];
     NSLog(@"Received Push Badge: %@", badge);
     application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
 
     //Mark as read
     NSString *urlString = [NSString stringWithFormat:@"%@/PFNotificationRead.php?",kAPIPath];
     urlString = [urlString stringByAppendingString:@"id="];
     urlString = [urlString stringByAppendingString:self.actionId];
     
     NSString *urlStr = [NSString stringWithFormat:@"%@/%@",kAPIHost,urlString];
     
     NSURL *url = [[NSURL alloc]initWithString:urlStr];
     NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
     NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
     NSLog(@"Register URL: %@", url);
     NSLog(@"Return Data: %@", returnData);
     
     
     // All instances of TestClass will be notified
     [[NSNotificationCenter defaultCenter]
      postNotificationName:@"PNotification"
      object:self];
     
 #endif
 }


/*
 * ------------------------------------------------------------------------------------------
 *  END APNS CODE
 * ------------------------------------------------------------------------------------------
 */

-(void)autoLoginIn
{
    NSLog(@"Loggin in...");
    
    NSUserDefaults *saveapp = [NSUserDefaults standardUserDefaults];
    
    //  Retrieve email
    NSString *encryptedEmail = [saveapp objectForKey:email];
    
    //Retrieve password from keychain
    NSError *error;
    NSString *encryptedPassword = [SFHFKeychainUtils getPasswordForUsername:encryptedEmail andServiceName:@"xavyx" error:&error];
    
    //check whether it's a login or register
    NSString* command = @"reLogin";
    
    NSDictionary* params =[NSDictionary dictionaryWithObjectsAndKeys:
                                  command, @"command",
                                  encryptedEmail, @"email",
                                  encryptedPassword, @"password",
                                  nil];
    NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *response = [responseObject allKeys];
        if(response.count >0)
        {
            
            NSLog(@"Response %@",responseObject);
            if(![[response objectAtIndex:0] isEqual: @"error"])
            {
                NSLog(@"Response success");
            }
            else
                NSLog(@"Error: Authorization failed");
           
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    
    }];
    
}

@end
