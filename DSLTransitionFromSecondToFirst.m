//
//  DSLTransitionFromSecondToFirst.m
//  TransitionExample
//
//  Created by Pete Callaway on 21/07/2013.
//  Copyright (c) 2013 Dative Studios. All rights reserved.
//

#import "DSLTransitionFromSecondToFirst.h"

#import "MainViewController.h"
#import "MainCell.h"

@implementation DSLTransitionFromSecondToFirst

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
//    SliderPuzzleMenuViewController *fromViewController = (SliderPuzzleMenuViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    MainViewController *toViewController = (MainViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//
//    UIView *containerView = [transitionContext containerView];
//    NSTimeInterval duration = [self transitionDuration:transitionContext];
//
//    // Get a snapshot of the image view
//    UIView *imageSnapshot = [fromViewController.mainImageView snapshotViewAfterScreenUpdates:NO];
//    imageSnapshot.frame = [containerView convertRect:fromViewController.mainImageView.frame fromView:fromViewController.mainImageView.superview];
//    fromViewController.mainImageView.hidden = YES;
//
//    // Get the cell we'll animate to
//    MainCell *cell = [toViewController tableViewCell:fromViewController.IdPhoto];
//    cell.imageView.hidden = YES;
//
//    // Setup the initial view states
//    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
//    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
//    [containerView addSubview:imageSnapshot];
//
//    [UIView animateWithDuration:duration animations:^{
//        // Fade out the source view controller
//        fromViewController.view.alpha = 0.0;
//
//        // Move the image view
//        imageSnapshot.frame = [containerView convertRect:cell.imageViewMain.frame fromView:cell.imageViewMain.superview];
//    } completion:^(BOOL finished) {
//        // Clean up
//        [imageSnapshot removeFromSuperview];
//        fromViewController.mainImageView.hidden = NO;
//        cell.imageView.hidden = NO;
//
//        // Declare that we've finished
//        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
//    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

@end
