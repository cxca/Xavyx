//
//  SettingsViewController.h
//  xavyx
//
//  Created by Xavy on 3/12/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
{
    NSTimer *timer;
    IBOutlet UILabel *myCounterLabel;
}

//@property (strong, nonatomic) IBOutlet UILabel *myCounterLabel;
-(void)updateCounter:(NSTimer *)theTimer;
-(void)countdownTimer;

@end
