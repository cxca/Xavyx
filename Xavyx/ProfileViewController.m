//
//  MainViewController.m
//  xavyx
//
//  Created by Xavy on 3/4/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import "ProfileViewController.h"
#define settings @"settings"


@interface ProfileViewController ()
{
    AppDelegate *appDelegate;
    
    NSInteger currentCell, headerHeight, streamOffset, streamType, flagType;
    NSMutableArray *tempMytableArray, *imagesArray, *timerArray, *likesArray,
    *flagsArray, *deleteArray, *labelsArray, *postedDateArray,
    *imageViewId;
    NSArray *streamResult;
    BOOL isRefreshing, canUpload, adSwitch;
    UIView *tmpView, *bgnView, *toolBarView;
    UIImage *tmpImage;
    NSString *streamCurrentDateTime, *sheetType, *pictureType;
    CALayer* globalLayer;
    int globalSender;
    BOOL viewIsHidden;
    CGFloat lastDirection;
    UIBarButtonItem *pictureAddItem;
    CALayer *maskLayer;
    UIButton *imageButton;
    PictureCountdownTimer *myAction;
    NSDateFormatter *DateFormatter;
}
@end

@implementation ProfileViewController
@synthesize progressView;
int hours, minutes, seconds, days;
int secondsLeft;
#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE
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
    [self PFregisterDeviceData];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    myAction = [[PictureCountdownTimer alloc]init];
    DateFormatter=[[NSDateFormatter alloc] init];
    
    UIScreenEdgePanGestureRecognizer *popRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopRecognizer:)];
    popRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:popRecognizer];
    
    //Mask image
    UIImage *mask = [UIImage imageNamed:@"maskCircle"];
    maskLayer = [CALayer layer];
    maskLayer.contents = (id)mask.CGImage;
    maskLayer.masksToBounds = YES;
    //END mask
    
    secondsLeft = 70;
    streamType = 0;
    NSUserDefaults *saveapp = [NSUserDefaults standardUserDefaults];
    if([saveapp objectForKey:settings] == NULL)
        NSLog(@"No settings");
    else
    {
        NSString *str = [NSString stringWithFormat:@"%@",[saveapp valueForKey:settings]];
        if([str isEqualToString:@"Most recent"])
            streamType = 0;
        else
            streamType = 1;
    }
    
    streamOffset = 0;
    canUpload = false;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reload) userInfo:nil repeats:YES];
    
    self.tableView.delegate = self;
    
    if (appDelegate.controllerView == 0)
    {
        UIBarButtonItem *sortItem = [[UIBarButtonItem alloc]initWithTitle:@"Sort" style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonPressed)];
        
        pictureAddItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(pictureAddButtonPressed)];
        
        NSArray *actionButtonItems = @[pictureAddItem];
        
        self.navigationItem.rightBarButtonItems = actionButtonItems;
        self.navigationItem.leftBarButtonItem = sortItem;
        
    }
    else if (appDelegate.controllerView == 1)
    {
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc]initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButton)];
        
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc]initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteProfile)];
        
        self.navigationItem.rightBarButtonItem = deleteButton;
        self.navigationItem.leftBarButtonItem = logoutButton;
    }
    
    
    //progress view
    progressView = [[UIProgressView alloc]init];
    progressView.hidden = YES;
    CGRect frame;
    if(INTERFACE_IS_PHONE)
        frame = CGRectMake(0, 43, 320, 1);
    else
        frame = CGRectMake(0, 43, iPadWidth, 2);
    progressView.frame = frame;
    progressView.backgroundColor = [UIColor grayColor];
    progressView.tintColor = [UIColor yellowColor];
    [self.navigationController.navigationBar addSubview:progressView];
    
    //    Refresh control
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    
    [refresh addTarget:self action:@selector(pullToRefresh)forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
    
    myAction = [[PictureCountdownTimer alloc]init];
    DateFormatter=[[NSDateFormatter alloc] init];
    
    tempMytableArray = [[NSMutableArray alloc]init];
    imagesArray = [[NSMutableArray alloc]init];
    timerArray = [[NSMutableArray alloc]init];
    likesArray = [[NSMutableArray alloc]init];
    flagsArray = [[NSMutableArray alloc]init];
    labelsArray = [[NSMutableArray alloc]init];
    deleteArray = [[NSMutableArray alloc]init];
    postedDateArray = [[NSMutableArray alloc]init];
    imageViewId = [[NSMutableArray alloc]init];
    
    for (NSInteger i = 0; i < 50; ++i)
    {
        [imagesArray addObject:[NSNull null]];
        [timerArray addObject:[NSNull null]];
        [likesArray addObject:[NSNull null]];
        [flagsArray addObject:[NSNull null]];
        [labelsArray addObject:[NSNull null]];
        [deleteArray addObject:[NSNull null]];
        [postedDateArray addObject:[NSNull null]];
        [imageViewId addObject:[NSNull null]];
    }
    
    [self pullToRefresh];
}
-(void)viewWillAppear:(BOOL)animated
{
    
    
}
-(void)viewDidAppear:(BOOL)animated
{
    // Set outself as the navigation controller's delegate so we're asked for a transitioning object
    self.navigationController.delegate = self;
    
}
- (void)methodToRepeatEveryOneSecond
{
    // Call this method again using GCD
    dispatch_queue_t q_background = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, q_background, ^(void){
        [self reload];
        [self methodToRepeatEveryOneSecond];
    });
}


- (void) viewWillDisappear:(BOOL)animated
{
    // Stop being the navigation controller's delegate
    if (self.navigationController.delegate == self) {
        self.navigationController.delegate = nil;
    }
}

- (void)sortButtonPressed
{
    //    [self loadInterstitial];
    sheetType = @"sort";
    [[[UIActionSheet alloc] initWithTitle:nil
                                 delegate:self
                        cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                   destructiveButtonTitle:nil
                        otherButtonTitles:NSLocalizedString(@"Most recent",nil), NSLocalizedString(@"Most life",nil), nil]
     showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button index %d",buttonIndex);
    if([sheetType isEqualToString:@"sort"])
    {
        switch (buttonIndex) {
            case 0:
            {
                
                isRefreshing = true;
                streamType = 0;
                
                [self pullToRefresh];
            }
                break;
            case 1:
            {
                isRefreshing = true;
                streamType = 1;
                
                [self pullToRefresh];
            }
                break;
            default:
                break;
        }
        
    }
    else if ([sheetType isEqualToString:@"flag"])
    {
        switch (buttonIndex) {
            case 0:
            {
                flagType = 0;
            }
                break;
            case 1:
            {
                flagType = 1;
            }
                break;
            case 2:
            {
                flagType = 2;
            }
                break;
            case 3:
            {
                flagType = 3;
            }
                break;
        }
        if(buttonIndex !=4)
            [self flagConfirmed];
        
        
    }
    else if ([sheetType isEqualToString:@"camera"])
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
    else if ([sheetType isEqualToString:@"deletePhoto"])
    {
        switch (buttonIndex) {
            case 0:
            {
                [self deleteConfirmed];
            }
                break;
            case 1:
            {
                
            }
                break;
        }
    }
    else if([sheetType isEqualToString:@"logout"])
    {
        switch (buttonIndex) {
            case 0:
            {
                [self logout];
                if (FBSession.activeSession.isOpen)
                {
                    [FBSession.activeSession closeAndClearTokenInformation];
                }
            }
        }
        
    }
    
    //    [self animate];
}

-(void)pictureAddButtonPressed
{
    NSLog(@"Picture Add");
    pictureType = @"post";
    
    sheetType = @"camera";
    [[[UIActionSheet alloc] initWithTitle:@"Upload picture from:"
                                 delegate:self
                        cancelButtonTitle:@"Cancel"
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"Camera", @"Camera Roll", nil]
     showInView:self.view];
    
}
-(void)pictureAdd:(NSInteger)type
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
#if TARGET_IPHONE_SIMULATOR
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.modalPresentationStyle = UIModalPresentationFormSheet;
    
#else
    if(type == 0)
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    else
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
#endif
    imagePickerController.editing = NO;
    imagePickerController.delegate = (id)self;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self canUpload:image];
}
-(void)publishButton:(id)sender
{
    //    self.tableView.userInteractionEnabled = YES;
    //    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
                             CGRect tmpFrame = CGRectMake((768/2)-(590/2)+100, -690, 390, 310);
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
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:0.5
                     animations:^{
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
    CGRect tmpFrame;//UIView
    CGRect tmpFrameImageView;
    CGRect tmpFrameButtonCancel;
    CGRect tmpFrameButtonPublish;
    CGRect tmpFrameLabel;
    CGRect tmpFrameTitleTextField;
    CGRect tmpNavigationBanner;
    
    if(INTERFACE_IS_PHONE)
    {
        if(isiPhone5)
        {
            tmpFrame = CGRectMake(15, -450, 290, 310);
            tmpNavigationBanner = CGRectMake(0, 0, 290, 50);
            tmpFrameImageView = CGRectMake(70, 60, 150, 150);
            tmpFrameButtonCancel = CGRectMake(10, 5, 70, 40);
            tmpFrameButtonPublish = CGRectMake(210, 5, 70, 40);
            tmpFrameLabel = CGRectMake(15, 280, 285, 80);
            tmpFrameTitleTextField = CGRectMake(20, 230, 250, 40);
        }
        else
        {
            tmpFrame = CGRectMake(15, -450, 290, 245);
            tmpNavigationBanner = CGRectMake(0, 0, 290, 40);
            tmpFrameImageView = CGRectMake(70, 45, 150, 150);
            tmpFrameButtonCancel = CGRectMake(10, 5, 70, 30);
            tmpFrameButtonPublish = CGRectMake(210, 5, 70, 30);
            tmpFrameLabel = CGRectMake(15, 250, 285, 80);
            tmpFrameTitleTextField = CGRectMake(20, 200, 250, 40);
            
        }
    }
    else
    {
        tmpFrame = CGRectMake((768/2)-(590/2)+100, -690, 390, 310);
        tmpNavigationBanner = CGRectMake(0, 0, 390, 50);
        tmpFrameImageView = CGRectMake(90, 60, 200, 200);
        tmpFrameButtonCancel = CGRectMake(10, 5, 70, 40);
        tmpFrameButtonPublish = CGRectMake(310, 5, 70, 40);
        tmpFrameLabel = CGRectMake(30, 250, 300, 40);
        tmpFrameTitleTextField = CGRectMake(45, 270, 300, 40);
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
        div = 1.0;
    
    CGSize size = CGSizeMake(image.size.width/div, image.size.height/div);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    tmpImageView.image = destImage;
    tmpImage = destImage;
    
    if([pictureType isEqualToString:@"profile"])
    {
        UIImage *maskImage = [UIImage imageNamed:@"maskCirclePreview.png"];
        tmpImageView.image = [self maskImage:destImage mask:maskImage];
    }
    
    UIButton *tmpButtonPublic = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    tmpButtonPublic.frame = tmpFrameButtonPublish;
    [tmpButtonPublic setTitle:NSLocalizedString(@"Post", nil) forState:UIControlStateNormal];
    [tmpButtonPublic addTarget:self action:@selector(publishButton:) forControlEvents:UIControlEventTouchUpInside];
    tmpButtonPublic.backgroundColor = [UIColor greenColor];
    [tmpButtonPublic setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tmpButtonPublic.layer setMasksToBounds:YES];
    [tmpButtonPublic.layer setCornerRadius:8];
    
    UIButton *tmpButtonCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    tmpButtonCancel.frame = tmpFrameButtonCancel;
    [tmpButtonCancel setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    
    [tmpButtonCancel addTarget:self action:@selector(cancelButton:) forControlEvents:UIControlEventTouchUpInside];
    tmpButtonCancel.backgroundColor = [UIColor lightGrayColor];
    [tmpButtonCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tmpButtonCancel.layer setMasksToBounds:YES];
    [tmpButtonCancel.layer setCornerRadius:8];
    
    //Title TextField
    if(![pictureType isEqualToString:@"profile"])
    {
        _titleTextField = [[UITextField alloc]initWithFrame:tmpFrameTitleTextField];
        _titleTextField.delegate = self;
        _titleTextField.layer.borderColor = [[UIColor redColor]CGColor];
        _titleTextField.layer.borderWidth= 1.0f;
        [_titleTextField.layer setCornerRadius:8];
        [_titleTextField.layer setMasksToBounds:YES];
        [_titleTextField becomeFirstResponder];
        [_titleTextField setTextAlignment:NSTextAlignmentCenter];
        _titleTextField.placeholder = NSLocalizedString(@"Picture title",nil);
    }
    //Navigation Bar
    UIView *navView = [[UIView alloc]initWithFrame:tmpNavigationBanner];
    navView.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(105/255.0) blue:(100/255.0) alpha:1];
    
    
    //Label
    UILabel *tmpLabel = [[UILabel alloc]initWithFrame:tmpFrameLabel];
    if([pictureType isEqualToString:@"post"])
        tmpLabel.text = NSLocalizedString(@"Enter picture title:", nil);
    else
        tmpLabel.text = NSLocalizedString(@"Profile picture will be seen by everyone", nil);
    
    if(INTERFACE_IS_PAD)
        tmpLabel.textAlignment = NSTextAlignmentLeft;
    tmpLabel.lineBreakMode = YES;
    tmpLabel.numberOfLines = 0;
    
    [tmpView addSubview:navView];
    [tmpView addSubview:tmpImageView];
    [tmpView addSubview:tmpButtonCancel];
    [tmpView addSubview:tmpButtonPublic];
    if(![pictureType isEqualToString:@"profile"])
        [tmpView addSubview:_titleTextField];
    
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
                             CGRect tmpFrame = CGRectMake(15, 40, 290, 310);
                             if(!isiPhone5)
                                 tmpFrame = CGRectMake(15, 20, 290, 245);
                             
                             tmpView.frame = tmpFrame;
                         }
                         else
                         {
                             CGRect tmpFrame = CGRectMake((768/2)-(590/2)+100, 300, 390, 350);
                             tmpView.frame = tmpFrame;
                         }
                         
                         
                     }
                     completion:^(BOOL finished){
                         
                         
                     }
     ];
}
- (UIImage*) maskImage:(UIImage *)image mask:(UIImage*)maskImage {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
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
    
    transform = CATransform3DRotate(transform,  180.0f * M_PI / 180.0f, 1.0f, 1.0f, 0.0f);
    transform = CATransform3DRotate(transform,  180.0f * M_PI / 180.0f, 0.0f, 0.0f, 1.0f);
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage {
    
    CGImageRef maskRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    return [UIImage imageWithCGImage:masked];
}

-(void)uploadSelectedPicture:(UIImage*)image
{
    pictureAddItem.enabled = NO;
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
    if([pictureType isEqualToString:@"profile"])
    {
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
        imageButton.imageView.image = imageMasked;
    }
    else
    {
        NSLog(@"Width size %f",image.size.width);
        
        // Resize the image from the camera
        scaledImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(widthHeight, widthHeight) interpolationQuality:kCGInterpolationHigh];
        // Crop the image to a square
        croppedImage = [scaledImage croppedImage:CGRectMake((scaledImage.size.width -widthHeight)/2, (scaledImage.size.height -widthHeight)/2, widthHeight, widthHeight)];
        
        imageToUpload = UIImageJPEGRepresentation(croppedImage,0.5);
        if([imageToUpload length] >= 1048576)
        {
            imageToUpload = UIImageJPEGRepresentation(croppedImage,0.0);
        }
    }
    
    NSString* command;
    if([pictureType isEqualToString:@"post"])
        command = @"upload";
    else
        command = @"uploadProfilePicture";
    
    NSMutableDictionary* params;
    
    if([pictureType isEqualToString:@"profile"])
    {
        params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                 command, @"command",
                 nil];
    }
    else
    {
        NSString *str = [NSString stringWithFormat:@"%@",_titleTextField.text];
        params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                 command, @"command",
                 str, @"title",
                 nil];
    }
    
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
                                         pictureAddItem.enabled = YES;
                                         [self pullToRefresh];
                                     }
     
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Failure %@", error.description);
                                         progressView.hidden = YES;
                                         UIAlertView *alert = [[UIAlertView alloc]initWithTitle: NSLocalizedString(@"Upload failed",nil) message: NSLocalizedString(@"Network problem.", nil) delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                         
                                         [alert show];
                                         pictureAddItem.enabled = YES;
                                     }];
    // 4. Set the progress block of the operation.
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                       long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite ) {
        float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            progressView.progress = progress;
            NSLog(@"Progress %f",progress);
            if(progress == 1.0)
            {
                progressView.hidden = YES;
                [self.tableView reloadData];
            }
        });
    }];
    
    // 5. Begin!
    [operation start];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = [tempMytableArray count];
    if(appDelegate.controllerView == 1)
        count = [tempMytableArray count]+1;
    return count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height;
    
    if(indexPath.row == 0 && appDelegate.controllerView == 1)
    {
        if(INTERFACE_IS_PHONE)
            height = 120;
        else
            height = 150;
    }
    else
    {
        if(INTERFACE_IS_PHONE)
            height = 433;
        else
            height = 877;
    }
    
    return height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell index: %ld",(long)indexPath.row);
    
    int index = indexPath.row;
    
    static NSString *kTableViewCellIdentifier = @"Cell";
    
    MainCell *cell = (MainCell*)[tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if(indexPath.row == 0 && appDelegate.controllerView == 1)
    {
        UITableViewCell *profileCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"profileCell"];
        
        [self getProfilePicture:profileCell];
        cell.hidden = YES;
        int width = 320;
        if(INTERFACE_IS_PAD)
            width = iPadWidth;
        
        CGRect cellFrame = CGRectMake(0, 0, width, 100);
        if(INTERFACE_IS_PAD)
            cellFrame = CGRectMake(0, 0, width, 100);
        cell.frame = cellFrame;
        return profileCell;
    }
    
    if(indexPath.row >0 &&appDelegate.controllerView == 1)
        index--;
    if(!isRefreshing && tempMytableArray.count> index)
    {
        //    reload offset
        int tmpCount = streamOffset+47;
        NSNumber *tempCount2 = [NSNumber numberWithInt:index];
        if(index >= [tempMytableArray count]-3 && tempCount2.intValue >= (int)tmpCount)
        {
            streamOffset = streamOffset +50;
            for (NSInteger i = 0; i < 50; ++i)
            {
                [imagesArray addObject:[NSNull null]];
                [timerArray addObject:[NSNull null]];
                [likesArray addObject:[NSNull null]];
                [flagsArray addObject:[NSNull null]];
                [labelsArray addObject:[NSNull null]];
                [deleteArray addObject:[NSNull null]];
                [postedDateArray addObject:[NSNull null]];
                [imageViewId  addObject:[NSNull null]];
            }
            [self refreshStream];
        }
        
        if([imagesArray objectAtIndex:index] == [NSNull null] || (indexPath.row >0 && appDelegate.controllerView ==1))
        {
            currentCell++;
            NSDictionary* dictionary = [tempMytableArray objectAtIndex:index];
            
            UIImageView *imageViewMain = (UIImageView *)[cell viewWithTag:1];
            imageViewMain.image = nil;
            imageViewMain.userInteractionEnabled = YES;
            
            NSString *tmpNameString = [NSString stringWithFormat:@"%d",indexPath.row];
            cell.imageViewMain.layer.name = tmpNameString;
            
            
            UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainImageTapped:)];
            tapped.numberOfTapsRequired = 1;
            
            //Get Image from server
            NSString *imageUrl = [NSString stringWithFormat:@"%@/%@/%@/%@.jpg", kAPIHost, kAPIPath,@"upload",[dictionary objectForKey:@"IdPhoto"]];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Successfully downloaded");
                
                if(imagesArray.count> index && responseObject != nil)
                    [imagesArray replaceObjectAtIndex:index withObject:[UIImage imageWithData:responseObject]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // do stuff with image
                    imageViewMain.image = [UIImage imageWithData:responseObject];
                });
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            
            [operation start];
            
            
            //    Get firstname, lastname
            NSString *tmpString = [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"firstName"],[dictionary objectForKey:@"lastName"]];
            UILabel *fullName =(UILabel *)[cell viewWithTag:2];
            fullName.text = tmpString;
            
            //  Date
            NSString *dateStr = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"transactionDateTime"]];
            [DateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *datePosted = [DateFormatter dateFromString:dateStr];
            NSDate *currentDate = [DateFormatter dateFromString:streamCurrentDateTime];
            //            Diference
            NSTimeInterval diff = [datePosted timeIntervalSinceDate:currentDate];
            NSLog(@"Date life: %@ current: %@",datePosted, currentDate);
            NSLog(@"Date diff: %f",diff);
            NSNumber *tmpTime = [NSNumber numberWithLong:diff];
            if(diff <= 0.0)
                tmpTime = [NSNumber numberWithInt:0];
            
            long secondIncrease = (long)diff;
            NSNumber *number = [NSNumber numberWithLong:labs(secondIncrease)];
            [postedDateArray replaceObjectAtIndex:index withObject:number];
            tmpString = [myAction timeCounterString:labs(secondIncrease)];
            
            UILabel *dateLabel =(UILabel *)[cell viewWithTag:11];
            
            dateLabel.text = tmpString;
            
            
            // Get likes
            tmpString = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"likes"]];
            NSNumberFormatter *tmpFormater = [NSNumberFormatter new];
            [tmpFormater setNumberStyle:NSNumberFormatterDecimalStyle];
            
            tmpString = [tmpFormater stringFromNumber:[NSNumber numberWithInteger:tmpString.intValue]];
            UILabel *tmpLabel =(UILabel *)[cell viewWithTag:6];
            UILabel *likesLabel = tmpLabel;
            tmpLabel.text = tmpString;
            
            
            //  Timer
            tmpString = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"life"]];
            
            
            [DateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *dateLife = [DateFormatter dateFromString:tmpString];
            
            //            Diference
            diff = [dateLife timeIntervalSinceDate:currentDate];
            NSLog(@"Date life: %@ current: %@",dateLife, currentDate);
            NSLog(@"Date diff: %f",diff);
            tmpTime = [NSNumber numberWithLong:diff];
            if(diff <= 0.0)
                tmpTime = [NSNumber numberWithInt:0];
            [timerArray replaceObjectAtIndex:index withObject:tmpTime];
            
            tmpString = [myAction timeRemainingString:(long)diff];
            tmpLabel =(UILabel *)[cell viewWithTag:4];
            
            //Labels
            NSArray *tmpArray = @[likesLabel,tmpLabel,dateLabel];//likes timer
            [labelsArray replaceObjectAtIndex:index withObject:tmpArray];
            
            tmpLabel.text = tmpString;
            if(diff <= 0.0)
                tmpLabel.text = @"0";
            
            //Picture title
            UILabel *tilteLabel = (UILabel *)[cell viewWithTag:14];
            if([[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"title"]] isEqualToString:@""] ||[dictionary objectForKey:@"title"] == [NSNull null])
            {
                
            }
            else
            {
                tilteLabel.text = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"title"]];
                tilteLabel.hidden = NO;
                
            }
            
            // Liked
            UIButton *likedButton;
            UIButton *flagButton;
            likedButton =(UIButton *)[cell viewWithTag:9];
            
            [likesArray replaceObjectAtIndex:index withObject:likedButton];
            
            //Flag button
            flagButton =(UIButton *)[cell viewWithTag:10];
            [flagsArray replaceObjectAtIndex:index withObject:flagButton];
            
            NSString *liked = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"liked"]];
            if([liked isEqualToString:@"0"])
            {
                
                NSString *flagged = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"flagged"]];
                if([flagged isEqualToString:@"0"])
                {
                    //flagged
                    flagButton.hidden = NO;
                    flagButton.enabled = YES;
                    [flagButton setImage:[UIImage imageNamed:@"flagNormal"]  forState:UIControlStateNormal];
                    
                    //liked
                    likedButton.hidden = NO;
                    likedButton.enabled = YES;
                    [likedButton setImage:[UIImage imageNamed:@"plusNormal"]  forState:UIControlStateNormal];
                }
                else
                {
                    [flagButton setImage:[UIImage imageNamed:@"flagPressed"]  forState:UIControlStateNormal];
                    flagButton.enabled = NO;
                    flagButton.hidden = NO;
                    likedButton.hidden = YES;
                }
            }
            else
            {
                //Plus 1 (+1) pressed
                [likedButton setImage:[UIImage imageNamed:@"plusPressed"]  forState:UIControlStateNormal];
                likedButton.enabled = NO;
                likedButton.hidden = NO;
                flagButton.hidden = YES;
                //unlike
                
            }
            
            // Delete
            NSString *udid = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"IdUser"]];
            
            // Delete Button
            //Delete button
            UIButton *deleteButton =(UIButton *)[cell viewWithTag:13];
            deleteButton.hidden = YES;
            NSInteger udidInt = udid.integerValue;
            if(appDelegate.udid ==udidInt)
            {
                //Liked button
                likedButton.hidden = YES;
                
                //Flag button
                flagButton.hidden = YES;
                
                //Delete button
                deleteButton.hidden = NO;
                deleteButton.enabled = YES;
                
                [deleteArray replaceObjectAtIndex:index withObject:deleteButton];
            }
            
            // Profile picture
            UIImageView *imageViewProfile = (UIImageView*)[cell viewWithTag:12];
            
            [self getPrifilePicture:imageViewProfile userId:udid.integerValue];
            
            //Comment count label(button)
            UIButton *commentCountButton = (UIButton*)[cell viewWithTag:15];
            
            NSString *idPhoto = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"IdPhoto"]];
            
            NSString* command = @"commentsCount";
            
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           command, @"command",
                                           idPhoto, @"IdPhoto",
                                           nil];
            
            NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSArray *response = [responseObject allKeys];
                if(response.count >0)
                {
                    
                    NSLog(@"Response count %lu",(unsigned long)response.count);
                    if(![[response objectAtIndex:0] isEqual: @"error"])
                    {
                        NSLog(@"Response stream %@",responseObject);
                        NSLog(@"Response success");
                        
                        NSString *count = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"nr"]];
                        [commentCountButton setTitle:count forState:UIControlStateNormal];
                        NSLog(@"Respond stream comments count: %@",count);
                        
                    }
                    else
                    {
                        NSLog(@"Error: Authorization failed");
                    }
                    
                    
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            //Comments count END
        }
        else
        {
            //UIImage from chache
            if(imagesArray.count> index)
            {
                if([imagesArray objectAtIndex:index] != [NSNull null])
                {
                    // do stuff with image
                    UIImageView *imageViewMain = (UIImageView *)[cell viewWithTag:1];
                    imageViewMain.image = nil;
                    UIImage *getImage = [imagesArray objectAtIndex:index];
                    imageViewMain.image = getImage;
                    
                    
                    NSDictionary* dictionary = [tempMytableArray objectAtIndex:index];
                    //    Get firstname, lastname
                    NSString *tmpString = [NSString stringWithFormat:@"%@ %@",[dictionary objectForKey:@"firstName"],[dictionary objectForKey:@"lastName"]];
                    UILabel *tmpLabel =(UILabel *)[cell viewWithTag:2];
                    tmpLabel.text = tmpString;
                    
                    tmpLabel =(UILabel *)[cell viewWithTag:11];
                    NSString *dateString = [NSString stringWithFormat:@"%@",[postedDateArray objectAtIndex:index]];
                    NSInteger dateCount = dateString.integerValue;
                    dateCount++;
                    NSNumber *number = [NSNumber numberWithInteger:dateCount];
                    [postedDateArray replaceObjectAtIndex:index withObject:number];
                    tmpString = [myAction timeCounterString:dateCount];
                    tmpLabel.text = tmpString;
                    
                    // Get likes
                    tmpString = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"likes"]];
                    NSNumberFormatter *tmpFormater = [NSNumberFormatter new];
                    [tmpFormater setNumberStyle:NSNumberFormatterDecimalStyle];
                    
                    tmpString = [tmpFormater stringFromNumber:[NSNumber numberWithInteger:tmpString.intValue]];
                    tmpLabel =(UILabel *)[cell viewWithTag:6];
                    tmpLabel.text = tmpString;
                    
                    //  Timer
                    if ([timerArray objectAtIndex:index]!= [NSNull null])
                    {
                        NSNumber *tmpNumber = [timerArray objectAtIndex:index];
                        long tmpInteger = [tmpNumber longValue];
                        NSLog(@"timer %ld",tmpInteger);
                        tmpString = [myAction timeRemainingString:tmpInteger];
                        NSLog(@"timer str %ld",tmpInteger);
                        tmpLabel =(UILabel *)[cell viewWithTag:4];
                        tmpLabel.text = tmpString;
                        if(tmpInteger <= 0.0)
                            tmpLabel.text = @"0";
                    }
                    else
                        tmpLabel.text = @"0";
                    
                    //Picture title
                    UILabel *tilteLabel = (UILabel *)[cell viewWithTag:14];
                    if([[NSString stringWithFormat:@"%@",[dictionary objectForKey:@"title"]] isEqualToString:@""] ||[dictionary objectForKey:@"title"] == [NSNull null])
                    {
                        
                    }
                    else
                    {
                        tilteLabel.text = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"title"]];
                        tilteLabel.hidden = NO;
                        
                    }
                    
                    //  Liked
                    UIButton *likedButton;
                    UIButton *flagButton;
                    NSString *liked = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"liked"]];
                    
                    likedButton =(UIButton *)[cell viewWithTag:9];
                    flagButton =(UIButton *)[cell viewWithTag:10];
                    if([liked isEqualToString:@"0"])
                    {
                        
                        
                        // Flags
                        NSString *flagged = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"flagged"]];
                        if([flagged isEqualToString:@"0"])
                        {
                            //flagged
                            flagButton.hidden = NO;
                            flagButton.enabled = YES;
                            [flagButton setImage:[UIImage imageNamed:@"flagNormal"]  forState:UIControlStateNormal];
                            
                            //liked
                            likedButton.hidden = NO;
                            likedButton.enabled = YES;
                            [likedButton setImage:[UIImage imageNamed:@"plusNormal"]  forState:UIControlStateNormal];
                        }
                        else
                        {
                            [flagButton setImage:[UIImage imageNamed:@"flagPressed"]  forState:UIControlStateNormal];
                            flagButton.enabled = NO;
                            flagButton.hidden = NO;
                            
                            
                            likedButton.hidden = YES;
                            
                        }
                    }
                    else
                    {
                        [likedButton setImage:[UIImage imageNamed:@"plusPressed"]  forState:UIControlStateNormal];
                        likedButton.enabled = NO;
                        likedButton.hidden = NO;
                        flagButton.hidden = YES;
                    }
                    
                    // Delete Button
                    NSString *udid = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"IdUser"]];
                    
                    UIButton *deleteButton =(UIButton *)[cell viewWithTag:13];
                    deleteButton.hidden = YES;
                    NSInteger udidInt = udid.integerValue;
                    if(appDelegate.udid == udidInt)
                    {
                        //Liked button
                        likedButton.hidden = YES;
                        
                        //Flag button
                        flagButton.hidden = YES;
                        deleteButton.hidden = NO;
                        deleteButton.enabled = YES;
                        
                        
                    }
                    // Profile picture
                    UIImageView *imageViewProfile = (UIImageView*)[cell viewWithTag:12];
                    
                    [self getPrifilePicture:imageViewProfile userId:udid.integerValue];
                    
                    //Comment count label(button)
                    UIButton *commentCountButton = (UIButton*)[cell viewWithTag:15];
                    
                    NSString *idPhoto = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"IdPhoto"]];
                    
                    NSString* command = @"commentsCount";
                    
                    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   command, @"command",
                                                   idPhoto, @"IdPhoto",
                                                   nil];
                    
                    NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
                    
                    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                    [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        
                        
                        
                        NSArray *response = [responseObject allKeys];
                        if(response.count >0)
                        {
                            
                            NSLog(@"Response count %lu",(unsigned long)response.count);
                            if(![[response objectAtIndex:0] isEqual: @"error"])
                            {
                                NSLog(@"Response stream %@",responseObject);
                                NSLog(@"Response success");
                                
                                
                                NSString *count = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"nr"]];
                                [commentCountButton setTitle:count forState:UIControlStateNormal];
                                NSLog(@"Respond stream comments count: %@",count);
                                
                            }
                            else
                            {
                                NSLog(@"Error: Authorization failed");
                            }
                            
                        }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Error: %@", error);
                    }];
                    //Comments count END
                }
            }
            
        }
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 && appDelegate.controllerView == 1)
        cell.backgroundColor = [UIColor whiteColor];
    else
        cell.backgroundColor = [UIColor colorWithRed:224.0f/255.0f green:224/255.0f blue:224/255.0f alpha:1.0];
}
-(void)reload
{
    for(NSInteger i = 0;i<[timerArray count];i++ )
    {
        if([timerArray objectAtIndex:i] != [NSNull null])
        {
            NSNumber *tmpNumber = [timerArray objectAtIndex:i];
            long tmpInteger = [tmpNumber longValue];
            tmpInteger = tmpInteger-1;
            tmpNumber = [NSNumber numberWithLong:tmpInteger];
            [timerArray replaceObjectAtIndex:i withObject:tmpNumber];
            
            UILabel *likesLabel = labelsArray[i][0];
            UILabel *timerLabel =labelsArray[i][1];
            
            NSString *str = [myAction timeRemainingString:tmpInteger];
            timerLabel.text = str;
            
            //Date
            tmpNumber = [postedDateArray objectAtIndex:i];
            tmpInteger = [tmpNumber longValue];
            tmpInteger++;
            tmpNumber = [NSNumber numberWithLong:tmpInteger];
            [postedDateArray replaceObjectAtIndex:i withObject:tmpNumber];
            
            UILabel *dateLabel = labelsArray[i][2];
            
            str = [myAction timeCounterString:tmpInteger];
            dateLabel.text = str;
            
            NSArray *array = @[likesLabel,timerLabel,dateLabel];
            
            [labelsArray replaceObjectAtIndex:i withObject:array];
            
        }
        
    }
}


//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return toolBarView;
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    int height = 722;
//    if(appDelegate.controllerView == 0)
//    {
//        if(INTERFACE_IS_PHONE)
//            height = 60;
//
//    }
//    return height;
//}

// CropRect is assumed to be in UIImageOrientationUp, as it is delivered this way from the UIImagePickerController when using AllowsImageEditing is on.
// The sourceImage can be in any orientation, the crop will be transformed to match
// The output image bounds define the final size of the image, the image will be scaled to fit,(AspectFit) the bounds, the fill color will be
// used for areas that are not covered by the scaled image.
-(UIImage *)cropImage:(UIImage *)sourceImage cropRect:(CGRect)cropRect aspectFitBounds:(CGSize)finalImageSize fillColor:(UIColor *)fillColor {
    
    CGImageRef sourceImageRef = sourceImage.CGImage;
    
    //Since the crop rect is in UIImageOrientationUp we need to transform it to match the source image.
    CGAffineTransform rectTransform = [self transformSize:sourceImage.size orientation:sourceImage.imageOrientation];
    CGRect transformedRect = CGRectApplyAffineTransform(cropRect, rectTransform);
    
    //Now we get just the region of the source image that we are interested in.
    CGImageRef cropRectImage = CGImageCreateWithImageInRect(sourceImageRef, transformedRect);
    
    //Figure out which dimension fits within our final size and calculate the aspect correct rect that will fit in our new bounds
    CGFloat horizontalRatio = finalImageSize.width / CGImageGetWidth(cropRectImage);
    CGFloat verticalRatio = finalImageSize.height / CGImageGetHeight(cropRectImage);
    CGFloat ratio = MIN(horizontalRatio, verticalRatio); //Aspect Fit
    CGSize aspectFitSize = CGSizeMake(CGImageGetWidth(cropRectImage) * ratio, CGImageGetHeight(cropRectImage) * ratio);
    
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 finalImageSize.width,
                                                 finalImageSize.height,
                                                 CGImageGetBitsPerComponent(cropRectImage),
                                                 0,
                                                 CGImageGetColorSpace(cropRectImage),
                                                 CGImageGetBitmapInfo(cropRectImage));
    
    if (context == NULL) {
        NSLog(@"NULL CONTEXT!");
    }
    
    //Fill with our background color
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, finalImageSize.width, finalImageSize.height));
    
    //We need to rotate and transform the context based on the orientation of the source image.
    CGAffineTransform contextTransform = [self transformSize:finalImageSize orientation:sourceImage.imageOrientation];
    CGContextConcatCTM(context, contextTransform);
    
    //Give the context a hint that we want high quality during the scale
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    //Draw our image centered vertically and horizontally in our context.
    CGContextDrawImage(context, CGRectMake((finalImageSize.width-aspectFitSize.width)/2, (finalImageSize.height-aspectFitSize.height)/2, aspectFitSize.width, aspectFitSize.height), cropRectImage);
    
    //Start cleaning up..
    CGImageRelease(cropRectImage);
    
    CGImageRef finalImageRef = CGBitmapContextCreateImage(context);
    UIImage *finalImage = [UIImage imageWithCGImage:finalImageRef];
    
    CGContextRelease(context);
    CGImageRelease(finalImageRef);
    return finalImage;
}

//Creates a transform that will correctly rotate and translate for the passed orientation.
//Based on code from niftyBean.com
- (CGAffineTransform) transformSize:(CGSize)imageSize orientation:(UIImageOrientation)orientation {
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (orientation) {
        case UIImageOrientationLeft: { // EXIF #8
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,M_PI_2);
            transform = txCompound;
            break;
        }
        case UIImageOrientationDown: { // EXIF #3
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,M_PI);
            transform = txCompound;
            break;
        }
        case UIImageOrientationRight: { // EXIF #6
            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,-M_PI_2);
            transform = txCompound;
            break;
        }
        case UIImageOrientationUp: // EXIF #1 - do nothing
        default: // EXIF 2,4,5,7 - ignore
            break;
    }
    return transform;
    
}

-(id)initWithIndex:(int)i andData:(NSDictionary*)data {
    self = [super init];
    if (self !=nil) {
        
    }
    return self;
}


#pragma mark-Stream
-(void)canUpload:(UIImage*)image
{
    
    NSString* command = @"canUpload";
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSMutableDictionary* params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  command, @"command",
                                  nil];
    NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        
        NSArray *response = [responseObject allKeys];
        if(response.count >0)
        {
            
            NSLog(@"Response %@",responseObject);
            if(![[response objectAtIndex:0] isEqual: @"error"])
            {
                canUpload = true;
                if(canUpload)
                {
                    [self uploadPreview:image];
                    
                }
                else
                {
                    NSString *msg = [NSString stringWithFormat:@"You have to wait to upload more pictures"];
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Alert" message: msg delegate: self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    
                    [alert show];
                }
                
                
            }
            else
            {
                NSLog(@"Error: Cannot upload");
                canUpload = false;
            }
            
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

-(void)pullToRefresh
{
    streamOffset = 0;
    currentCell = 0;
    //remove all objects from mutable array*******
    [tempMytableArray removeAllObjects];
    [imagesArray removeAllObjects];
    [timerArray removeAllObjects];
    [likesArray removeAllObjects];
    [flagsArray removeAllObjects];
    [labelsArray removeAllObjects];
    [deleteArray removeAllObjects];
    [postedDateArray removeAllObjects];
    [imageViewId removeAllObjects];
    for (NSInteger i = 0; i < 50; ++i)
    {
        [imagesArray addObject:[NSNull null]];
        [timerArray addObject:[NSNull null]];
        [likesArray addObject:[NSNull null]];
        [flagsArray addObject:[NSNull null]];
        [labelsArray addObject:[NSNull null]];
        [deleteArray addObject:[NSNull null]];
        [postedDateArray addObject:[NSNull null]];
        [imageViewId  addObject:[NSNull null]];
    }
    isRefreshing = true;
    [self refreshStream];
}
#pragma  mark-Stream
-(void)refreshStream {
    //just call the "stream" command from the web API
    timer =nil;
    
    NSString* command = @"stream";
    if(appDelegate.controllerView == 1)
        command = @"streamMyUploads";
    NSString* tmpStreamType = [NSString stringWithFormat:@"%ld",(long)streamType];
    NSString* tmpOffset = [NSString stringWithFormat:@"%ld",(long)streamOffset];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   command, @"command",
                                   tmpStreamType, @"streamType",
                                   tmpOffset, @"offset",
                                   nil];
    
    NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        NSArray *response = [responseObject allKeys];
        if(response.count >0)
        {
            
            NSLog(@"Response count %lu",(unsigned long)response.count);
            if(![[response objectAtIndex:0] isEqual: @"error"])
            {
                NSLog(@"Response success");
                
                
                [tempMytableArray addObjectsFromArray:[responseObject objectForKey:@"result"]];
                
                NSLog(@"Respond stream: %@",tempMytableArray);
                [self getCurrentDateTime];
                isRefreshing = false;
            }
            else
            {
                NSLog(@"Error: Authorization failed");
                [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
            }
            
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self refreshStream];
        
    }];
    
    
}

-(void)getCurrentDateTime
{
    NSString* command = @"dateTime";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   command, @"command",
                                   nil];
    NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *response = [responseObject allKeys];
        if(response.count >0)
        {
            
            NSLog(@"Response count %lu",(unsigned long)response.count);
            if(![[response objectAtIndex:0] isEqual: @"error"])
            {
                NSLog(@"Response stream %@",responseObject);
                streamCurrentDateTime = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"dateTime"]];
                NSLog(@"Respond currentDateTime: %@",streamCurrentDateTime);
                [self.tableView reloadData];
                [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
                
                
                
            }
            else
            {
                NSLog(@"Error: Authorization failed");
                [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
            }
            
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:2.0];
        
    }];
}
- (void)stopRefresh
{
    [self.refreshControl endRefreshing];
}


#pragma mark-Buttons
- (void)likeButtonTappedOnCell:(id)sender {
    NSIndexPath *indepath = [self.tableView indexPathForCell:sender];
    
    NSLog(@"cell %i", indepath.row);
    int i = indepath.row;
    {
        
        NSDictionary* dictionary = [tempMytableArray objectAtIndex:i];
        NSString *liked = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"liked"]];
        if([liked isEqualToString:@"0"])
        {
            NSString *idPhoto = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"IdPhoto"]];
            NSLog(@"Button %@",idPhoto);
            
            UIButton *tmpButton = likesArray[i];
            tmpButton.enabled = NO;
            [tmpButton setImage:[UIImage imageNamed:@"plusPressed"]  forState:UIControlStateNormal];
            
            
            //Update likes
            NSString *tmpString = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"likes"]];
            NSNumberFormatter *tmpFormater = [NSNumberFormatter new];
            [tmpFormater setNumberStyle:NSNumberFormatterDecimalStyle];
            NSInteger tmpInt = tmpString.integerValue+1;
            NSNumber *number = [NSNumber numberWithInteger:tmpInt];
            UILabel *label = labelsArray[i][0];
            label.text = [NSString stringWithFormat:@"%@",number];
            
            
            //Update Like Button
            NSNumber *likedButton = [NSNumber numberWithInteger:1];//= (long)[dictionary objectForKey:@"liked"];
            
            
            NSMutableDictionary *mutDict = [[NSMutableDictionary alloc]init];
            [mutDict setValuesForKeysWithDictionary:dictionary];
            [mutDict setObject:number forKey:@"likes"];
            [mutDict setObject:likedButton forKey:@"liked"];
            tempMytableArray[i] = mutDict;
            
            //            Update Flag Button
            tmpButton = flagsArray[i];
            tmpButton.hidden = YES;
            
            
            //Get amount of time to be added
            NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
            NSString* command = @"amountOfLife";
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           command, @"command",
                                           nil];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSArray *response = [responseObject allKeys];
                if(response.count >0)
                {
                    
                    NSLog(@"Response count %lu",(unsigned long)response.count);
                    if(![[response objectAtIndex:0] isEqual: @"error"])
                    {
                        NSLog(@"Response like %@",responseObject);
                        //Update Timer
                        NSString *secondsStr = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"seconds"]];
                        long tmpSeconds = secondsStr.integerValue;
                        NSNumber *tmpNumber = [timerArray objectAtIndex:i];
                        long tmpInteger = [tmpNumber longValue] ;
                        tmpInteger = tmpInteger+tmpSeconds;
                        tmpNumber = [NSNumber numberWithLong:tmpInteger];
                        [timerArray replaceObjectAtIndex:i withObject:tmpNumber];
                        
                        [self incrementLikes:idPhoto];
                        
                        
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
        else
        {
            
        }
        
    }
    
}
- (void)flagButtonTappedOnCell:(id)sender {
    NSIndexPath *indepath = [self.tableView indexPathForCell:sender];
    
    NSLog(@"cell %i", indepath.row);
    
    globalSender = indepath.row;
    sheetType = @"flag";
    [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"What is the issue?",nil)
                                 delegate:self
                        cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                   destructiveButtonTitle:nil
                        otherButtonTitles:NSLocalizedString(@"Sexual content",nil), NSLocalizedString(@"Violent or repulsive content",nil), NSLocalizedString(@"Child Abuse",nil), NSLocalizedString(@"Hateful or abusive content",nil), nil]
     showInView:self.view];
    
}
- (void)deleteButtonTappedOnCell:(id)sender {
    NSIndexPath *indepath = [self.tableView indexPathForCell:sender];
    
    NSLog(@"cell %@", indepath);
    globalSender = indepath.row;
    
    NSLog(@"Delete Button pressed");
    sheetType = @"deletePhoto";
    [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Delete photo",nil)
                                 delegate:self
                        cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                   destructiveButtonTitle:NSLocalizedString(@"Delete",nil)
                        otherButtonTitles:nil]
     showInView:self.view];
    
}

-(void)likePressed:(id)sender
{
    
    
    NSLog(@"Like Button pressed");
    NSString *idPhoto;
    
    for(int i = 0;i<likesArray.count;i++)
    {
        
        if(likesArray[i] == (UIButton*)sender)
        {
            NSDictionary* dictionary = [tempMytableArray objectAtIndex:i];
            idPhoto = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"IdPhoto"]];
            NSLog(@"Button %@",idPhoto);
            
            UIButton *tmpButton = (UIButton*)sender;
            tmpButton.enabled = NO;
            [tmpButton setImage:[UIImage imageNamed:@"plusPressed"]  forState:UIControlStateNormal];
            
            
            //Update likes
            NSString *tmpString = [NSString stringWithFormat:@"%@",[dictionary objectForKey:@"likes"]];
            NSNumberFormatter *tmpFormater = [NSNumberFormatter new];
            [tmpFormater setNumberStyle:NSNumberFormatterDecimalStyle];
            NSInteger tmpInt = tmpString.integerValue+1;
            NSNumber *number = [NSNumber numberWithInteger:tmpInt];
            
            
            
            //Update Like Button
            NSNumber *likedButton = [NSNumber numberWithInteger:1];//= (long)[dictionary objectForKey:@"liked"];
            
            
            NSMutableDictionary *mutDict = [[NSMutableDictionary alloc]init];
            [mutDict setValuesForKeysWithDictionary:dictionary];
            [mutDict setObject:number forKey:@"likes"];
            [mutDict setObject:likedButton forKey:@"liked"];
            tempMytableArray[i] = mutDict;
            
            //            Update Flag Button
            tmpButton = flagsArray[i];
            tmpButton.hidden = YES;
            
            
            //Get amount of time to be added
            NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
            NSString* command = @"amountOfLife";
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           command, @"command",
                                           nil];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSArray *response = [responseObject allKeys];
                if(response.count >0)
                {
                    
                    NSLog(@"Response count %lu",(unsigned long)response.count);
                    if(![[response objectAtIndex:0] isEqual: @"error"])
                    {
                        NSLog(@"Response like %@",responseObject);
                        //Update Timer
                        NSString *secondsStr = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"seconds"]];
                        long tmpSeconds = secondsStr.integerValue;
                        NSNumber *tmpNumber = [timerArray objectAtIndex:i];
                        long tmpInteger = [tmpNumber longValue] ;
                        tmpInteger = tmpInteger+tmpSeconds;
                        tmpNumber = [NSNumber numberWithLong:tmpInteger];
                        [timerArray replaceObjectAtIndex:i withObject:tmpNumber];
                        
                        [self incrementLikes:idPhoto];
                        
                        
                    }
                    else
                    {
                        NSLog(@"Error: Authorization failed");
                    }
                    
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
                
            }];
            
            
            break;
            
            
        }
    }
    
    
}
-(void)incrementLikes:(NSString*)idPhoto
{
    NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
    
    NSString *command = @"like";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   command, @"command",
                                   idPhoto,@"idPhoto",
                                   nil];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        NSArray *response = [responseObject allKeys];
        if(response.count >0)
        {
            
            NSLog(@"Response count %lu",(unsigned long)response.count);
            if(![[response objectAtIndex:0] isEqual: @"error"])
            {
                NSLog(@"Response like %@",responseObject);
                
                
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
-(void)flagPressed:(id)sender
{
    sheetType = @"flag";
    [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"What is the issue?",nil)
                                 delegate:self
                        cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                   destructiveButtonTitle:nil
                        otherButtonTitles:NSLocalizedString(@"Sexual content",nil), NSLocalizedString(@"Violent or repulsive content",nil), NSLocalizedString(@"Child Abuse",nil), NSLocalizedString(@"Hateful or abusive content",nil), nil]
     showInView:self.view];
}
-(void)flagConfirmed
{
    NSLog(@"Flag Button pressed");
    NSString *idPhoto;
    int i = globalSender;
    
    NSDictionary* dictionary = [tempMytableArray objectAtIndex:i];
    idPhoto = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"IdPhoto"]];
    NSLog(@"Flag %@",idPhoto);
    
    UIButton *tmpButton = flagsArray[i];
    tmpButton.enabled = NO;
    [tmpButton setImage:[UIImage imageNamed:@"flagPressed"]  forState:UIControlStateNormal];
    
    //Update Like Button
    NSNumber *likedButton = [NSNumber numberWithInteger:1];//= (long)[dictionary objectForKey:@"liked"];
    
    
    NSMutableDictionary *mutDict = [[NSMutableDictionary alloc]init];
    [mutDict setValuesForKeysWithDictionary:dictionary];
    [mutDict setObject:likedButton forKey:@"flagged"];
    tempMytableArray[i] = mutDict;
    
    //  Update Like Button
    tmpButton = likesArray[i];
    tmpButton.hidden = YES;
    
    //            Network
    //Get amount of time to be added
    NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
    NSString* command = @"flag";
    NSString *flagTypeStr = [NSString stringWithFormat:@"%d",flagType];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   command, @"command",
                                   flagTypeStr,@"type",
                                   idPhoto,@"idPhoto",
                                   nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [tempMytableArray removeObjectAtIndex:i];
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexpath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
    
}

-(void)deleteConfirmed
{
    NSLog(@"Delete Button pressed");
    NSString *idPhoto;
    
    int i = globalSender;
    
    NSDictionary* dictionary = [tempMytableArray objectAtIndex:i];
    idPhoto = [NSString stringWithFormat:@"%@", [dictionary objectForKey:@"IdPhoto"]];
    NSLog(@"Delete %@",idPhoto);
    
    //            Network
    //Get amount of time to be added
    NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
    NSString* command = @"deletePhoto";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   command, @"command",
                                   idPhoto,@"idPhoto",
                                   nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSArray *response = [responseObject allKeys];
        if(response.count >0)
        {
            
            NSLog(@"Response %@",responseObject);
            if(![[response objectAtIndex:0] isEqual: @"error"])
            {
                
            }
            else
            {
                NSLog(@"Error: Authorization failed");
            }
            [tempMytableArray removeObjectAtIndex:i];
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexpath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
    
}

-(void)profilePicturePressed:(id)sender
{
    pictureType = @"profile";
    NSLog(@"Profile Picture Add");
    sheetType = @"camera";
    [[[UIActionSheet alloc] initWithTitle:@"Upload picture from:"
                                 delegate:self
                        cancelButtonTitle:@"Cancel"
                   destructiveButtonTitle:nil
                        otherButtonTitles:@"Camera", @"Camera Roll", nil]
     showInView:self.view];
    
}
-(void)getPrifilePicture:(UIImageView*)imageViewLocal userId:(NSInteger)udid
{
    //Get Image from server
    NSString *imageUrl = [NSString stringWithFormat:@"%@/%@/%@/%d.jpg",kAPIHost,kAPIPath, @"profile",udid];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded");
        //3
        dispatch_async(dispatch_get_main_queue(), ^{
            // do stuff with image
            if ([UIImage imageWithData:responseObject] == nil) {
                imageViewLocal.image = [UIImage imageNamed:@"profilePicture"];
            }
            else
                imageViewLocal.image = [UIImage imageWithData:responseObject];
            
        });
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        imageViewLocal.image = [UIImage imageNamed:@"profilePicture"];
    }];
    
    [operation start];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    for (NSInteger i = 0; i < imagesArray.count; ++i)
    {
        [imagesArray addObject:[NSNull null]];
        
    }
}
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma  mark-ProfilePicture
-(void)getProfilePicture:(UITableViewCell *)cell;
{
    int width = 320;
    if(INTERFACE_IS_PAD)
        width = iPadWidth;
    
    CGRect frame = CGRectMake(0, 44, width, 60);
    CGRect imageFrame = CGRectMake(width/2-38, 5, 76, 76);
    if(INTERFACE_IS_PAD)
    {
        frame = CGRectMake(0, 44, width, 120);
        imageFrame = CGRectMake(width/2-55, 5, 110, 110);
    }
    
    imageButton = [[UIButton alloc]initWithFrame:imageFrame];
    [imageButton addTarget:self action:@selector(profilePicturePressed:) forControlEvents:UIControlEventTouchUpInside];
    imageButton.hidden = NO;
    imageButton.userInteractionEnabled = YES;
    
    CGRect fullNameFrame = CGRectMake(10, 60, width-10, 76);
    if(INTERFACE_IS_PAD)
        fullNameFrame = CGRectMake(10, 90, width-10, 76);
    
    UILabel *fullNameLabel = [[UILabel alloc]initWithFrame:fullNameFrame];
    fullNameLabel.text = appDelegate.fullName;
    fullNameLabel.textAlignment = NSTextAlignmentCenter;
    [cell addSubview:imageButton];
    [cell addSubview:fullNameLabel];
    
    CGRect cellFrame = CGRectMake(0, 0, width, 100);
    if(INTERFACE_IS_PAD)
        cellFrame = CGRectMake(0, 0, width, 200);
    cell.frame = cellFrame;
    //Get Image from server
    NSString *imageUrl = [NSString stringWithFormat:@"%@/%@/%@/%ld.jpg",kAPIHost,kAPIPath,@"profile",(long)appDelegate.udid];
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded");
        //3
        dispatch_async(dispatch_get_main_queue(), ^{
            // do stuff with image
            if ([UIImage imageWithData:responseObject] == nil){
                [imageButton setImage:[UIImage imageNamed:@"profilePicture120"] forState:UIControlStateNormal];
            } else
                [imageButton setImage:[UIImage imageWithData:responseObject] forState:UIControlStateNormal];
            
        });
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [imageButton setImage:[UIImage imageNamed:@"profilePicture120"] forState:UIControlStateNormal];
        
    }];
    
    [operation start];
    
}

#pragma mark TextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _titleTextField) {
        [_titleTextField becomeFirstResponder];
    }
    return NO;
}

#pragma mark-TouchesBegan

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch Event");
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([_titleTextField isFirstResponder] && [touch view] != _titleTextField) {
        [_titleTextField resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL lenght;
    if(textField == _titleTextField)
    {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        lenght = (newLength > 30) ? NO : YES;
    }
    return lenght;
}
- (void)commentsButtonTappedOnCell:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    NSLog(@"cell %@", indexPath);
    globalSender = indexPath.row;
    
    CommentsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
    
    NSLog(@"cell %i", indexPath.row);

    int i = indexPath.row;
    
    controller.postDictionary = [tempMytableArray objectAtIndex:i];
    controller.mainImage = [imagesArray objectAtIndex:i];
    controller.streamCurrentDateTime = streamCurrentDateTime;
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark APNS
/*
 * ------------------------------------------------------------------------------------------
 *  BEGIN APNS CODE
 * ------------------------------------------------------------------------------------------
 */
-(void)PFregisterDeviceData
{
    NSLog(@"Device token %@",appDelegate.deviceToken);
    if(appDelegate.deviceToken != nil)
    {
        // Prepare the Device Token for Registration (remove spaces and < >)
        NSString *deviceToken = [[[[appDelegate.deviceToken description]
                                   stringByReplacingOccurrencesOfString:@"<"withString:@""]
                                  stringByReplacingOccurrencesOfString:@">" withString:@""]
                                 stringByReplacingOccurrencesOfString: @" " withString: @""];
        
        NSString *udid = [NSString stringWithFormat:@"%d",appDelegate.udid];
        
        // Register the Device Data
        // !!! CHANGE "http" TO "https" IF YOU ARE USING HTTPS PROTOCOL
        NSString *urlString = [@"apns/PFregisterDevice.php?" stringByAppendingString:@"appId=com.xavyx.xavyx"];
        urlString = [urlString stringByAppendingString:@"&deviceToken="];//CAP T
        urlString = [urlString stringByAppendingString:deviceToken];
        urlString = [urlString stringByAppendingString:@"&IdUser="];//CAP T
        urlString = [urlString stringByAppendingString:udid];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@/%@",kAPIHost,urlString];
        
        NSURL *url = [[NSURL alloc]initWithString:urlStr];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSLog(@"Register URL: %@", url);
        NSLog(@"Return Data: %@", returnData);
    }
}



/*
 * ------------------------------------------------------------------------------------------
 *  END APNS CODE
 * ------------------------------------------------------------------------------------------
 */

#pragma mark Type
-(void)typeComment:(NSString*)typeId IdPhoto:(NSString*)IdPhoto
{
    NSString* command = @"fetchSpecific";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   command, @"command",
                                   typeId,@"type",
                                   IdPhoto,@"IdPhoto",
                                   nil];
    
    NSString *script = [NSString stringWithFormat:@"%@/%@/%@",kAPIHost,kAPIPath,@"app.php"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:script parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *response = [responseObject allKeys];
        if(response.count >0)
        {
            
            NSLog(@"Response count %lu",(unsigned long)response.count);
            if(![[response objectAtIndex:0] isEqual: @"error"])
            {
                NSLog(@"Response success fetching notification comment");
                NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                [tempArray addObjectsFromArray:[responseObject objectForKey:@"result"]];
                NSLog(@"Respond stream: %@",tempArray);
                
                CommentsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
                
                controller.postDictionary = [tempArray objectAtIndex:0];
                //                controller.mainImage = [imagesArray objectAtIndex:0];
                controller.streamCurrentDateTime = streamCurrentDateTime;
                
                [self.navigationController pushViewController:controller animated:YES];
                
            }
            else
            {
                NSLog(@"Error: Authorization failed");
                [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:1.0];
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:1.0];
        
    }];
    
}


-(void) ClickEventOnImage:(id) sender
{
    UIImageView *image = (UIImageView*)sender;
    NSIndexPath *indexpath = [self.tableView indexPathForCell:sender];
    NSLog(@"index main image tap %d",indexpath.row);
    NSLog(@"image %@",image);
}

-(void)mainImageTapped:(id)sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    NSLog(@"Tag = %@", gesture.view.layer.name);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"index selected %d",indexPath.row);
    
}

+ (UIImage *)scaleImage:(UIImage *)image maxWidth:(int) maxWidth maxHeight:(int) maxHeight
{
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    if (width <= maxWidth && height <= maxHeight)
    {
        return image;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    if (width > maxWidth || height > maxHeight)
    {
        CGFloat ratio = width/height;
        
        if (ratio > 1)
        {
            bounds.size.width = maxWidth;
            bounds.size.height = bounds.size.width / ratio;
        }
        else
        {
            bounds.size.height = maxHeight;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, scaleRatio, -scaleRatio);
    CGContextTranslateCTM(context, 0, -height);
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
    
}


#pragma mark Transition to games
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

#pragma mark UINavigationControllerDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    // Check if we're transitioning from this view controller to a DSLSecondViewController
    //    if (fromVC == self && [toVC isKindOfClass:[SliderPuzzleMenuViewController class]]) {
    //        return [[DSLTransitionFromFirstToSecond alloc] init];
    //    }
    //    else {
    return nil;
    //    }
}

- (void)handlePopRecognizer:(UIScreenEdgePanGestureRecognizer*)recognizer {
    // Calculate how far the user has dragged across the view
    CGFloat progress = [recognizer translationInView:self.view].x / (self.view.bounds.size.width * 1.0);
    progress = MIN(1.0, MAX(0.0, progress));
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // Create a interactive transition and pop the view controller
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // Update the interactive transition's progress
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        // Finish or cancel the interactive transition
        if (progress > 0.5) {
            [self.interactivePopTransition finishInteractiveTransition];
        }
        else {
            [self.interactivePopTransition cancelInteractiveTransition];
        }
        
        self.interactivePopTransition = nil;
    }
}
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    // Check if this is for our custom transition
    if ([animationController isKindOfClass:[DSLTransitionFromSecondToFirst class]]) {
        return self.interactivePopTransition;
    }
    else {
        return nil;
    }
}
- (MainCell*)tableViewCell:(NSString*)IdPhoto {
    NSInteger thingIndex = 0;
    for(int i=0; i<[tempMytableArray count]; i++)
    {
        NSDictionary *dictionary = [tempMytableArray objectAtIndex:i];
        NSString *str = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"IdPhoto"]];
        if([str isEqualToString:IdPhoto])
        {
            thingIndex = i;
            break;
        }
    }
    if (thingIndex == NSNotFound) {
        return nil;
    }
    
    return (MainCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:thingIndex inSection:0]];
}

- (void)logoutButton
{
    sheetType = @"logout";
    [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Confirm",nil)
                                 delegate:self
                        cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                   destructiveButtonTitle:nil
                        otherButtonTitles:NSLocalizedString(@"Logout",nil), nil]
     showInView:self.view];
    
}
-(void)logout
{
    //Log out
    //From local - delete password from keychain
    NSUserDefaults *saveapp = [NSUserDefaults standardUserDefaults];
    
    //  Retrieve email
    NSString *encryptedEmail = [saveapp objectForKey:@"email"];
    
    //Delete from macro
    [saveapp setObject:nil forKey:@"email"];
    
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

-(void)deleteProfile
{
    AccountManagementViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountManagementViewController"];
    
    [self.navigationController pushViewController:controller animated:YES];
}
@end
