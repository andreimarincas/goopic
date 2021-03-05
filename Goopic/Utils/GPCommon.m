//
//  GPCommon.m
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPCommon.h"

NSString * NSStringFromGPToolbarButtonType(GPToolbarButtonType buttonType)
{
    NSString *buttonTypeStr;
    
    switch (buttonType)
    {
        case GPToolbarButtonCamera:
            buttonTypeStr = @"Camera";
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

CGFloat StatusBarHeight()
{
    return 20.0f; // I need this to be the same also when the status bar is hidden
}

CGFloat RealStatusBarHeight()
{
    CGRect statusFrame = [[UIApplication sharedApplication] statusBarFrame];
    return fminf(statusFrame.size.width, statusFrame.size.height); // depending on interface orientation
}

CGFloat StatusBarHeightForToolbar()
{
    return GPInterfaceOrientationIsPortrait() ? StatusBarHeight() : 0;
}

CGFloat ToolbarHeight(BOOL top)
{
    if (top && GPInterfaceOrientationIsPortrait())
    {
        if (RealStatusBarHeight() > StatusBarHeight()) // status bar height is 40 (red when recording, green during phone call)
        {
            return kToolbarHeight_Portrait + StatusBarHeight();
        }
    }
    
    return (GPInterfaceOrientationIsPortrait() ? kToolbarHeight_Portrait : kToolbarHeight_Landscape);
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

UIInterfaceOrientationMask GPInterfaceOrientationMaskForOrientation(UIInterfaceOrientation orientation)
{
    if (orientation == UIInterfaceOrientationPortrait)           return UIInterfaceOrientationMaskPortrait;
    if (orientation == UIInterfaceOrientationPortraitUpsideDown) return UIInterfaceOrientationMaskPortraitUpsideDown;
    if (orientation == UIInterfaceOrientationLandscapeLeft)      return UIInterfaceOrientationMaskLandscapeLeft;
    if (orientation == UIInterfaceOrientationLandscapeRight)     return UIInterfaceOrientationMaskLandscapeRight;
    
    return UIInterfaceOrientationMaskAll;
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

UIEdgeInsets GPEdgeInsetsNegate(UIEdgeInsets insets)
{
    return UIEdgeInsetsMake(-insets.top, -insets.left, -insets.bottom, -insets.right);
}

UIEdgeInsets GPEdgeInsetsMake(CGFloat inset)
{
    return UIEdgeInsetsMake(inset, inset, inset, inset);
}

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
}

CGFloat FloorValueWithTwoDecimals(CGFloat value)
{
    return floorf(100 * value) / 100;
}
