//
//  LoginRegisterViewController.m
//  Xavyx
//
//  Created by Xavy on 2/3/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import "LoginRegisterViewController.h"

#define TRANSITION_DURATION 0.5

#define email @"email"

@interface LoginRegisterViewController ()
{
//    NSString *globalKey;
    AppDelegate *appDelegate;
    FBLoginView *loginView;
}
@end

@implementation LoginRegisterViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = [[UIApplication sharedApplication]delegate];
    
    //Facebook login
    loginView =
    [[FBLoginView alloc] initWithReadPermissions:
     @[@"basic_info", @"email", @"user_likes"]];
    loginView.delegate = self;
    if(INTERFACE_IS_PHONE)
    {
        loginView.frame = CGRectMake(0, 0, 280, 40);
        if(!isiPhone5)
        {
        loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), self.view.center.y+10);
        }
        else
        {
            loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), self.view.center.y-40);
        }
    }
    else
    {
        loginView.frame = CGRectMake(0, 0, 330, 40);
        loginView.frame = CGRectOffset(loginView.frame, (self.view.center.x - (loginView.frame.size.width / 2)), self.view.center.y-100);
    }
    [loginView.layer setMasksToBounds:YES];
    [loginView.layer setCornerRadius:8];
    // You can even add a border
//    [loginView.layer setBorderWidth:.5f];
    [self.view addSubview:loginView];
    
    [self autoLoginIn];
    
    
   //Buttons shape
    //Login Button
    _userNameTextField.delegate = self;
    _passwordTextField.delegate = self;
    [_loginButtonOutlet.layer setMasksToBounds:YES];
    [_loginButtonOutlet.layer setCornerRadius:8];
    // You can even add a border
    [_loginButtonOutlet.layer setBorderWidth:.5f];
    
    _loginButtonOutlet.layer.borderColor = [[UIColor blueColor]CGColor];
    CGRect frame = _loginButtonOutlet.frame;
    frame.size.height = 40;
    _loginButtonOutlet.frame = frame;
    
    //Register Button
    [_registerButtonOutlet.layer setMasksToBounds:YES];
    [_registerButtonOutlet.layer setCornerRadius:8];
    // You can even add a border
    [_registerButtonOutlet.layer setBorderWidth:.5f];
    
//    _registerButtonOutlet.layer.borderColor = [[UIColor greenColor]CGColor];
     _registerButtonOutlet.layer.backgroundColor = [[UIColor lightGrayColor]CGColor];
    [_registerButtonOutlet setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registerButtonOutlet setTitle:NSLocalizedString(@"Sign up",nil) forState:UIControlStateNormal];
    frame = _registerButtonOutlet.frame;
    frame.size.height = 40;
    _registerButtonOutlet.frame = frame;
    
    _userNameTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    _userNameTextField.text = appDelegate.emailReg;
    _passwordTextField.text = appDelegate.passReg;
    NSLog(@"Email %@",appDelegate.emailReg);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)encrypt:(NSString*)string
{
    NSString* encrypted = [FBEncryptorAES encryptBase64String:string
                                                    keyString:globalKey
                                                separateLines:NO];
    return encrypted;
}
-(NSString*)decrypt:(NSString*)string
{
    NSString* decrypted = [FBEncryptorAES decryptBase64String:string
                                                    keyString:globalKey];
    return decrypted;
}




- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([_passwordTextField isFirstResponder] && [touch view] != _passwordTextField) {
        [_passwordTextField resignFirstResponder];
    }
    if ([_userNameTextField isFirstResponder] && [touch view] != _userNameTextField) {
        [_userNameTextField resignFirstResponder];
    }
    if(INTERFACE_IS_PAD)
    {
        if([_userNameTextField.text isEqualToString:@""])
        {
            _userNameTextField.text = appDelegate.emailReg;
            _passwordTextField.text = appDelegate.passReg;
        }
    }
    [super touchesBegan:touches withEvent:event];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == _userNameTextField) {
		[_passwordTextField becomeFirstResponder];
	}
    if (textField == _passwordTextField) {
		[self loginIn];
	}
	return NO;
}

#define ACCEPTABLE_CHARECTERS_EMAIL @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.!@"
#define ACCEPTABLE_CHARECTERS @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.!"


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet];
    
    if(textField == _userNameTextField)
        cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS_EMAIL] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
}

- (IBAction)loginButton:(id)sender {
    [self loginIn];
}

-(void)loginIn
{
    NSLog(@"Loggin in...");
    loginView.hidden = YES;
    
    _loginButtonOutlet.hidden = YES;
    [_activity startAnimating];
    
    //encrypt the password
    NSString *encryptedPassword = [NSString stringWithFormat:@"%@",[self encrypt:_passwordTextField.text]];
    
    //Encrypt email
    NSString *encryptedEmail = [NSString stringWithFormat:@"%@",[self encrypt:_userNameTextField.text]];
    
    //check whether it's a login or register
    NSString* command = @"login";

    NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
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
                NSLog(@"Response %@",responseObject);
                NSLog(@"Response success");
                //    Store Username and password in keychain
                NSError *error;
                NSString *firstName = [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"firstName"]];
                NSString *lastName = [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"lastName"]];
                
                NSString *fullName = [NSString stringWithFormat:@"%@ %@",firstName, lastName];
                
                NSString *udid = [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"udid"]];
                NSInteger tmpInteger = udid.integerValue;

                appDelegate.fullName = fullName;
                appDelegate.udid = tmpInteger;
                
                
                [SFHFKeychainUtils storeUsername:encryptedEmail andPassword:encryptedPassword forServiceName:@"xavyx" updateExisting:TRUE error:&error];
                NSUserDefaults *saveapp = [NSUserDefaults standardUserDefaults];
                [saveapp setObject:encryptedEmail forKey:email];
              
                UINavigationController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
                [self presentViewController:controller animated:YES completion:nil];

                _loginButtonOutlet.hidden = NO;
                [_activity stopAnimating];
                _userNameTextField.text = @"";
                _passwordTextField.text = @"";
                loginView.hidden = NO;
                
            }
            else
            {
                NSLog(@"Error: Authorization failed");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Authentication failed",nil) message:NSLocalizedString(@"Please check your email and password. If you have not activated your account check your email inbox, junk/spam folder.",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss",nil) otherButtonTitles:nil];
                [alert show];
                [_activity stopAnimating];
                _loginButtonOutlet.hidden = NO;
                loginView.hidden = NO;
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [_activity stopAnimating];
        _loginButtonOutlet.hidden = NO;
        loginView.hidden = NO;


    }];
}
-(void)autoLoginIn
{
    NSLog(@"Loggin in...");
    loginView.hidden = YES;

    UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iPadWidth, iPadHeight)];
    UIImageView *tmpImage = [[UIImageView alloc] initWithFrame:tmpView.frame];
    int Y=0;
    if(INTERFACE_IS_PHONE)
        tmpImage.image = [UIImage imageNamed:@"iPhone5AppRed"];
    else
    {
        tmpImage.image = [UIImage imageNamed:@"iPadRed"];
        Y = 30;
    }
    
    UIActivityIndicatorView *tmpActivity = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-20, self.view.frame.size.height/2+Y, 40, 40)];
    
    tmpActivity.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [tmpActivity startAnimating];
    
    [tmpView addSubview:tmpImage];
    [tmpView addSubview:tmpActivity];
//    tmpView.backgroundColor = [UIColor redColor];
    [self.view addSubview:tmpView];
    
    NSUserDefaults *saveapp = [NSUserDefaults standardUserDefaults];
    
    //Retrieve email
    NSString *encryptedEmail = [saveapp objectForKey:email];
    
    //Retrieve password from keychain
    NSError *error;
    NSString *encryptedPassword = [SFHFKeychainUtils getPasswordForUsername:encryptedEmail andServiceName:@"xavyx" error:&error];
    
    //check whether it's a login or register
    NSString* command = @"login";
    NSString *device = [[NSString alloc]init];
    if(INTERFACE_IS_PAD)
        device = @"iPad";
    else
        device = @"iPhone";

    NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  command, @"command",
                                  encryptedEmail, @"email",
                                  encryptedPassword, @"password",
                                  device, @"device",
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
//                NSLog(@"Response %@",responseObject);
                NSLog(@"Response success");
                
                NSString *firstName = [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"firstName"]];
                NSString *lastName = [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"lastName"]];
                
                NSString *fullName = [NSString stringWithFormat:@"%@ %@",firstName, lastName];
                
                NSString *udid = [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"udid"]];
                NSInteger tmpInteger = udid.integerValue;
                
                appDelegate.fullName = fullName;
                appDelegate.udid = tmpInteger;

                UINavigationController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
                [self presentViewController:controller animated:YES completion:nil];

                [tmpActivity stopAnimating];
                tmpView.hidden = YES;
                [tmpView removeFromSuperview];
            }
            else
                NSLog(@"Error: Authorization failed");
            [tmpActivity stopAnimating];
            tmpView.hidden = YES;
            loginView.hidden = NO;

            [tmpView removeFromSuperview];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [tmpActivity stopAnimating];
        tmpView.hidden = YES;
        loginView.hidden = NO;

        [tmpView removeFromSuperview];
    }];
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return TRANSITION_DURATION;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    // Uncomment this line if you want to poke around at what Apple is doing a bit more.
    NSLog(@"context class is %@", [transitionContext class]);
    
    //Index path
    
    UIView *container = transitionContext.containerView;
	
	UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    
    
    // Would be safer to use container bounds here
    CGRect endFrame = [transitionContext initialFrameForViewController:fromVC];
    
    // DEMO: Remove this line for full screen goodness
    //	endFrame = CGRectInset(endFrame, 40.0, 40.0);
    
    
	UIView *move = nil;
	if (toVC.isBeingPresented) {
		toView.frame = endFrame;
		move = [toView snapshotViewAfterScreenUpdates:YES];

	} else {
        
        // DEMO: comment these 2 lines out to see what happens with elements inside modal view
        //        PhotoScrollViewController *modalVC = (PhotoScrollViewController *)fromVC;
        //        [modalVC.centerLabel setAlpha:0.0];
        
		move = [fromView snapshotViewAfterScreenUpdates:YES];
		move.frame = fromView.frame;
		[fromView removeFromSuperview];
	}
    [container addSubview:move];
	
	[UIView animateWithDuration:TRANSITION_DURATION delay:0
         usingSpringWithDamping:500 initialSpringVelocity:15
                        options:0 animations:^{
                            move.frame = endFrame;}
                     completion:^(BOOL finished) {
                         if (toVC.isBeingPresented) {
                             [move removeFromSuperview];
                             toView.frame = endFrame;
                             [container addSubview:toView];
                         } else {
                         }
                         
                         [transitionContext completeTransition: YES];
                     }];
}



- (IBAction)forgotPasswordButtonAction:(id)sender {
}

#pragma mark Facebook
//Facebook
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}
// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
        NSLog(@"Registering in Facebook...");
        
        _loginButtonOutlet.hidden = YES;
        [_activity startAnimating];
        
        //encrypt the password
        NSString *encryptedPassword = [self encrypt:@"Facebook"];
        //Encrypt email
        
        NSString *encryptedEmail = [NSString stringWithFormat:@"%@",[user objectForKey:@"email"]];
        encryptedEmail = [self encrypt:encryptedEmail];
        NSString *firstName = [NSString stringWithFormat:@"%@",user.first_name];
        NSString *lastName = [NSString stringWithFormat:@"%@",user.last_name];
        
        NSString* command = @"registerFacebook";
    
        NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      command, @"command",
                                      encryptedEmail, @"email",
                                      encryptedPassword, @"password",
                                      firstName, @"firstName",
                                      lastName, @"lastName",
                                      nil];
        NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
            NSLog(@"Response %@",responseObject);
            
             [self loginInFacebook:encryptedEmail pass:encryptedPassword];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [_activity stopAnimating];
        }];
        
    
//    self.profilePictureView.profileID = user.id;
//    self.nameLabel.text = user.name;
}
// Logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
//    self.statusLabel.text = @"You're logged in as";
}
// Logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
//    self.profilePictureView.profileID = nil;
//    self.nameLabel.text = @"";
//    self.statusLabel.text= @"You're not logged in!";
}
// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}
-(void)loginInFacebook:(NSString*)encryptedEmail pass:(NSString*)encryptedPassword
{
    NSLog(@"Loggin in Facebook...");

    NSString* command = @"login";

    NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
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
                NSLog(@"Response %@",responseObject);
                NSLog(@"Response success");
                //Store Username and password in keychain
                NSError *error;
                NSString *firstName = [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"firstName"]];
                NSString *lastName = [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"lastName"]];
                
                NSString *fullName = [NSString stringWithFormat:@"%@ %@",firstName, lastName];
                
                NSString *udid = [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"udid"]];
                NSInteger tmpInteger = udid.integerValue;
                
                appDelegate.fullName = fullName;
                appDelegate.udid = tmpInteger;
                
                
                [SFHFKeychainUtils storeUsername:encryptedEmail andPassword:encryptedPassword forServiceName:@"xavyx" updateExisting:TRUE error:&error];
                NSUserDefaults *saveapp = [NSUserDefaults standardUserDefaults];
                [saveapp setObject:encryptedEmail forKey:email];
        
                UINavigationController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
                [self presentViewController:controller animated:YES completion:nil];

                _loginButtonOutlet.hidden = NO;
                [_activity stopAnimating];
                _userNameTextField.text = @"";
                _passwordTextField.text = @"";
                
                
            }
            else
            {
                NSLog(@"Error: Authorization failed");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Authentication failed",nil) message:NSLocalizedString(@"Please check your email and password. If you have not activated your account check your email inbox, junk/spam folder.",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss",nil) otherButtonTitles:nil];
                [alert show];
                [_activity stopAnimating];
                _loginButtonOutlet.hidden = NO;
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [_activity stopAnimating];
        _loginButtonOutlet.hidden = NO;
        
        
    }];
}
@end
