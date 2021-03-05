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

CGFloat StatusBarHeightForToolbar();
CGFloat ToolbarHeight();

NSString * NSStringFromBOOL(BOOL b);

UIInterfaceOrientation GPInterfaceOrientation();

BOOL GPInterfaceOrientationIsPortrait();
BOOL GPInterfaceOrientationIsLandscape();

UIInterfaceOrientationMask GPInterfaceOrientationMaskForOrientation(UIInterfaceOrientation orientation);

BOOL CGPointInCGRect(CGPoint point, CGRect rect);

CGFloat ScaleFactorForUploadingImageWithSize(CGSize size);

CGSize CGSizeIntegral(CGSize size);

UIEdgeInsets GPEdgeInsetsNegate(UIEdgeInsets insets);
UIEdgeInsets GPEdgeInsetsMake(CGFloat inset);