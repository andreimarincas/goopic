//
//  UIViewController+Extension.m
//  Goopic
//
//  Created by andrei.marincas on 10/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "UIViewController+Extension.h"

@implementation UIViewController (Extension)

- (BOOL)isOrientationSupported:(UIInterfaceOrientation)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
            return (UIInterfaceOrientationMaskPortrait & [self supportedInterfaceOrientations]);
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return (UIInterfaceOrientationMaskPortraitUpsideDown & [self supportedInterfaceOrientations]);
            
        case UIInterfaceOrientationLandscapeLeft:
            return (UIInterfaceOrientationMaskLandscapeLeft & [self supportedInterfaceOrientations]);
            
        case UIInterfaceOrientationLandscapeRight:
            return (UIInterfaceOrientationLandscapeRight & [self supportedInterfaceOrientations]);
            
        default:
            return NO;
    }
}

@end
