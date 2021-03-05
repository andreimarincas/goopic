//
//  GPFadeTransition.m
//  Goopic
//
//  Created by Andrei Marincas on 01/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPFadeTransition.h"

@implementation GPFadeTransition

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.presentationDuration = self.dismissalDuration = 0.25f;
    }
    
    return self;
}

- (void)executePresentationAnimation:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    
    toViewController.view.alpha = 0;
    [container addSubview:toViewController.view];
    
    [UIView animateWithDuration:self.presentationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         toViewController.view.alpha = 1;
                         
                     } completion:^(BOOL finished) {
                         [transitionContext completeTransition:finished];
                     }];
}

- (void)executeDismissalAnimation:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    
    [container insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    [UIView animateWithDuration:self.dismissalDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         fromViewController.view.alpha = 0;
                         
                     } completion:^(BOOL finished) {
                         [transitionContext completeTransition:finished];
                     }];
}

@end
