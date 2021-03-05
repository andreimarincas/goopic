//
//  UIView+Extension.m
//  Goopic
//
//  Created by andrei.marincas on 31/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "UIView+Extension.h"

static const NSTimeInterval kTransitionAnimationDuration = 0.1f;

@implementation UIView (Extension)

- (void)moveToView:(UIView *)view
{
    UIView *selfView = self;
    [selfView removeFromSuperview];
    [view addSubview:selfView];
}

+ (void)hideView:(UIView *)view1 andRevealView:(UIView *)view2 animated:(BOOL)animated
{
    if (view1 != view2)
    {
        Block transitionBlock = ^{
            
            view1.alpha = 0;
            view2.alpha = 1;
        };
        
        if (animated)
        {
            UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState |
                                             UIViewAnimationOptionCurveLinear;
            
            [UIView animateWithDuration:kTransitionAnimationDuration
                                  delay:0
                                options:options
                             animations:transitionBlock
                             completion:nil];
        }
        else
        {
            [UIView performWithoutAnimation:transitionBlock];
        }
    }
}

- (void)setUserInteractionEnabled:(BOOL)enabled applyToSubviews:(BOOL)apply
{
    self.userInteractionEnabled = enabled;
    
    if (apply)
    {
        for (UIView *view in [self subviews])
        {
            [view setUserInteractionEnabled:enabled applyToSubviews:apply];
        }
    }
}

@end
