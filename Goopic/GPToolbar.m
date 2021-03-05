//
//  GPToolbar.m
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPToolbar.h"
#import "GPResponsiveButton.h"


static const NSInteger      kButtonsCapacity        = 10;

static const CGFloat        kButtonMinWidth         = 40.0f;
static const CGFloat        kButtonMinHeight        = 40.0f;
static const CGFloat        kButtonsSpacing         = 14.0f;

static const CGFloat        kDateLabelMarginLeft    = 5.0f;
static const CGFloat        kDateLabelMarginBottom  = 1.0f;

static const NSTimeInterval kDateFadingDuration     = 0.2f;

static const CGFloat        kTitleLabelTapPadding   = 80.0f;


@implementation GPToolbar

- (instancetype)initWithStyle:(GPPosition)style
{
    self = [super init];
    
    if (self)
    {
        // Custom initialization
        
        _leftButtons = [NSMutableArray arrayWithCapacity:kButtonsCapacity / 2];
        _rightButtons = [NSMutableArray arrayWithCapacity:kButtonsCapacity / 2];
        
        self.backgroundColor = [COLOR_BLACK colorWithAlphaComponent:0.8];
        self.style = style;
        
        GPLine *line = [[GPLine alloc] init];
        line.lineWidth = 0.25f;
        line.linePosition = (self.style == GPPositionTop) ? LinePositionBottom : LinePositionTop;
        line.lineStyle = LineStyleContinuous;
        line.lineColor = COLOR_BLACK;
        [self insertSubview:line atIndex:0];
        self.line = line;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.hidden = YES;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self.titleLabel addGestureRecognizer:tapGr];
        self.titleLabel.userInteractionEnabled = YES;
    }
    
    return self;
}

- (void)dealloc
{
    GPLogIN();
    
    // Dealloc code
    
    GPLogOUT();
}

- (void)handleTap:(UITapGestureRecognizer *)tapGr
{
    GPLogIN();
    
    if (tapGr.view == self.titleLabel)
    {
        [self.delegate toolbar:self didTapTitle:self.titleLabel];
    }
    
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
    
    if (_middleButton && (_middleButton.tag == buttonType))
    {
        return _middleButton;
    }
    
    if (_backButton && (_backButton.tag == buttonType))
    {
        return _backButton;
    }
    
    return nil;
}

- (void)addButtonWithType:(GPToolbarButtonType)buttonType toLeftOrRight:(GPPosition)leftOrRight
{
    GPLogIN();
    
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
    
    GPLogOUT();
}

- (UIButton *)middleButton
{
    if (!_middleButton)
    {
        UIButton *button = [GPResponsiveButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:COLOR_BLUE forState:UIControlStateNormal];
        [button setTitleColor:[COLOR_BLUE colorWithAlphaComponent:0.3f] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:button];
        
        _middleButton = button;
    }
    
    return _middleButton;
}

- (UIButton *)backButton
{
    if (!_backButton)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitleColor:COLOR_BLUE forState:UIControlStateNormal];
        [button setTitleColor:[COLOR_BLUE colorWithAlphaComponent:0.3f] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:button];
        
        _backButton = button;
    }
    
    return _backButton;
}

- (void)setMiddleButtonType:(GPToolbarButtonType)buttonType
{
    GPLogIN();
    
    if ([self buttonWithType:buttonType])
    {
        GPLogErr(@"Cannot set middle button type to %@, there already is another button with this type in this toolbar.",
                 NSStringFromGPToolbarButtonType(buttonType));
        
        GPLogOUT();
        return;
    }
    
    [self.middleButton setTitle:NSStringFromGPToolbarButtonType(buttonType) forState:UIControlStateNormal];
    self.middleButton.tag = buttonType;
    
    GPLogOUT();
}

- (void)setBackButtonType:(GPToolbarButtonType)buttonType
{
    GPLogIN();
    
    if ([self buttonWithType:buttonType])
    {
        GPLogErr(@"Cannot set back button type to %@, there already is another button with this type in this toolbar.",
                 NSStringFromGPToolbarButtonType(buttonType));
        
        GPLogOUT();
        return;
    }
    
    [self.backButton setTitle:NSStringFromGPToolbarButtonType(buttonType) forState:UIControlStateNormal];
    self.backButton.tag = buttonType;
    
    GPLogOUT();
}

- (void)updateUI
{
    GPLogIN();
    
    GPLog(@"toolbar bounds: %@", NSStringFromCGRect(self.bounds));
    GPLog(@"toolbar frame: %@", NSStringFromCGRect(self.frame));
    
    CGFloat yOffset = 0;
    
    if (self.style == GPPositionTop)
    {
        yOffset = AppIsInFullScreenMode() ? StatusBarHeight() : 0;
    }
    
    for (NSInteger i = 0; i < [_leftButtons count]; i++)
    {
        UIButton *button = _leftButtons[i];
        
        [button sizeToFit];
        CGSize buttonSize = CGSizeMake(fmaxf(button.frame.size.width, kButtonMinWidth),
                                       fmaxf(button.frame.size.height, kButtonMinHeight));
        
        button.frame = CGRectMake(kButtonsSpacing + i * (buttonSize.width + kButtonsSpacing),
                                  yOffset + (self.bounds.size.height - yOffset - buttonSize.height) / 2,
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
                                  yOffset + (self.bounds.size.height - yOffset + buttonSize.height) / 2,
                                  buttonSize.width,
                                  buttonSize.height);
        [button setNeedsDisplay];
    }
    
    if (_middleButton)
    {
        _middleButton.frame = CGRectMake(0, yOffset, self.bounds.size.width, self.bounds.size.height - yOffset);
        [self bringSubviewToFront:_middleButton];
    }
    
    if (_backButton)
    {
        [_backButton sizeToFit];
        CGSize buttonSize = CGSizeMake(fmaxf(_backButton.frame.size.width, kButtonMinWidth),
                                       fmaxf(_backButton.frame.size.height, kButtonMinHeight));
        _backButton.frame = CGRectMake(kButtonsSpacing, yOffset + (self.bounds.size.height - yOffset - buttonSize.height) / 2,
                                       buttonSize.width, buttonSize.height);
        [self bringSubviewToFront:_backButton];
    }
    
    if (_dateLabel)
    {
        [_dateLabel sizeToFit];
        _dateLabel.center = CGPointMake(kDateLabelMarginLeft + _dateLabel.frame.size.width / 2,
                                        self.bounds.size.height - _dateLabel.frame.size.height / 2 - kDateLabelMarginBottom);
        [self bringSubviewToFront:_dateLabel];
    }
    
    [self.titleLabel sizeToFit];
    NSLog(@"title label frame: %@", NSStringFromCGRect(self.titleLabel.frame));
    self.titleLabel.frame = CGRectMake(0, 0, self.titleLabel.frame.size.width + kTitleLabelTapPadding, self.bounds.size.height - yOffset);
    NSLog(@"title label frame: %@", NSStringFromCGRect(self.titleLabel.frame));
    self.titleLabel.center = CGPointMake(self.bounds.size.width / 2, yOffset + (self.bounds.size.height - yOffset) / 2);
    NSLog(@"title label frame: %@", NSStringFromCGRect(self.titleLabel.frame));
    [self bringSubviewToFront:self.titleLabel];
    
    self.titleLabel.hidden = ([self.titleLabel.text length] == 0);
    
    self.line.frame = self.bounds;
    [self.line setNeedsDisplay];
    
    [self setNeedsDisplay];
    
    GPLogOUT();
}

- (CGFloat)preferredHeight
{
    CGFloat height = kToolbarHeight;
    
//    if ((self.style == GPPositionTop) && AppIsInFullScreenMode())
    if (AppIsInFullScreenMode())
    {
        height += StatusBarHeight();
    }
    
    return height;
}

- (void)buttonTapped:(UIButton *)button
{
    GPLogIN();
    
    if (button == _middleButton)
    {
        GPLog(@"middle button tapped: %@", [button titleForState:UIControlStateNormal]);
    }
    else if (button == _backButton)
    {
        GPLog(@"back button tapped: %@", [button titleForState:UIControlStateNormal]);
    }
    else
    {
        GPLog(@"button tapped: %lu - %@", (unsigned long)[[self buttons] indexOfObject:button],
              [button titleForState:UIControlStateNormal]);
    }
    
    [self.delegate toolbar:self didSelectButtonWithType:(GPToolbarButtonType)button.tag];
    
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

- (UILabel *)dateLabel
{
    if (!_dateLabel)
    {
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
        dateLabel.textColor = [UIColor whiteColor];
        dateLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:dateLabel];
        _dateLabel = dateLabel;
    }
    
    return _dateLabel;
}

- (NSString *)date
{
    return [self.dateLabel.text copy];
}

- (void)setDate:(NSString *)leftTitle
{
    if (![self.dateLabel.text isEqualToString:leftTitle])
    {
        GPLog(@"new left title: %@", leftTitle);
        self.dateLabel.text = [leftTitle copy];
        [self updateUI];
    }
}

- (void)hideDate:(BOOL)animated
{
    if (animated)
    {
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState |
                                         UIViewAnimationCurveEaseInOut;
        
        [UIView animateWithDuration:kDateFadingDuration
                              delay:0
                            options:options
                         animations:^{
                             
                             self.dateLabel.alpha = 0;
                             
                         } completion:^(BOOL finished) {
                             
                             self.dateLabel.hidden = YES;
                         }];
    }
    else
    {
        [UIView performWithoutAnimation:^{
            
            self.dateLabel.alpha = 0;
            self.dateLabel.hidden = YES;
        }];
    }
    
}

- (void)hideDateAnimated
{
    [self hideDate:YES];
}

- (void)showDate:(BOOL)animated
{
    self.dateLabel.hidden = NO;
    
    if (animated)
    {
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState |
                                         UIViewAnimationCurveEaseInOut;
        
        [UIView animateWithDuration:kDateFadingDuration
                              delay:0
                            options:options
                         animations:^{
                             
                             self.dateLabel.alpha = 1;
                             
                         } completion:nil];
    }
    else
    {
        [UIView performWithoutAnimation:^{
            
            self.dateLabel.alpha = 1;
        }];
    }
}

@end
