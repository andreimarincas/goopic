//
//  CALayer+Extension.m
//  Goopic
//
//  Created by andrei.marincas on 06/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "CALayer+Extension.h"

@implementation CALayer (Extension)

+ (void)performWithoutAnimation:(Block)actionsWithoutAnimation
{
    if (actionsWithoutAnimation)
    {
        // Wrap actions in a transaction block to avoid implicit animations.
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        
        actionsWithoutAnimation();
        
        [CATransaction commit];
    }
}

- (void)bringSublayerToFront:(CALayer *)layer
{
    // Bring to front only if already in this layer's hierarchy.
    if ([layer superlayer] == self)
    {
        [CALayer performWithoutAnimation:^{
            
            // Add 'layer' to the end of the receiver's sublayers array.
            // If 'layer' already has a superlayer, it will be removed before being added.
            [self addSublayer:layer];
        }];
    }
}

@end
