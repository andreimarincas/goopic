//
//  GPBaseViewController+Private.m
//  Goopic
//
//  Created by Andrei Marincas on 01/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPBaseViewController+Private.h"


@implementation GPBaseView (Private)

- (void)setBaseViewController:(GPBaseViewController *)baseViewController
{
    _baseViewController = baseViewController;
}

@end


@implementation GPBaseViewController (Private)

- (void)updateBaseUI
{
    [self updateUI];
    [self bringActivityViewToFrontIfActivityInProgress];
}

@end
