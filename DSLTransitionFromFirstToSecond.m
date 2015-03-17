//
//  DSLTransitionFromFirstToSecond.m
//  TransitionExample
//
//  Created by Pete Callaway on 21/07/2013.
//  Copyright (c) 2013 Dative Studios. All rights reserved.
//

#import "DSLTransitionFromFirstToSecond.h"

//#import "DSLFirstViewController.h"
//#import "DSLSecondViewController.h"
#import "MainViewController.h"
#import "MainCell.h"


@implementation DSLTransitionFromFirstToSecond

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
//    MainViewController *fromViewController = (MainViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    SliderPuzzleMenuViewController *toViewController = (SliderPuzzleMenuViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//
//    UIView *containerView = [transitionContext containerView];
//    NSTimeInterval duration = [self transitionDuration:transitionContext];
//
//    // Get a snapshot of the thing cell we're transitioning from
//    MainCell *cell = (MainCell*)[fromViewController.tableView cellForRowAtIndexPath:[fromViewController.tableView indexPathForSelectedRow]];
//    UIView *cellImageSnapshot = [cell.imageViewMain snapshotViewAfterScreenUpdates:NO];
//    cellImageSnapshot.frame = [containerView convertRect:cell.imageViewMain.frame fromView:cell.imageViewMain.superview];
//    cell.imageView.hidden = YES;
//
//    // Setup the initial view states
//    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
//    toViewController.view.alpha = 0;
//    toViewController.mainImageView.hidden = YES;
//
//    [containerView addSubview:toViewController.view];
//    [containerView addSubview:cellImageSnapshot];
//
//    [UIView animateWithDuration:duration animations:^{
//        // Fade in the second view controller's view
//        toViewController.view.alpha = 1.0;
//
//        // Move the cell snapshot so it's over the second view controller's image view
//        CGRect frame = [containerView convertRect:toViewController.mainImageView.frame fromView:toViewController.view];
//        cellImageSnapshot.frame = frame;
//    } completion:^(BOOL finished) {
//        // Clean up
//        toViewController.mainImageView.hidden = NO;
//        cell.hidden = NO;
//        [cellImageSnapshot removeFromSuperview];
//
//        // Declare that we've finished
//        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
//    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

@end
