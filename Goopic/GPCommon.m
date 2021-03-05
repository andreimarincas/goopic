//
//  GPCommon.m
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPCommon.h"
#import "GPRootViewController.h"

NSString * NSStringFromGPToolbarButtonType(GPToolbarButtonType buttonType)
{
    NSString *buttonTypeStr;
    
    switch (buttonType)
    {
        case GPToolbarButtonCamera:
        {
            buttonTypeStr = @"Camera";
        }
            break;
            
        default:
        {
            buttonTypeStr = @"<unknown>";
        }
            break;
    }
    
    return buttonTypeStr;
}

BOOL AppIsInFullScreenMode()
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    GPLog(@"screen bounds: %@", NSStringFromCGRect(screenBounds));
    
    GPRootViewController *rootViewController = [GPRootViewController rootViewController];
    GPLog(@"root frame: %@", NSStringFromCGRect(rootViewController.view.frame));
    
    return (screenBounds.size.height == rootViewController.view.frame.size.height);
}

CGFloat StatusBarHeight()
{
    CGRect statusFrame = [[UIApplication sharedApplication] statusBarFrame];
    return fminf(statusFrame.size.width, statusFrame.size.height);
}

NSString * NSStringFromBOOL(BOOL b)
{
    return b ? @"YES" : @"NO";
}

UIInterfaceOrientation GPInterfaceOrientation()
{
    return [[UIApplication sharedApplication] statusBarOrientation];
}

BOOL GPInterfaceOrientationIsPortrait()
{
    return UIInterfaceOrientationIsPortrait(GPInterfaceOrientation());
}

BOOL GPInterfaceOrientationIsLandscape()
{
    return UIInterfaceOrientationIsLandscape(GPInterfaceOrientation());
}
