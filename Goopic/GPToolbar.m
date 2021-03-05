//
//  GPToolbar.m
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPToolbar.h"

static const CGFloat kToolbarHeight = 70.0f;

static const NSInteger kButtonsCapacity = 10;

static const CGFloat kButtonMinWidth = 40.0f;
static const CGFloat kButtonMinHeight = 40.0f;
static const CGFloat kButtonsSpacing = 14.0f;

static const CGFloat kLeftTitleMargin = 5.0f;

@implementation GPToolbar

- (instancetype)initWithStyle:(GPPosition)style
{
    self = [super init];
    
    if (self)
    {
        // Custom initialization
        
        self.userInteractionEnabled = YES;
        
        _leftButtons = [NSMutableArray arrayWithCapacity:kButtonsCapacity / 2];
        _rightButtons = [NSMutableArray arrayWithCapacity:kButtonsCapacity / 2];
        
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        
        self.style = style;
        
        GPLine *line = [[GPLine alloc] init];
        line.lineWidth = 0.25f;
        line.linePosition = (self.style == GPPositionTop) ? LinePositionBottom : LinePositionTop;
        line.lineStyle = LineStyleContinuous;
        [self insertSubview:line atIndex:0];
        self.line = line;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:20.0f];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *leftTitleLabel = [[UILabel alloc] init];
        leftTitleLabel.textAlignment = NSTextAlignmentCenter;
//        leftTitleLabel.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:18.0f];
//        leftTitleLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-UltraLight" size:18.0f];
//        leftTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
//        leftTitleLabel.font = [UIFont systemFontOfSize:12.5f];
//        leftTitleLabel.font = [UIFont systemFontOfSize:13.0f];
        leftTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
        leftTitleLabel.textColor = [UIColor whiteColor];
//        leftTitleLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1];
        leftTitleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:leftTitleLabel];
        self.leftTitleLabel = leftTitleLabel;
    }
    
    return self;
}

- (void)dealloc
{
    GPLogIN();
    
    // Dealloc code
    
    GPLogOUT();
}

- (NSArray *)buttons
{
    return [_leftButtons arrayByAddingObjectsFromArray:_rightButtons];
}

- (NSInteger)buttonsCount
{
    return [_leftButtons count] + [_rightButtons count];
}

- (UIButton *)buttonWithType:(GPToolbarButtonType)buttonType
{
    for (UIButton *button in [self buttons])
    {
        if (button.tag == buttonType)
        {
            return button;
        }
    }
    
    return nil;
}

- (void)addButtonWithType:(GPToolbarButtonType)buttonType toLeftOrRight:(GPPosition)leftOrRight
{
    if ([self buttonsCount] == kButtonsCapacity)
    {
        GPLogErr(@"Cannot add button %@, too many buttons.", NSStringFromGPToolbarButtonType(buttonType));
        
        GPLogOUT();
        return;
    }
    
    if ([self buttonWithType:buttonType])
    {
        GPLogErr(@"Cannot add button %@, it already exists in this toolbar.", NSStringFromGPToolbarButtonType(buttonType));
        
        GPLogOUT();
        return;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSStringFromGPToolbarButtonType(buttonType) forState:UIControlStateNormal];    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3f] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:19.0f];
//    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f];
    button.titleLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:18.0f];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.tag = buttonType;
    [self addSubview:button];
    
    if (leftOrRight == GPPositionLeft)
    {
        [_leftButtons addObject:button];
    }
    else // GPPositionRight
    {
        [_rightButtons addObject:button];
    }
    
    [self updateUI];
}

- (void)updateUI
{
    GPLogIN();
    
    GPLog(@"toolbar bounds: %@", NSStringFromCGRect(self.bounds));
    GPLog(@"toolbar frame: %@", NSStringFromCGRect(self.frame));
    
    CGFloat yOffset = AppIsInFullScreenMode() ? StatusBarHeight() / 2 : 0;
    
    for (NSInteger i = 0; i < [_leftButtons count]; i++)
    {
        UIButton *button = _leftButtons[i];
        
        [button sizeToFit];
        CGSize buttonSize = CGSizeMake(fmaxf(button.frame.size.width, kButtonMinWidth),
                                       fmaxf(button.frame.size.height, kButtonMinHeight));
        
        button.frame = CGRectMake(kButtonsSpacing + i * (buttonSize.width + kButtonsSpacing),
                                  (self.bounds.size.height - buttonSize.height) / 2 + yOffset,
                                  buttonSize.width,
                                  buttonSize.height);
        [button setNeedsDisplay];
    }
    
    for (NSInteger i = 0; i < [_rightButtons count]; i++)
    {
        UIButton *button = _rightButtons[i];
        
        [button sizeToFit];
        CGSize buttonSize = CGSizeMake(fmaxf(button.frame.size.width, kButtonMinWidth),
                                       fmaxf(button.frame.size.height, kButtonMinHeight));
        
        button.frame = CGRectMake(self.bounds.size.width - (i + 1) * (buttonSize.width + kButtonsSpacing),
                                  (self.bounds.size.height - buttonSize.height) / 2 + yOffset,
                                  buttonSize.width,
                                  buttonSize.height);
        [button setNeedsDisplay];
    }
    
    self.line.frame = self.bounds;
    [self.line setNeedsDisplay];
    
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 + yOffset);
    
    [self.leftTitleLabel sizeToFit];
    
//    self.leftTitleLabel.frame = CGRectIntegral(CGRectInset(self.leftTitleLabel.frame, -1, -1));
//    self.leftTitleLabel.frame = CGRectIntegral(self.leftTitleLabel.frame);
//    self.leftTitleLabel.center = CGPointMake((int)(kLeftTitleMargin + self.leftTitleLabel.frame.size.width / 2 + 1),
//                                             (int)(self.bounds.size.height / 2 + yOffset + 1));
    
    self.leftTitleLabel.center = CGPointMake(kLeftTitleMargin + self.leftTitleLabel.frame.size.width / 2,
                                             self.bounds.size.height / 2 + yOffset);
    
    [self bringSubviewToFront:self.leftTitleLabel];
    [self bringSubviewToFront:self.titleLabel];
    
    [self setNeedsDisplay];
    
    GPLogOUT();
}

+ (CGFloat)preferredHeight
{
    CGFloat height = kToolbarHeight;
    
    if (!AppIsInFullScreenMode())
    {
        height -= StatusBarHeight();
    }
    
    return height;
}

- (void)buttonTapped:(UIButton *)button
{
    GPLogIN();
    
    GPLog(@"button tapped: %lu - %@", (unsigned long)[[self buttons] indexOfObject:button], [button titleForState:UIControlStateNormal]);
    
    GPLogOUT();
}

- (NSString *)title
{
    return [self.titleLabel.text copy];
}

- (void)setTitle:(NSString *)title
{
    if (![self.titleLabel.text isEqualToString:title])
    {
        self.titleLabel.text = [title copy];
        [self updateUI];
    }
}

- (NSString *)leftTitle
{
    return [self.leftTitleLabel.text copy];
}

- (void)setLeftTitle:(NSString *)leftTitle
{
    if (![self.leftTitleLabel.text isEqualToString:leftTitle])
    {
        GPLog(@"new left title: %@", leftTitle);
        self.leftTitleLabel.text = [leftTitle copy];
        [self updateUI];
    }
}

- (void)hideLeftTitle:(BOOL)animated
{
    if (animated)
    {
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState |
                                         UIViewAnimationCurveEaseInOut;
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options:options
                         animations:^{
                             
                             self.leftTitleLabel.alpha = 0;
                             
                         } completion:^(BOOL finished) {
                             
                             self.leftTitleLabel.hidden = YES;
                         }];
    }
    else
    {
        [UIView performWithoutAnimation:^{
            
            self.leftTitleLabel.alpha = 0;
            self.leftTitleLabel.hidden = YES;
        }];
    }
    
}

- (void)hideLeftTitleAnimated
{
    [self hideLeftTitle:YES];
}

- (void)showLeftTitle:(BOOL)animated
{
    self.leftTitleLabel.hidden = NO;
    
    if (animated)
    {
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState |
                                         UIViewAnimationCurveEaseInOut;
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options:options
                         animations:^{
                             
                             self.leftTitleLabel.alpha = 1;
                             
                         } completion:nil];
    }
    else
    {
        [UIView performWithoutAnimation:^{
            
            self.leftTitleLabel.alpha = 1;
        }];
    }
}

@end
