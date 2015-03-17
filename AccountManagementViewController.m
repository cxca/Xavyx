//
//  AccountManagementViewController.m
//  xavyx
//
//  Created by Xavy on 3/22/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import "AccountManagementViewController.h"
#define email @"email"
#define settings @"settings"
#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE

@interface AccountManagementViewController ()
{
    AppDelegate *appDelegate;
    UIView *tmpView;
    UIView *bgnView;
    UIImage *tmpImage;
    NSArray *sortArray;
    BOOL passMatch;

}
@end

@implementation AccountManagementViewController
@synthesize progressView,scrollView, deleteView;
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
    appDelegate = [[UIApplication sharedApplication]delegate];

    //Sort Array
    sortArray = @[@"Most recent",@"Most life"];
    
//    scrollView.contentSize = CGSizeMake(width, 524);
    scrollView.userInteractionEnabled = YES;
    scrollView.scrollEnabled = NO;
    scrollView.delegate = self;

  
    
//    UIPickerView *sortPickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    NSUserDefaults *saveapp = [NSUserDefaults standardUserDefaults];
    if([saveapp objectForKey:settings] == NULL)
        NSLog(@"No settings");
    else
    {
        NSString *str = [NSString stringWithFormat:@"%@",[saveapp valueForKey:settings]];

        self.sortLabel.text = str;
    }
    [self profilePictureDownload];

}

- (void) viewWillDisappear:(BOOL)animated
{

}
-(void)profilePictureDownload
//ProfilePicture
{
    
    //Get Image from server
    NSString *imageUrl = [NSString stringWithFormat:@"%@/%@/%ld.jpg",kAPIHost,@"profile",(long)appDelegate.udid];
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded");
        //3
        dispatch_async(dispatch_get_main_queue(), ^{
            // do stuff with image
            [_profileImageButtonOutlet setImage:[UIImage imageWithData:responseObject] forState:UIControlStateNormal];
            
            if (responseObject == nil) {
                [_profileImageButtonOutlet setImage:[UIImage imageNamed:@"profilePicture120"] forState:UIControlStateNormal];
            }
        });
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [_profileImageButtonOutlet setImage:[UIImage imageNamed:@"profilePicture120"] forState:UIControlStateNormal];
        
        [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(profilePictureDownload) userInfo:nil repeats:NO];

        
    }];
    
    //        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
    //
    //            NSLog(@"Download = %f", (float)totalBytesRead / totalBytesExpectedToRead);
    //
    //        }];
    [operation start];
    
    
    _fullNameLabel.text = appDelegate.fullName;
    
}


- (IBAction)deleteButtonAction:(id)sender {

    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: NSLocalizedString(@"Delete Account",nil) message: NSLocalizedString(@"All your data will be lost!", nil) delegate: self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"Delete",nil),nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        NSLog(@"user pressed Button Indexed 0");
        // Any action can be performed here
    }
    else
    {
        NSString* encrypted = [FBEncryptorAES encryptBase64String:[[alertView textFieldAtIndex:0] text]
                                                        keyString:globalKey
                                                    separateLines:NO];
        NSLog(@"user pressed Button Indexed 1");
        // Delete photos
        
        [self confirmPassword:encrypted];
//        if(confirm)
//            [self deleteAccountConfirmed];
//        else
//        {
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: NSLocalizedString(@"Deletion failed",nil) message: NSLocalizedString(@"Account could not be deleted", nil) delegate: self cancelButtonTitle:NSLocalizedString(@"Dismiss",nil) otherButtonTitles:nil];
//            [alert show];
//        }
    }
}
-(BOOL)confirmPassword:(NSString*)pass
{
    passMatch = false;
    _deleteButtonOutlet.hidden = YES;
    [_activity startAnimating];
    NSString* command = @"confirmPassword";

    NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  command, @"command",
                                  pass, @"password",
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
              
               
                _deleteButtonOutlet.hidden = NO;
                [_activity stopAnimating];
                passMatch = true;
                [self deleteAccountConfirmed];
            }
            else
            {
                NSLog(@"Error: Authorization failed");
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle: NSLocalizedString(@"Deletion failed",nil) message: NSLocalizedString(@"Account could not be deleted", nil) delegate: self cancelButtonTitle:NSLocalizedString(@"Dismiss",nil) otherButtonTitles:nil];
                [alert show];
                [_activity stopAnimating];
                _deleteButtonOutlet.hidden = NO;
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [_activity stopAnimating];
        _deleteButtonOutlet.hidden = NO;
        
        
    }];

    
    
    return passMatch;
}
-(void)deleteAccountConfirmed
{
    NSLog(@"Deleting account...");
    _deleteButtonOutlet.hidden = YES;
    _activity.hidden = NO;
    [_activity startAnimating];
    
    NSString* command = @"deleteAccount";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   command, @"command",
                                   nil];
    NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        NSArray *response = [responseObject allKeys];
        if(response.count >0)
        {
            
            NSLog(@"Response count %@",responseObject);
            if(![[response objectAtIndex:0] isEqual: @"error"])
            {
                NSLog(@"Response success");
                [self logOut];
                
                
            }
            else
            {
                NSLog(@"Error: Authorization failed");
            }
            
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
    
}

-(void)logOut
{
    /*UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[MainViewController new]];
     [self.sideMenuViewController setMainViewController:controller animated:YES closeMenu:YES];*/
    
    //Log out
    //From local - delete password from keychain
    NSUserDefaults *saveapp = [NSUserDefaults standardUserDefaults];
    
    //  Retrieve email
    NSString *encryptedEmail = [saveapp objectForKey:email];
    
    //Delete from macro
    [saveapp setObject:nil forKey:email];
    
    //Delete from keychain
    NSError *error;
    [SFHFKeychainUtils deleteItemForUsername:encryptedEmail andServiceName:@"xavyx" error:&error];
    
    //check whether it's a login or register
    NSString* command = @"logout";
    
    NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  command, @"command",
                                  nil];
    NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        NSArray *response = [responseObject allKeys];
        if(response.count >0)
        {
            
            
            if(![[response objectAtIndex:0] isEqual: @"error"])
            {
                NSLog(@"Response %@",responseObject);
                NSLog(@"Response success");
                
            }
            else
                NSLog(@"Error: Authorization failed");
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)profileImageButtonAction:(id)sender {
    [[[UIActionSheet alloc] initWithTitle:@"Upload picture from:"
                                 delegate:self
                        cancelButtonTitle:@"Cancel"
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"Camera", @"Camera Roll", nil]
     showInView:self.view];

    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            [self pictureAdd:0];
        }
            break;
        case 1:
        {
            [self pictureAdd:1];
        }
            break;
    }
}
-(void)pictureAdd:(NSInteger)type
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
#if TARGET_IPHONE_SIMULATOR
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#else
    if(type == 0)
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    else
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#endif
    imagePickerController.editing = NO;
    imagePickerController.delegate = (id)self;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self uploadPreview:image];
  
    
}
-(void)publishButton:(id)sender
{
 
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:0.5
                     animations:^{
                         if(INTERFACE_IS_PHONE)
                         {
                             CGRect tmpFrame = CGRectMake(15, -450, 290, 410);
                             tmpView.frame = tmpFrame;
                         }
                         else
                         {
                             CGRect tmpFrame = CGRectMake((768/2)-(590/2), -690, 590, 710);
                             tmpView.frame = tmpFrame;
                         }
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                         [bgnView removeFromSuperview];
                         [tmpView removeFromSuperview];
                         
                     }
     ];
    
    
    
    [self uploadSelectedPicture:tmpImage];
    tmpImage = nil;
}
-(void)cancelButton:(id)sender
{
    //    self.tableView.userInteractionEnabled = YES;
    //    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:0.5
                     animations:^{
                             tmpView.alpha = 0.0;
                             bgnView.alpha = 0.0;
                 
                             tmpView.alpha = 0.0;
                             bgnView.alpha = 0.0;
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                         [bgnView removeFromSuperview];
                         [tmpView removeFromSuperview];
                         
                     }
     ];
    
}
-(void)uploadPreview:(UIImage*)image
{
    tmpImage = image;
    CGRect tmpFrame;
    CGRect tmpFrameImageView;
    CGRect tmpFrameButtonCancel;
    CGRect tmpFrameButtonPublish;
    CGRect tmpFrameLabel;
    
    if(INTERFACE_IS_PHONE)
    {
        tmpFrame = CGRectMake(15, -450, 290, 410);
        tmpFrameImageView = CGRectMake(20, 20, 250, 250);
        tmpFrameButtonCancel = CGRectMake(10, 360, 70, 40);
        tmpFrameButtonPublish = CGRectMake(210, 360, 70, 40);
        tmpFrameLabel = CGRectMake(15, 280, 285, 80);
    }
    else
    {
        tmpFrame = CGRectMake((768/2)-(590/2), -690, 590, 710);
        tmpFrameImageView = CGRectMake(20, 20, 550, 550);
        tmpFrameButtonCancel = CGRectMake(10, 660, 70, 40);
        tmpFrameButtonPublish = CGRectMake(510, 660, 70, 40);
        tmpFrameLabel = CGRectMake(0, 600, 590, 40);
    }
    
    tmpView = [[UIView alloc]initWithFrame:tmpFrame];
    //    tmpView.frame = tmpFrame;
    tmpView.backgroundColor = [UIColor whiteColor];
    tmpView.layer.borderColor = [UIColor redColor].CGColor;
    tmpView.layer.borderWidth = 3.0f;
    tmpView.layer.cornerRadius = 5;
    tmpView.layer.masksToBounds = YES;
    
    
    UIImageView *tmpImageView = [[UIImageView alloc]initWithFrame:tmpFrameImageView];
    
    CGFloat div;
    if(image.size.height >= 3000)
        div = 4;
    else if (image.size.height >= 1500)
        div = 2;
    else if (image.size.height >=  1300)
        div = 1.5;
    else
        div = 1;
    
    CGSize size = CGSizeMake(image.size.width/div,image.size.height/div);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    tmpImageView.image = destImage;
    tmpImage = destImage;
    
            UIImage *maskImage = [UIImage imageNamed:@"maskCirclePreview.png"];
        tmpImageView.image = [self maskImage:destImage mask:maskImage];
    

    UIButton *tmpButtonPublic = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    tmpButtonPublic.frame = tmpFrameButtonPublish;
    //    tmpButtonPublic.titleLabel.text = NSLocalizedString(@"Publish",nil);
    [tmpButtonPublic setTitle:NSLocalizedString(@"Publish", nil) forState:UIControlStateNormal];
    [tmpButtonPublic addTarget:self action:@selector(publishButton:) forControlEvents:UIControlEventTouchUpInside];
    tmpButtonPublic.backgroundColor = [UIColor greenColor];
    //    tmpButtonPublic.titleLabel.textColor = [UIColor whiteColor];
    [tmpButtonPublic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tmpButtonPublic.layer setMasksToBounds:YES];
    [tmpButtonPublic.layer setCornerRadius:8];
    
    UIButton *tmpButtonCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    tmpButtonCancel.frame = tmpFrameButtonCancel;
    //    tmpButtonCancel.titleLabel.text = NSLocalizedString(@"Cancel", nil);
    [tmpButtonCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    
    [tmpButtonCancel addTarget:self action:@selector(cancelButton:) forControlEvents:UIControlEventTouchUpInside];
    tmpButtonCancel.backgroundColor = [UIColor lightGrayColor];
    //    tmpButtonCancel.titleLabel.textColor = [UIColor whiteColor];
    [tmpButtonCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tmpButtonCancel.layer setMasksToBounds:YES];
    [tmpButtonCancel.layer setCornerRadius:8];
    
    //Label
    UILabel *tmpLabel = [[UILabel alloc]initWithFrame:tmpFrameLabel];

        tmpLabel.text = NSLocalizedString(@"Profile picture will be seen by everyone", nil);
    
    if(INTERFACE_IS_PAD)
        tmpLabel.textAlignment = NSTextAlignmentCenter;
    tmpLabel.lineBreakMode = YES;
    tmpLabel.numberOfLines = 0;
    
    [tmpView addSubview:tmpImageView];
    [tmpView addSubview:tmpButtonCancel];
    [tmpView addSubview:tmpButtonPublic];
    [tmpView addSubview:tmpLabel];
    
    //    Background view
    bgnView = [[UIView alloc]initWithFrame:[[UIApplication sharedApplication] keyWindow].bounds];
    bgnView.alpha = 0.7;
    bgnView.backgroundColor = [UIColor blackColor];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:bgnView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:tmpView];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:0.5
                     animations:^{
                         if(INTERFACE_IS_PHONE)
                         {
                             CGRect tmpFrame = CGRectMake(15, 40, 290, 410);
                             tmpView.frame = tmpFrame;
                         }
                         else
                         {
                             CGRect tmpFrame = CGRectMake((768/2)-(590/2), 100, 590, 710);
                             tmpView.frame = tmpFrame;
                         }
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                         
                     }
     ];
    
}
- (UIImage*) maskImage:(UIImage *)image mask:(UIImage*)maskImage {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //    UIImage *maskImage = [UIImage imageNamed:@"maskCircle.png"];
    CGImageRef maskImageRef = [maskImage CGImage];
    
    // create a bitmap graphics context the size of the image
    CGContextRef mainViewContentContext = CGBitmapContextCreate (NULL, maskImage.size.width, maskImage.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    
    if (mainViewContentContext==NULL)
        return NULL;
    
    CGFloat ratio = 0;
    
    ratio = maskImage.size.width/ image.size.width;
    
    if(ratio * image.size.height < maskImage.size.height) {
        ratio = maskImage.size.height/ image.size.height;
    }
    
    CGRect rect1  = {{0, 0}, {maskImage.size.width, maskImage.size.height}};
    CGRect rect2  = {{-((image.size.width*ratio)-maskImage.size.width)/2 , -((image.size.height*ratio)-maskImage.size.height)/2}, {image.size.width*ratio, image.size.height*ratio}};
    
    
    CGContextClipToMask(mainViewContentContext, rect1, maskImageRef);
    CGContextDrawImage(mainViewContentContext, rect2, image.CGImage);
    
    
    // Create CGImageRef of the main view bitmap content, and then
    // release that bitmap context
    CGImageRef newImage = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    
    UIImage *theImage = [UIImage imageWithCGImage:newImage];
    
    CGImageRelease(newImage);
    
    // return the image
    return theImage;
}
- (void)animationDidStop:(CAAnimation *)theAnimation2 finished:(BOOL)flag {
    CATransform3D transform = CATransform3DIdentity;
    //         transform.m34 = 1.0/(-700.0);
    //         leftSleeve1.sublayerTransform = transform;
    
    transform = CATransform3DRotate(transform,  180.0f * M_PI / 180.0f, 1.0f, 1.0f, 0.0f);
    transform = CATransform3DRotate(transform,  180.0f * M_PI / 180.0f, 0.0f, 0.0f, 1.0f);
    //    globalLayer.hidden = YES;
    //    globalLayer.sublayerTransform = transform;
    //    globalLayer.hidden = NO;
    
    
}
-(void)uploadSelectedPicture:(UIImage*)image
{
//    pictureAddItem.enabled = NO;
    float widthHeight;
    if(image.size.width > image.size.height)
        widthHeight = image.size.width;
    else
        widthHeight = image.size.height;
    image = [image fixOrientation];
    // Resize the image from the camera
	UIImage *scaledImage;
    // Crop the image to a square
    UIImage *croppedImage;
    
    NSData *imageToUpload;
    
    //Apply Mask

        // Resize the image from the camera
        scaledImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(100, 100) interpolationQuality:kCGInterpolationHigh];
        // Crop the image to a square
        croppedImage = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -100)/2, (scaledImage.size.height -100)/2, 100, 100)];
        
        //Mask image
        UIImage *mask = [UIImage imageNamed:@"maskCircle120"];
        
        // result of the masking method
        UIImage *imageMasked = [self maskImage:croppedImage mask:mask];
        //END
        
        imageToUpload = UIImageJPEGRepresentation(imageMasked,1.0);
        _profileImageButtonOutlet.imageView.image = imageMasked;

    NSString *command = @"uploadProfilePicture";
    NSString *device = [[NSString alloc]init];
    if(INTERFACE_IS_PAD)
        device = @"iPad";
    else
        device = @"iPhone";
    
    NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  command, @"command",
                                  //base64String, @"file",
                                  device, @"device",
                                  nil];
    NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
    progressView.hidden = NO;
    progressView.progress = 0.0;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    // 1. Create `AFHTTPRequestSerializer` which will create your request.
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    // 2. Create an `NSMutableURLRequest`.
    NSMutableURLRequest *request =
    [serializer multipartFormRequestWithMethod:@"POST" URLString:script parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageToUpload
                                    name:@"file"
                                fileName:@"myimage.jpg"
                                mimeType:@"image/jpeg"];
    } error:nil];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"Success %@", responseObject);
//                                         pictureAddItem.enabled = YES;
                                         
                                         
                                     }
     
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Failure %@", error.description);
                                         progressView.hidden = YES;
                                         UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Upload failed" message: NSLocalizedString(@"Network problem.", nil) delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                         
                                         [alert show];
//                                         pictureAddItem.enabled = YES;
                                     }];
    // 4. Set the progress block of the operation.
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        //        NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
        float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            progressView.progress = progress;
            //        [progressView setProgress:progress];
            NSLog(@"Progress %f",progress);
            if(progress == 1.0)
            {
                progressView.hidden = YES;
            }
        });
    }];
    
    // 5. Begin!
    [operation start];
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark-Picker
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    //One column
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //set number of rows
    return sortArray.count;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //set item per row
    return [sortArray objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Selected Row %d", row);
    switch(row)
    {
        case 0:
        {
            self.sortLabel.text = @"Most recent";
            NSUserDefaults *saveapp = [NSUserDefaults standardUserDefaults];
            [saveapp setObject:@"Most recent" forKey:settings];
            [saveapp synchronize];
        }
            break;
        case 1:
        {
            self.sortLabel.text = @"Most life";
            NSUserDefaults *saveapp = [NSUserDefaults standardUserDefaults];
            [saveapp setObject:@"Most life" forKey:settings];
            [saveapp synchronize];

        }
            break;
       
    }
}
- (IBAction)sortButtonAction:(id)sender {
    if([self.pickerSelection isHidden])
    {
        self.pickerSelection.hidden = NO;
        _deleteButtonOutlet.hidden = YES;
        _deleteLabel.hidden = YES;
        _doneButtonOutlet.hidden = NO;
    }
    else
    {
        self.pickerSelection.hidden = YES;
        _deleteButtonOutlet.hidden = NO;
        _deleteLabel.hidden = NO;
        _doneButtonOutlet.hidden = YES;

    }

}
- (IBAction)doneButtonAction:(id)sender {
    self.pickerSelection.hidden = YES;
    _deleteButtonOutlet.hidden = NO;
    _deleteLabel.hidden = NO;
    _doneButtonOutlet.hidden = YES;
}
@end
