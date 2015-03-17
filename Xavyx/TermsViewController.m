//
//  TermsViewController.m
//  xavyx
//
//  Created by Xavy on 3/7/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import "TermsViewController.h"

@interface TermsViewController ()

@end

@implementation TermsViewController
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
	// Do any additional setup after loading the view.
 
    [self loadRemotePdf];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadRemotePdf
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize screenSize = rect.size;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,44,screenSize.width,screenSize.height-88)];
    webView.autoresizesSubviews = YES;
    webView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    /*Unhide Terms of Use button in RegisterViewController*/
    NSURL *myUrl = [NSURL URLWithString:@"http://yourdomain.com/path_to_terms.pdf"];//<http://yourdomain.com/path_to_terms.pdf>
    
    NSURLRequest *myRequest = [NSURLRequest requestWithURL:myUrl];
    
    [webView loadRequest:myRequest];
    
    [self.view addSubview: webView];
    
}

- (IBAction)doneButtonAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
