//
//  GPButton.m
//  Goopic
//
//  Created by andrei.marincas on 27/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPButton.h"

static const CGFloat kButtonAlphaForHighlightTransition = 0.001f;
static const NSTimeInterval kButtonHighlightTransitionDuration = 0.2f;


#pragma mark - GP Button State Transition View

@implementation GPButtonStateTransitionView

- (instancetype)initWithButton:(GPButton *)button state:(UIControlState)state
{
    self = [super init];
    
    if (self)
    {
        self.frame = button.frame;
        self.transform = button.transform;
        
        if ([button isImageBased])
        {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[button imageForState:state]];
            imageView.frame = self.bounds;
            [self addSubview:imageView];
            self.imageView = imageView;
        }
        else
        {
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
    }
    
    return self;
}

@end


#pragma mark - GP Button

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
        self.isImageBased = NO;
        
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
        
        // TODO: UIButton not responsive near the screen margins?
        
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
    
    [self.viewForHighlightState removeFromSuperview];
    self.viewForHighlightState = nil;
    
    [self.viewForNormalState removeFromSuperview];
    self.viewForNormalState = nil;
    
    // set this alpha value before creating the transition views, otherwise they will be affected too
    self.alpha = kButtonAlphaForHighlightTransition;
    
    UIControlState highlightState = self.isSelected ? UIControlStateNormal : UIControlStateHighlighted;
    GPButtonStateTransitionView *viewForHighlightState = [[GPButtonStateTransitionView alloc] initWithButton:self state:highlightState];
    [self.superview insertSubview:viewForHighlightState aboveSubview:self];
    self.viewForHighlightState = viewForHighlightState;
    
    UIControlState normalState = self.isSelected ? UIControlStateSelected : UIControlStateNormal;
    GPButtonStateTransitionView *viewForNormalState = [[GPButtonStateTransitionView alloc] initWithButton:self state:normalState];
    viewForNormalState.alpha = 0;
    [self.superview insertSubview:viewForNormalState aboveSubview:self.viewForHighlightState];
    self.viewForNormalState = viewForNormalState;
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState |
                                     UIViewAnimationOptionCurveEaseOut;
    
    [UIView animateWithDuration:kButtonHighlightTransitionDuration
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
                if ([self isSelected] == wasSelectedWhenHighlighted && [self isEnabled] && ![self isHidden])
                {
                    if (self.alpha > 0)
                    {
                        [self animateFromHighlightToNormal];
                    }
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
    
    if (wasHighlighted != [self isHighlighted])
    {
        [self.delegate buttonDidChangedHighlightState:self];
    }
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    GPLogIN();
    [super setUserInteractionEnabled:userInteractionEnabled];
    
    [self updateTitleColor];
    
    GPLogOUT();
}

- (void)updateTitleColor
{
    GPLogIN();
    
    if (self.shouldUpdateTitleColor)
    {
        return;
    }
    
    if ([self isUserInteractionEnabled])
    {
        if ([self isSelected])
        {
            [self setTitleColor:GPCOLOR_BLUE forState:UIControlStateNormal];
            [self setTitleColor:GPCOLOR_ORANGE_HIGHLIGHT forState:UIControlStateHighlighted];
            [self setTitleColor:GPCOLOR_ORANGE_SELECTED forState:UIControlStateSelected];
            [self setTitleColor:GPCOLOR_ORANGE_HIGHLIGHT forState:UIControlStateDisabled];
        }
        else
        {
            [self setTitleColor:GPCOLOR_BLUE forState:UIControlStateNormal];
            [self setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateHighlighted];
            [self setTitleColor:GPCOLOR_ORANGE_SELECTED forState:UIControlStateSelected];
            [self setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateDisabled];
        }
    }
    else
    {
        if ([self isSelected])
        {
            [self setTitleColor:GPCOLOR_ORANGE_HIGHLIGHT forState:UIControlStateNormal];
            [self setTitleColor:GPCOLOR_ORANGE_HIGHLIGHT forState:UIControlStateHighlighted];
            [self setTitleColor:GPCOLOR_ORANGE_HIGHLIGHT forState:UIControlStateSelected];
            [self setTitleColor:GPCOLOR_ORANGE_HIGHLIGHT forState:UIControlStateDisabled];
        }
        else
        {
            [self setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateNormal];
            [self setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateHighlighted];
            [self setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateSelected];
            [self setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateDisabled];
        }
    }
    
    GPLogOUT();
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    [self updateTitleColor];
    
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
    [super setTransform:transform];
    
    self.viewForHighlightState.transform = transform;
    self.viewForNormalState.transform = transform;
}

- (void)connectTo:(GPButton *)button
{
    GPLogIN();
    
    self.connectedButton = button;
    button.connectedButton = self;
    
    GPLogOUT();
}

- (void)setAlpha:(CGFloat)alpha
{
    [super setAlpha:alpha];
    self.viewForHighlightState.alpha = alpha;
    self.viewForNormalState.alpha = alpha;
}

@end
