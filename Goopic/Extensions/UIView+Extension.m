//
//  UIView+Extension.m
//  Goopic
//
//  Created by andrei.marincas on 31/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

- (void)setSubviewsHidden:(BOOL)hidden
{
    for (UIView *subview in self.subviews)
    {
        subview.hidden = hidden;
    }
    
    for (CALayer *sublayer in self.layer.sublayers)
    {
        sublayer.hidden = hidden;
    }
}

- (void)moveToView:(UIView *)view
{
    UIView *selfView = self;
    [selfView removeFromSuperview];
    [view addSubview:selfView];
}

@end
