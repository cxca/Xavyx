//
//  LoginRegisterViewController.m
//  XavyxArt
//
//  Created by Xavy on 2/3/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import "LoginRegisterViewController.h"

#define TRANSITION_DURATION 0.5

#define email @"email"

@interface LoginRegisterViewController () <TWTSideMenuViewControllerDelegate>
{
//    NSString *globalKey;
    AppDelegate *appDelegate;
}
@property (nonatomic, strong) TWTSideMenuViewController *sideMenuViewController;
@property (nonatomic, strong) MenuViewController *menuViewController;
@property (nonatomic, strong) MainViewController *mainViewController;
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
    [self autoLoginIn];
    
	// Do any additional setup after loading the view.
//    globalKey = @"73DDA869523FF6FCBF64C9AD6E25E";
    
   //Buttons shape
    //Login Button
    _userNameTextField.delegate = self;
    _passwordTextField.delegate = self;
    [_loginButtonOutlet.layer setMasksToBounds:YES];
    [_loginButtonOutlet.layer setCornerRadius:8];
    // You can even add a border
    [_loginButtonOutlet.layer setBorderWidth:.5f];
    
    _loginButtonOutlet.layer.borderColor = [[UIColor blueColor]CGColor];
    
    //Register Button
    [_registerButtonOutlet.layer setMasksToBounds:YES];
    [_registerButtonOutlet.layer setCornerRadius:8];
    // You can even add a border
    [_registerButtonOutlet.layer setBorderWidth:.5f];
    
//    _registerButtonOutlet.layer.borderColor = [[UIColor greenColor]CGColor];
     _registerButtonOutlet.layer.backgroundColor = [[UIColor lightGrayColor]CGColor];
    [_registerButtonOutlet setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registerButtonOutlet setTitle:NSLocalizedString(@"Sign in",nil) forState:UIControlStateNormal];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    _userNameTextField.text = appDelegate.emailReg;
    _passwordTextField.text = appDelegate.passReg;

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
- (IBAction)registerButton:(id)sender {
    NSLog(@"Register button");
}

-(void)loginIn
{
    NSLog(@"Loggin in...");
    
    
    _loginButtonOutlet.hidden = YES;
    [_activity startAnimating];
    
    //form fields validation
//    if (_passwordTextField.text.length < 4 || _userNameTextField.text.length < 4) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Verify",nil) message:NSLocalizedString(@"Enter username and password over 4 chars each.",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss",nil) otherButtonTitles:nil];
//        [alert show];
//        return;
//    }
    
    //encrypt the password
    
    NSString *encryptedPassword = [NSString stringWithFormat:@"%@",[self encrypt:_passwordTextField.text]];
    
    //Encrypt email
    
    NSString *encryptedEmail = [NSString stringWithFormat:@"%@",[self encrypt:_userNameTextField.text]];
    
    //NSLog(@"enc email: %@",encryptedEmail);
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
//    NSDictionary *parameters = @{@"foo": @"bar"};
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
                
                //Login Success
//                NSLog(@"IdUser %@",[responseObject objectForKey:@"IdUser"]);
//                NSInteger tempInt =(long)[responseObject objectForKey:@"IdUser"];
//                appDelegate.UserId = tempInt;
                
//                TWTSideMenuViewController *mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SideMenuViewController"];
////                mainViewController.transitioningDelegate = self;
//                mainViewController.modalPresentationStyle = UIModalPresentationCustom;
//                
//                [self presentViewController:mainViewController animated:YES completion:nil];

                self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];                  self.mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
                self.sideMenuViewController = [[TWTSideMenuViewController alloc] initWithMenuViewController:self.menuViewController mainViewController:[[UINavigationController alloc] initWithRootViewController:self.mainViewController]];
                self.sideMenuViewController.shadowColor = [UIColor blackColor];
                self.sideMenuViewController.edgeOffset = (UIOffset) { .horizontal = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 18.0f : 0.0f };
                self.sideMenuViewController.zoomScale = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 0.5634f : 0.85f;
                self.sideMenuViewController.delegate = self;
                [self presentViewController:self.sideMenuViewController animated:NO completion:nil];
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

    
//    Store Username and password in keychain
//    [SFHFKeychainUtils storeUsername:_userNameTextField.text andPassword:encryptedPassword forServiceName:@"xavyx" updateExisting:TRUE error:&error];
    
//    Retrieve Username and password from keychain
//    [SFHFKeychainUtils getPasswordForUsername:_userNameTextField.text andServiceName:@"xavyx" error:&error];
    
//    [SFHFKeychainUtils deleteItemForUsername:<#(NSString *)#> andServiceName:<#(NSString *)#> error:<#(NSError *__autoreleasing *)#>]
    
}
-(void)autoLoginIn
{
    NSLog(@"Loggin in...");
    UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iPadWidth, iPadHeight)];
    UIImageView *tmpImage = [[UIImageView alloc] initWithFrame:tmpView.frame];
    if(INTERFACE_IS_PHONE)
        tmpImage.image = [UIImage imageNamed:@"iPhone5AppRed"];
    else
        tmpImage.image = [UIImage imageNamed:@"iPadRed"];
    
    UIActivityIndicatorView *tmpActivity = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-20, self.view.frame.size.height/2, 40, 40)];
    
    tmpActivity.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [tmpActivity startAnimating];
    
    [tmpView addSubview:tmpImage];
    [tmpView addSubview:tmpActivity];
//    tmpView.backgroundColor = [UIColor redColor];
    [self.view addSubview:tmpView];
    
    NSUserDefaults *saveapp = [NSUserDefaults standardUserDefaults];
    
    //  Retrieve email
    NSString *encryptedEmail = [saveapp objectForKey:email];
    
    //    Retrieve password from keychain
    NSError *error;
    NSString *encryptedPassword = [SFHFKeychainUtils getPasswordForUsername:encryptedEmail andServiceName:@"xavyx" error:&error];
    
    //    NSLog(@"enc pass: %@",encryptedPassword);
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
                //Login Success
//                NSLog(@"IdUser %@",[responseObject objectForKey:@"IdUser"]);
//                NSInteger tempInt =(long)[responseObject objectForKey:@"IdUser"];
//                appDelegate.UserId = tempInt;
                
//                TWTSideMenuViewController *mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SideMenuViewController"];
//                mainViewController.modalPresentationStyle = UIModalPresentationCustom;
//                
//                [self presentViewController:mainViewController animated:NO completion:nil];

                self.menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];                  self.mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
                self.sideMenuViewController = [[TWTSideMenuViewController alloc] initWithMenuViewController:self.menuViewController mainViewController:[[UINavigationController alloc] initWithRootViewController:self.mainViewController]];
                self.sideMenuViewController.shadowColor = [UIColor blackColor];
                self.sideMenuViewController.edgeOffset = (UIOffset) { .horizontal = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 18.0f : 0.0f };
                self.sideMenuViewController.zoomScale = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 0.5634f : 0.85f;
                self.sideMenuViewController.delegate = self;
                 [self presentViewController:self.sideMenuViewController animated:NO completion:nil];

                [tmpActivity stopAnimating];
                tmpView.hidden = YES;
                [tmpView removeFromSuperview];
            }
            else
                NSLog(@"Error: Authorization failed");
            [tmpActivity stopAnimating];
            tmpView.hidden = YES;
            [tmpView removeFromSuperview];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [tmpActivity stopAnimating];
        tmpView.hidden = YES;
        [tmpView removeFromSuperview];
    }];
    
   
    
    //    Store Username and password in keychain
    //    [SFHFKeychainUtils storeUsername:_userNameTextField.text andPassword:encryptedPassword forServiceName:@"xavyx" updateExisting:TRUE error:&error];
    
    //    Retrieve Username and password from keychain
    //    [SFHFKeychainUtils getPasswordForUsername:_userNameTextField.text andServiceName:@"xavyx" error:&error];
    
    //    [SFHFKeychainUtils deleteItemForUsername:<#(NSString *)#> andServiceName:<#(NSString *)#> error:<#(NSError *__autoreleasing *)#>]
    
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
@end
