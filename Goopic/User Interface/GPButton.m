//
//  GPButton.m
//  Goopic
//
//  Created by andrei.marincas on 27/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPButton.h"


@implementation GPButtonStateTransitionView

- (instancetype)initWithButton:(GPButton *)button state:(UIControlState)state
{
    self = [super init];
    
    if (self)
    {
        self.frame = button.frame;
        self.transform = button.transform;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[button imageForState:state]];
        imageView.frame = self.bounds;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *label = [[UILabel alloc] init];
        label.font = button.titleLabel.font;
        label.text = [button titleForState:UIControlStateNormal];
        label.textColor = [button titleColorForState:state];
        label.textAlignment = NSTextAlignmentCenter;
        [label sizeToFit];
        [self addSubview:label];
        label.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        self.label = label;
    }
    
    return self;
}

@end



@implementation GPButton

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        // Custom initialization
        
        self.forceHighlight = NO;
        self.hitTestEdgeInsets = UIEdgeInsetsZero;
        self.animateHighlightStateChange = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)handleAppWillResignActive:(NSNotification *)notification
{
    GPLogIN();
    
    if (self.forceHighlight && self.isHighlighted)
    {
        self.highlighted = NO;
    }
    
    GPLogOUT();
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL inside = NO;
    
    // Hit test edge insets
    if (UIEdgeInsetsEqualToEdgeInsets(self.hitTestEdgeInsets, UIEdgeInsetsZero) || !self.enabled || self.hidden)
    {
        inside = [super pointInside:point withEvent:event];
    }
    else
    {
        CGRect relativeFrame = self.bounds;
        CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, GPEdgeInsetsNegate(self.hitTestEdgeInsets));
        
//        GPLog(@"relative frame: %@", NSStringFromCGRect(relativeFrame));
//        GPLog(@"hit frame: %@", NSStringFromCGRect(hitFrame));
//        GPLog(@"point: %@", NSStringFromCGPoint(point));
        
        // TODO: UIButton not responsive near the screen margin?
        
        inside = CGRectContainsPoint(hitFrame, point);
    }
    
    // Force highlight
    if (self.forceHighlight)
    {
        if (inside && !self.isHighlighted)
        {
            self.highlighted = YES;
        }
    }
    
    return inside;
}

- (void)animateFromHighlightToNormal
{
    GPLogIN();
    
    UIControlState highlightState = self.isSelected ? UIControlStateNormal : UIControlStateHighlighted;
    GPButtonStateTransitionView *viewForHighlightState = [[GPButtonStateTransitionView alloc] initWithButton:self state:highlightState];
    [self.superview addSubview:viewForHighlightState];
    self.viewForHighlightState = viewForHighlightState;
    
    UIControlState normalState = self.isSelected ? UIControlStateSelected : UIControlStateNormal;
    GPButtonStateTransitionView *viewForNormalState = [[GPButtonStateTransitionView alloc] initWithButton:self state:normalState];
    viewForNormalState.alpha = 0;
    [self.superview addSubview:viewForNormalState];
    self.viewForNormalState = viewForNormalState;
    
    self.alpha = 0.00001;
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState |
                                     UIViewAnimationOptionCurveEaseOut;
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:options
                     animations:^{
                         
                         viewForNormalState.alpha = 1;
                         
                     } completion:^(BOOL finished) {
                         
                         self.alpha = 1;
                         [viewForHighlightState removeFromSuperview];
                         [viewForNormalState removeFromSuperview];
                     }];
    
    GPLogOUT();
}

- (void)setHighlighted:(BOOL)highlighted
{
    static BOOL wasSelectedWhenHighlighted;
    BOOL wasHighlighted = [self isHighlighted];
    
    [super setHighlighted:highlighted];
    
    if (self.animateHighlightStateChange)
    {
        if (highlighted != wasHighlighted)
        {
            if (!highlighted)
            {
                if ([self isSelected] == wasSelectedWhenHighlighted && [self isEnabled])
                {
                    [self animateFromHighlightToNormal];
                }
            }
            else
            {
                self.alpha = 1;
                
                [self.viewForHighlightState removeFromSuperview];
                self.viewForHighlightState = nil;
                
                [self.viewForNormalState removeFromSuperview];
                self.viewForNormalState = nil;
                
                wasSelectedWhenHighlighted = self.isSelected;
            }
        }
    }
    
    if (self.connectedButton)
    {
        if ([self.connectedButton isHighlighted] != highlighted)
        {
            self.connectedButton.highlighted = highlighted;
        }
    }
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if (!enabled)
    {
        [self.viewForHighlightState removeFromSuperview];
        self.viewForHighlightState = nil;
        
        [self.viewForNormalState removeFromSuperview];
        self.viewForNormalState = nil;
    }
    
    if (self.connectedButton)
    {
        if ([self.connectedButton isEnabled] != enabled)
        {
            self.connectedButton.enabled = enabled;
        }
    }
}

- (void)setTransform:(CGAffineTransform)transform
{
    GPLogIN();
    [super setTransform:transform];
    
    self.viewForHighlightState.transform = transform;
    self.viewForNormalState.transform = transform;
    
    GPLogOUT();
}

- (void)connectTo:(GPButton *)button
{
    GPLogIN();
    
    self.connectedButton = button;
    button.connectedButton = self;
    
    GPLogOUT();
}

@end
