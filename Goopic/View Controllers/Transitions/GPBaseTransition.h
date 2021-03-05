//
//  GPBaseTransition.h
//  Goopic
//
//  Created by Andrei Marincas on 01/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GPBaseTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) NSTimeInterval presentationDuration;
@property (nonatomic) NSTimeInterval dismissalDuration;

@property (nonatomic, getter = isReverse) BOOL reverse;

// Designated initializer
- (instancetype)init;

// Override
- (void)executePresentationAnimation:(id <UIViewControllerContextTransitioning>)transitionContext;

// Override
- (void)executeDismissalAnimation:(id <UIViewControllerContextTransitioning>)transitionContext;

@end
