//
//  UIViewController+Extension.m
//  Goopic
//
//  Created by andrei.marincas on 27/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "UIViewController+Extension.h"
#import "GPRootViewController.h"
#import "GPToolbar.h"

@implementation UIViewController (Extension)

@dynamic rootViewController;

- (BOOL)isTopViewController
{
    if (self.parentViewController == [GPRootViewController rootViewController])
    {
        return (self == [[GPRootViewController rootViewController] topViewController]);
    }
    
    return NO;
}

- (GPToolbar *)topToolbar
{
    return nil;
}

- (GPToolbar *)bottomToolbar
{
    return nil;
}

- (void)updateUI
{
    // No implementation needed
}

@end
