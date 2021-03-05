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
            buttonTypeStr = @"CAM";
            break;
            
        case GPToolbarButtonSearchGoogleForThisImage:
            buttonTypeStr = @"Search Google For This Image";
            break;
            
        case GPToolbarButtonBackToPhotos:
            buttonTypeStr = @"Photos";
            break;
            
        default: buttonTypeStr = @"<unknown-btn>";
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

BOOL CGPointInCGRect(CGPoint point, CGRect rect)
{
    return (point.x >= rect.origin.x) &&
    (point.x <= rect.origin.x + rect.size.width) &&
    (point.y >= rect.origin.y) &&
    (point.y <= rect.origin.y + rect.size.height);
}

CGFloat ScaleFactorForUploadingImageWithSize(CGSize size)
{
    if (size.width * size.height <= kMaxImageUploadSize)
    {
        return 1; // no need to scale
    }
    
    CGFloat r = size.width / size.height;
    CGFloat w = sqrtf(r * kMaxImageUploadSize);
    
    return w / size.width;
}

CGSize CGSizeIntegral(CGSize size)
{
    return CGSizeMake((int)size.width, (int)size.height);
}
