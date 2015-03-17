//
//  RulesViewController.m
//  xavyx
//
//  Created by Xavy on 3/10/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import "RulesViewController.h"

@interface RulesViewController ()

@end

@implementation RulesViewController

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
    _webView.delegate = self;
   
    NSString *userLocale = [[NSLocale currentLocale] localeIdentifier];
    NSLog(@"Locale %@", userLocale);
    
    NSString *language = NSLocalizedString(@"lang", nil);
    NSLog(@"lang: %@",language);
    
    NSURL *url;
    //you can specific any language here if Spanish else English
    if([language isEqualToString:@"es"])
        //http://yourdomain.com/path_to_rulesES.html
        url = [NSURL URLWithString:@"http://xavyx.com/xavyx/rules/RulesES.html"];//Specify path for rules in Spanish
    else
        //http://yourdomain.com/path_to_rulesEN.html
        url = [NSURL URLWithString:@"http://xavyx.com/xavyx/rules/RulesEN.html"];//Speciify path for rules in English//    [_webView loadHTMLString:@"RulesES" baseURL:url];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    
     [_activity startAnimating];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    
    [_activity stopAnimating];
}

@end
