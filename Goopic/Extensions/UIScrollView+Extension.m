//
//  UIScrollView+Extension.m
//  Goopic
//
//  Created by andrei.marincas on 26/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "UIScrollView+Extension.h"

@implementation UIScrollView (Extension)

- (UIPanGestureRecognizer *)panGestureRecognizer
{
    for (UIGestureRecognizer *gr in self.gestureRecognizers)
    {
        if ([gr isKindOfClass:[UIPanGestureRecognizer class]])
        {
            return (UIPanGestureRecognizer *)gr;
        }
    }
    
    return nil;
}

@end
