//
//  GPResponsiveButton.m
//  Goopic
//
//  Created by andrei.marincas on 27/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPResponsiveButton.h"

@implementation GPResponsiveButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inside = [super pointInside: point withEvent: event];
    
    if (inside && !self.highlighted)
    {
        self.highlighted = YES;
    }
    
    return inside;
}

@end
