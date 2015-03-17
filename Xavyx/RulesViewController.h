//
//  RulesViewController.h
//  xavyx
//
//  Created by Xavy on 3/10/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RulesViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property(nonatomic, readonly, getter=isLoading) BOOL loading;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
