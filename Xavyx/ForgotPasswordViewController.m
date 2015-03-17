//
//  ForgotPasswordViewController.m
//  xavyx
//
//  Created by Xavy on 3/8/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import "ForgotPasswordViewController.h"

#define ACCEPTABLE_CHARECTERS_EMAIL @"abcdefghijklmnopqrstuvwxyz0123456789_.!@"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

@synthesize navigationItem;

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
	// Do any additional setup after loading the view.
    _emailTextField.delegate = self;
    _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;

    //Cancel Button
    _cancelButtonOutlet.titleLabel.text = NSLocalizedString(@"Cancel", nil);
    [_cancelButtonOutlet.layer setMasksToBounds:YES];
    [_cancelButtonOutlet.layer setCornerRadius:8];
    // You can even add a border
    [_cancelButtonOutlet.layer setBorderWidth:.5f];
    //    _cancelButtonOutlet.layer.borderColor = [[UIColor blueColor]CGColor];
    _cancelButtonOutlet.layer.borderColor = [[UIColor colorWithRed:(0/255.0) green:(191/255.0) blue:(255/255.0) alpha:1] CGColor];
    
    
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

- (IBAction)submitButtonAction:(id)sender {
    
    [self submit];
}

- (IBAction)cancelButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark-TouchesBegan

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([_emailTextField isFirstResponder] && [touch view] != _emailTextField) {
        [_emailTextField resignFirstResponder];
    }
  
    [super touchesBegan:touches withEvent:event];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _emailTextField) {
		[self submit];
	}
	return NO;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS_EMAIL] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [string isEqualToString:filtered];
}

#pragma mark-Encryption

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

- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

-(void)submit
{
    //Validate email
    if (![self validateEmail:_emailTextField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Verify",nil) message:NSLocalizedString(@"Must be a valid email address",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss",nil) otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    [_activity startAnimating];
    _submitButtonOutlet.hidden = YES;
    
    NSString *encryptedEmail = [NSString stringWithFormat:@"%@",[self encrypt:_emailTextField.text]];
    
    //check whether it's a login or register
    NSString* command = @"forgotPassword";
    
    NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  command, @"command",
                                  encryptedEmail, @"email",
                                  nil];
    NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    NSDictionary *parameters = @{@"foo": @"bar"};
    [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        [self dismissViewControllerAnimated:YES completion:nil];
        NSArray *response = [responseObject allKeys];
        if(response.count >0)
        {
            
            NSLog(@"Response %@",responseObject);
            if(![[response objectAtIndex:0] isEqual: @"error"])
            {
                //NSLog(@"Response %@",responseObject);
               // NSLog(@"Response success");
            }
            else
            {
                NSLog(@"Error: Authorization failed");
                _submitButtonOutlet.hidden = NO;
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self dismissViewControllerAnimated:YES completion:nil];

    }];
}
@end
