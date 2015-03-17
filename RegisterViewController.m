//
//  RegisterViewController.m
//  xavyx
//
//  Created by Xavy on 3/2/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import "RegisterViewController.h"

#define ACCEPTABLE_CHARECTERS @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.!"

#define ACCEPTABLE_CHARECTERS_EMAIL @"abcdefghijklmnopqrstuvwxyz0123456789_.!@"

@interface RegisterViewController ()
{
    BOOL keyboardVisible;
    CGPoint offset;
    CGFloat animatedDistance;
    NSInteger code;


}
@end

@implementation RegisterViewController
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@synthesize scrollview,navigationItem;

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
    
    self.title = NSLocalizedString(@"Sign in", nil);
	// Do any additional setup after loading the view.
    scrollview.delegate = self;
    _firstNameTextField.delegate = self;
    _lastNameTextField.delegate = self;
    _eMailTextField.delegate = self;
//    _confrimEmailTectField.delegate = self;
    _passwordTextField.delegate = self;
    _confirmPasswordTextField.delegate = self;
    
    //Cancel Button
    _cancelButtonOutlet.titleLabel.text = NSLocalizedString(@"Cancel", nil);
    [_cancelButtonOutlet.layer setMasksToBounds:YES];
    [_cancelButtonOutlet.layer setCornerRadius:8];
    // You can even add a border
    [_cancelButtonOutlet.layer setBorderWidth:.5f];
//    _cancelButtonOutlet.layer.borderColor = [[UIColor blueColor]CGColor];
     _cancelButtonOutlet.layer.borderColor = [[UIColor colorWithRed:(0/255.0) green:(191/255.0) blue:(255/255.0) alpha:1] CGColor];
    
    //Submit Button
    _submitButtonOutlet.titleLabel.text = NSLocalizedString(@"Agree and Submit", nil);
    
    if(INTERFACE_IS_PAD)
    {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonAction:)];
//        UINavigationItem *navigationItem = [[UINavigationItem alloc]init];
        navigationItem.leftBarButtonItem = cancelButton;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-KeyBoard

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(INTERFACE_IS_PHONE)
    {
        CGRect textFieldRect =
        [self.view.window convertRect:textField.bounds fromView:textField];
        CGRect viewRect =
        [self.view.window convertRect:self.view.bounds fromView:self.view];
        CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
        CGFloat numerator =
        midline - viewRect.origin.y
        - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
        CGFloat denominator =
        (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
        * viewRect.size.height;
        CGFloat heightFraction = numerator / denominator;
        if (heightFraction < 0.0)
        {
            heightFraction = 0.0;
        }
        else if (heightFraction > 1.0)
        {
            heightFraction = 1.0;
        }
        UIInterfaceOrientation orientation =
        [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationPortrait ||
            orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
        }
        else
        {
            animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
        }
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y -= animatedDistance;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        
        [self.view setFrame:viewFrame];
        
        [UIView commitAnimations];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _firstNameTextField) {
		[_lastNameTextField becomeFirstResponder];
	}
    else if (textField == _lastNameTextField) {
		[_eMailTextField becomeFirstResponder];
	}
//    else if (textField == _eMailTextField) {
//		[_confrimEmailTectField becomeFirstResponder];
//	}
    else if (textField == _eMailTextField) {
		[_passwordTextField becomeFirstResponder];
	}
    else if (textField == _passwordTextField) {
		[_confirmPasswordTextField becomeFirstResponder];
	}
    else if (textField == _confirmPasswordTextField) {
		[_confirmPasswordTextField resignFirstResponder];
	}
    return NO;
}



#pragma mark-TouchesBegan

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([_passwordTextField isFirstResponder] && [touch view] != _passwordTextField) {
        [_passwordTextField resignFirstResponder];
    }
    else if ([_confirmPasswordTextField isFirstResponder] && [touch view] != _confirmPasswordTextField) {
        [_confirmPasswordTextField resignFirstResponder];
    }
    else if ([_firstNameTextField isFirstResponder] && [touch view] != _firstNameTextField) {
        [_firstNameTextField resignFirstResponder];
    }
    else if ([_lastNameTextField isFirstResponder] && [touch view] != _lastNameTextField) {
        [_lastNameTextField resignFirstResponder];
    }
    else if ([_eMailTextField isFirstResponder] && [touch view] != _eMailTextField) {
        [_eMailTextField resignFirstResponder];
    }
//    else if ([_confrimEmailTectField isFirstResponder] && [touch view] != _confrimEmailTectField) {
//        [_confrimEmailTectField resignFirstResponder];
//    }
    [super touchesBegan:touches withEvent:event];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet];
    if(textField == _eMailTextField || textField == _confrimEmailTectField)
        cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS_EMAIL] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
}

#pragma mark-ButtonsAction

- (IBAction)submitButtonAction:(id)sender {
    NSLog(@"Registering...");
  
    
    //form fields validation
    if (_firstNameTextField.text.length > 2 && _lastNameTextField.text.length > 2 && _eMailTextField.text.length > 2)
        
    {
        //Validate email
        if (![self validateEmail:_eMailTextField.text]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Verify",nil) message:NSLocalizedString(@"Must be a valid email address",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss",nil) otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        //validate passwords
        if (_passwordTextField.text.length < 4 || _confirmPasswordTextField.text.length < 4) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Verify",nil) message:NSLocalizedString(@"Enter and password over 4 chars each.",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss",nil) otherButtonTitles:nil];
            [alert show];
            return;
        }
        else
        {
            //form fields validation
//            if ([_eMailTextField.text isEqualToString:_confrimEmailTectField.text]) {

                if ([_passwordTextField.text isEqualToString:_confirmPasswordTextField.text]) {
                    NSLog(@"Passwords are ok");
                    //////////////////////////
                    //Go ahead with validation
                    //////////////////////////
                    //encrypt the password
                    
                    NSString *encryptedPassword = [NSString stringWithFormat:@"%@",[self encrypt:_passwordTextField.text]];
                     NSString *encryptedEmail = [NSString stringWithFormat:@"%@",[self encrypt:_eMailTextField.text]];
                    //    NSLog(@"enc pass: %@",encryptedPassword);
                    //check whether it's a login or register
                    NSString* command = @"register";
                    
                    [_activity startAnimating];
                    _submitButtonOutlet.hidden = YES;
                    
                    NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                  command, @"command",
                                                  encryptedEmail, @"email",
                                                  encryptedPassword, @"password",
                                                  _firstNameTextField.text, @"firstName",
                                                  _lastNameTextField.text, @"lastName",
                                                  nil];
                    NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    //    NSDictionary *parameters = @{@"foo": @"bar"};
                    [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        
                        
                         NSLog(@"Response %@",responseObject);
                        NSArray *response = [responseObject allKeys];
                        if(response.count >0)
                        {
                            
                            
                            if(![[response objectAtIndex:0] isEqual: @"error"])
                            {
                           
                                
                                NSLog(@"Code: %@",[responseObject objectForKey:@"code"]);
                                NSString *tmp =[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"code"]];
                                code = tmp.intValue;
                                switch (code) {
                                    case 0:
                                    {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",nil) message:NSLocalizedString(@"The email you have entered is invalid, please try again.",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss",nil) otherButtonTitles:nil];
                                        [alert show];
                                        [_activity stopAnimating];
                                        _submitButtonOutlet.hidden = NO;
                                    }
                                        break;
                                    case 1:
                                    {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Registration success",nil) message:NSLocalizedString(@"Activation is required. You will receive an email soon. Please check your spam/junk folder.",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss",nil) otherButtonTitles:nil];
                                        [alert show];
                                        
                                    }
                                        break;
                                    case 2:
                                    {
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error",nil) message:NSLocalizedString(@"The email is already taken, please try new.",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss",nil) otherButtonTitles:nil];
                                        [alert show];
                                        [_activity stopAnimating];
                                        _submitButtonOutlet.hidden = NO;
                                    }
                                        break;
                                        
                                    default:
                                        break;
                                }

                                
                                
                            }
                            else
                            {
                                NSLog(@"Error: Authorization failed");
                                [_activity stopAnimating];
                                _submitButtonOutlet.hidden = NO;
                            }
                            
                        }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Error: %@", error);
                        [_activity stopAnimating];
                        _submitButtonOutlet.hidden = NO;
                    }];
                    
                    //////////////////
                    //End Registering
                    /////////////////
                    
                    
                }
                else
                {
                    //Passwords does not match
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Verify",nil) message:NSLocalizedString(@"Passwords does not match",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss",nil) otherButtonTitles:nil];
                    [alert show];
                    return;
                }
          /*  }//Email match
            else
            {
                //Emails does not match
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Verify",nil) message:NSLocalizedString(@"Emails does not match",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss",nil) otherButtonTitles:nil];
                [alert show];
                return;
            }*/
            
        }
    }
    else
    {
        //Fields left in blank
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Verify",nil) message:NSLocalizedString(@"Text fields should not be left empty",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss",nil) otherButtonTitles:nil];
        [alert show];
        return;
    }


}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0 && code == 1)
    {
        NSLog(@"code 1 (success)");
        // Any action can be performed here
//        LoginRegisterViewController *loginController;
        AppDelegate *appDelegate =[[UIApplication sharedApplication]delegate];
        appDelegate.emailReg = _eMailTextField.text;
        appDelegate.passReg= _passwordTextField.text;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}
- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

- (IBAction)cancelButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark-Encryptions
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


- (IBAction)termsButtonAction:(id)sender {
}
@end
