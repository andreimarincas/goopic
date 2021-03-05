//
//  UIViewController+Extension.h
//  Goopic
//
//  Created by andrei.marincas on 27/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GPToolbar;
@class GPRootViewController;

@interface UIViewController (Extension)

@property (nonatomic, weak) GPRootViewController *rootViewController;

@property (nonatomic, readonly) BOOL isTopViewController; // for controllers added in root view controller

@property (nonatomic, readonly) GPToolbar *topToolbar;
@property (nonatomic, readonly) GPToolbar *bottomToolbar;

- (void)updateUI;

@end
