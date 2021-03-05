//
//  GPBaseTransition.m
//  Goopic
//
//  Created by Andrei Marincas on 01/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPBaseTransition.h"

@implementation GPBaseTransition

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.presentationDuration = 1.0f;
        self.dismissalDuration = 1.0f;
        self.reverse = NO;
    }
    
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return !self.isReverse ? self.presentationDuration : self.dismissalDuration;
}

-(void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if (!self.reverse)
    {
        [self executePresentationAnimation:transitionContext];
    }
    else
    {
        [self executeDismissalAnimation:transitionContext];
    }
}

- (void)executePresentationAnimation:(id <UIViewControllerContextTransitioning>)transitionContext
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)executeDismissalAnimation:(id <UIViewControllerContextTransitioning>)transitionContext
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

@end
