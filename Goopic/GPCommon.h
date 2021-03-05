//
//  GPCommon.h
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <Foundation/Foundation.h>


NSString * NSStringFromGPToolbarButtonType(GPToolbarButtonType buttonType);

BOOL AppIsInFullScreenMode();

CGFloat StatusBarHeight();

NSString * NSStringFromBOOL(BOOL b);

UIInterfaceOrientation GPInterfaceOrientation();

BOOL GPInterfaceOrientationIsPortrait();
BOOL GPInterfaceOrientationIsLandscape();

BOOL CGPointInCGRect(CGPoint point, CGRect rect);

CGFloat ScaleFactorForUploadingImageWithSize(CGSize size);

CGSize CGSizeIntegral(CGSize size);
