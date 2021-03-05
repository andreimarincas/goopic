//
//  UIView+Extension.h
//  Goopic
//
//  Created by andrei.marincas on 31/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)

- (void)moveToView:(UIView *)view;

// animated: if YES, cross-fade animation
+ (void)hideView:(UIView *)view1 andRevealView:(UIView *)view2 animated:(BOOL)animated;

@end
