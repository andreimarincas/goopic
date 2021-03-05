//
//  GPCommon.h
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <Foundation/Foundation.h>


NSString * NSStringFromGPToolbarButtonType(GPToolbarButtonType buttonType);

CGFloat StatusBarHeight();
CGFloat RealStatusBarHeight();

CGFloat StatusBarHeightForToolbar();

// if the toolbar is on top of the screen then the status bar height will be added
CGFloat ToolbarHeight(BOOL top);

NSString * NSStringFromBOOL(BOOL b);

UIInterfaceOrientation GPInterfaceOrientation();

BOOL GPInterfaceOrientationIsPortrait();
BOOL GPInterfaceOrientationIsLandscape();

UIInterfaceOrientationMask GPInterfaceOrientationMaskForOrientation(UIInterfaceOrientation orientation);

BOOL CGPointInFrame(CGPoint point, CGRect rect);
CGFloat CGPointDistanceToCGPoint(CGPoint p1, CGPoint p2);
CGPoint CenterOfFrame(CGRect frame);

double sqr(double x);

CGFloat ScaleFactorForUploadingImageWithSize(CGSize size);

CGSize CGSizeIntegral(CGSize size);

UIEdgeInsets GPEdgeInsetsNegate(UIEdgeInsets insets);
UIEdgeInsets GPEdgeInsetsMake(CGFloat inset);

CGFloat DegreesToRadians(CGFloat degrees);

CGFloat FloorValueWithTwoDecimals(CGFloat value);

BOOL iOS_8_or_higher();
