//
//  UITabBarController+TabBarController.m
//  Tune Stream
//
//  Created by Xavy on 11/17/14.
//  Copyright (c) 2014 Carlos Chaparro. All rights reserved.
//

#import "TabBarController.h"
#import "AppDelegate.h"

@interface TabBarController ()
{
    
}
@end

@implementation TabBarController

-(void)viewDidLoad
{
  
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    if (item.tag == 0)
    {
        appDelegate.controllerView = 0;
    }
    else if (item.tag == 2)
    {
        appDelegate.controllerView = 1;
    }
}
@end
