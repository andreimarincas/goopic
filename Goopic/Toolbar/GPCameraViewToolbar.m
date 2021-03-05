//
//  GPCameraViewToolbar.m
//  Goopic
//
//  Created by andrei.marincas on 30/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPCameraViewToolbar.h"

static const CGFloat kFlashIconSize          = 20.0f;
static const CGFloat kFlashIconOverlap       = 16.0f;

static const CGFloat kFlashMargin            = 5.0f;
static const CGFloat kFlashOffsetWhenRotated = 8.0f;

static const CGFloat kFlashButtonWidth       = 60.0f;
static const CGFloat kFlashButtonHeight      = 60.0f;
static const CGFloat kFlashButtonsFontSize   = 13.0f;

static const CGFloat kFlashButtonEdgeInset   = 20.0f;

static const CGFloat kTakeButtonSize         = 50.0f;
static const CGFloat kButtonHitTestEdgeInset = 40.0f;

static const CGFloat kButtonsRotationAnimationDuration = 0.3f;


#pragma mark -
#pragma mark - Camera View Top Toolbar

@implementation GPCameraViewTopToolbar

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        // Custom initialization
        
        self.backgroundColor = CAMERA_VIEW_BACKGROUND_COLOR;
        
        GPLine *line = [[GPLine alloc] init];
        line.lineWidth = 0.25f;
        line.linePosition = LinePositionBottom;
        line.lineStyle = LineStyleContinuous;
        line.lineColor = CAMERA_TOOLBAR_LINE_COLOR;
        [self insertSubview:line atIndex:0];
        self.line = line;
        
        UIImageView *flashIcon = [[UIImageView alloc] init];
        flashIcon.image = [UIImage imageNamed:@"flash.png"];
        [self addSubview:flashIcon];
        self.flashIcon = flashIcon;
        
        GPButton *flashAutoButton = [self createButtonWithTitle:@"Auto"];
        [self addSubview:flashAutoButton];
        self.flashAutoButton = flashAutoButton;
        
        GPButton *flashOnButton = [self createButtonWithTitle:@"On"];
        [self addSubview:flashOnButton];
        self.flashOnButton = flashOnButton;
        
        GPButton *flashOffButton = [self createButtonWithTitle:@"Off"];
        [self addSubview:flashOffButton];
        self.flashOffButton = flashOffButton;
    }
    
    return self;
}

- (GPButton *)createButtonWithTitle:(NSString *)title
{
    GPButton *button = [GPButton buttonWithTitle:title target:self action:@selector(buttonTapped:)];
    [button setTitleColor:CAMERA_VIEW_BUTTON_COLOR forState:UIControlStateNormal];
    [button setTitleColor:CAMERA_VIEW_BUTTON_COLOR_PRESSED forState:UIControlStateHighlighted];
    [button setTitleColor:CAMERA_VIEW_FLASH_SELECTION_COLOR forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kFlashButtonsFontSize];
    button.delegate = self;
    button.forceHighlight = YES;
    
    return button;
}

- (void)selectFlashButtonForValue:(NSString *)value
{
    GPLogIN();
    
    if ([value length] == 0)
    {
        value = kCameraFlashAutoValue;
    }
    
    self.flashAutoButton.selected = [value isEqualToString:kCameraFlashAutoValue];
    self.flashOnButton.selected = [value isEqualToString:kCameraFlashOnValue];
    self.flashOffButton.selected = [value isEqualToString:kCameraFlashOffValue];
    
    GPLogOUT();
}

- (GPButton *)selectedFlashButton
{
    if ([self.flashAutoButton isSelected])
    {
        return self.flashAutoButton;
    }
    
    if ([self.flashOnButton isSelected])
    {
        return self.flashOnButton;
    }
    
    if ([self.flashOffButton isSelected])
    {
        return self.flashOffButton;
    }
    
    return nil;
}

- (void)updateUI
{
    GPLogIN();
    
    CGFloat x = kFlashMargin;
    
    self.flashIcon.frame = CGRectMake(x, (self.bounds.size.height - kFlashIconSize) / 2, kFlashIconSize, kFlashIconSize);
    [self.flashIcon setNeedsDisplay];
    
    x = self.flashIcon.frame.origin.x + kFlashIconSize - kFlashIconOverlap;
    
    if (_buttonsRotationAngle != 0)
    {
        x -= kFlashOffsetWhenRotated;
    }
    
    CGAffineTransform t = self.flashAutoButton.transform;
    self.flashAutoButton.transform = CGAffineTransformIdentity;
    self.flashAutoButton.frame = CGRectMake(x, (self.bounds.size.height - kFlashButtonHeight) / 2, kFlashButtonWidth, kFlashButtonHeight);
    self.flashAutoButton.hitTestEdgeInsets = UIEdgeInsetsMake(kFlashButtonEdgeInset, kFlashIconSize, kFlashButtonEdgeInset, 0);
    self.flashAutoButton.transform = t;
    [self.flashAutoButton setNeedsDisplay];
    
    x = x + self.flashAutoButton.frame.size.width;
    
    t = self.flashOnButton.transform;
    self.flashOnButton.transform = CGAffineTransformIdentity;
    self.flashOnButton.frame = CGRectMake(x, (self.bounds.size.height - kFlashButtonHeight) / 2, kFlashButtonWidth, kFlashButtonHeight);
    self.flashOnButton.hitTestEdgeInsets = UIEdgeInsetsMake(kFlashButtonEdgeInset, 0, kFlashButtonEdgeInset, 0);
    self.flashOnButton.transform = t;
    [self.flashOnButton setNeedsDisplay];
    
    x = x + self.flashOnButton.frame.size.width;
    
    t = self.flashOffButton.transform;
    self.flashOffButton.transform = CGAffineTransformIdentity;
    self.flashOffButton.frame = CGRectMake(x, (self.bounds.size.height - kFlashButtonHeight) / 2, kFlashButtonWidth, kFlashButtonHeight);
    self.flashOffButton.hitTestEdgeInsets = UIEdgeInsetsMake(kFlashButtonEdgeInset, 0, kFlashButtonEdgeInset, 0);
    self.flashOffButton.transform = t;
    [self.flashOffButton setNeedsDisplay];
    
    self.line.frame = self.bounds;
    [self.line setNeedsDisplay];
    
    [self setNeedsDisplay];
    
    GPLogOUT();
}

- (void)buttonTapped:(UIButton *)button
{
    GPLogIN();
    GPLog(@"%@", button);
    
    if (![button isSelected])
    {
        self.flashAutoButton.selected = NO;
        self.flashOnButton.selected = NO;
        self.flashOffButton.selected = NO;
        
        button.selected = YES;
        
        NSString *flashValue;
        
        if (button == self.flashAutoButton) flashValue = kCameraFlashAutoValue;
        else if (button == self.flashOnButton) flashValue = kCameraFlashOnValue;
        else if (button == self.flashOffButton) flashValue = kCameraFlashOffValue;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:flashValue forKey:kCameraFlashKey];
        [userDefaults synchronize];
        
        [self.delegate toolbar:self didSelectButton:(GPButton *)button];
    }
    
    GPLogOUT();
}

- (void)setButtonsRotation:(CGFloat)angle animated:(BOOL)animated
{
    GPLogIN();
    
    if (angle != _buttonsRotationAngle)
    {
        NSTimeInterval duration = kButtonsRotationAnimationDuration;
        
        if (FloorValueWithTwoDecimals(fabsf(angle - _buttonsRotationAngle)) > M_PI_2)
        {
            duration = 2 * kButtonsRotationAnimationDuration;
        }
        
        _buttonsRotationAngle = angle;
        
        CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
        
        Block rotateButtons = ^{
            
            self.flashAutoButton.transform = rotation;
            self.flashOnButton.transform = rotation;
            self.flashOffButton.transform = rotation;
            
            [self updateUI];
        };
        
        if (animated)
        {
            UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut;
            
            [UIView animateWithDuration:duration
                                  delay:0
                                options:options
                             animations:rotateButtons
                             completion:nil];
        }
        else
        {
            [UIView performWithoutAnimation:rotateButtons];
        }
    }
    
    GPLogOUT();
}

#pragma mark - GP Button Delegate

- (void)buttonDidChangedHighlightState:(GPButton *)button
{
    GPLogIN();
    GPLog(@"button: %@, isHighlighted: %@", button, NSStringFromBOOL([button isHighlighted]));
    
    NSString *flash = @"flash.png";
    
    if ([button isHighlighted])
    {
        flash = @"flash-highlight.png";
    }
    
    [self.flashIcon setImage:[UIImage imageNamed:flash]];
    
    GPLogOUT();
}

@end


#pragma mark -
#pragma mark - Camera View Bottom Toolbar

@implementation GPCameraViewBottomToolbar

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        // Custom initialization
        
        self.backgroundColor = CAMERA_VIEW_BACKGROUND_COLOR;
        
        GPLine *line = [[GPLine alloc] init];
        line.lineWidth = 0.25f;
        line.linePosition = LinePositionTop;
        line.lineStyle = LineStyleContinuous;
        line.lineColor = CAMERA_TOOLBAR_LINE_COLOR;
        [self insertSubview:line atIndex:0];
        self.line = line;
        
        GPButton *cancelButton = [self createButtonWithTitle:@"Cancel"];
        [self addSubview:cancelButton];
        self.cancelButton = cancelButton;
        
        GPButton *retakeButton = [self createButtonWithTitle:@"Retake"];
        [self addSubview:retakeButton];
        self.retakeButton = retakeButton;
        
        GPButton *useButton = [self createButtonWithTitle:@"Use"];
        [self addSubview:useButton];
        self.useButton = useButton;
        
        GPButton *takeButton = [GPButton buttonWithImageName:@"take-button.png" target:self action:@selector(buttonTapped:)];
        [self addSubview:takeButton];
        self.takeButton = takeButton;
    }
    
    return self;
}

- (GPButton *)createButtonWithTitle:(NSString *)title
{
    GPButton *button = [GPButton buttonWithTitle:title target:self action:@selector(buttonTapped:)];
    [button setTitleColor:CAMERA_VIEW_BUTTON_COLOR forState:UIControlStateNormal];
    [button setTitleColor:CAMERA_VIEW_BUTTON_COLOR_PRESSED forState:UIControlStateHighlighted];
    
    return button;
}

- (void)updateUI
{
    GPLogIN();
    
    CGAffineTransform t = self.cancelButton.transform;
    self.cancelButton.transform = CGAffineTransformIdentity;
    [self.cancelButton sizeToFit];
    self.cancelButton.frame = CGRectMake(kToolbarButtonsMargin, (self.bounds.size.height - self.cancelButton.frame.size.height) / 2,
                                         self.cancelButton.frame.size.width, self.cancelButton.frame.size.height);
    self.cancelButton.hitTestEdgeInsets = GPEdgeInsetsMake(kButtonHitTestEdgeInset);
    self.cancelButton.transform = t;
    [self.cancelButton setNeedsDisplay];
    
    t = self.retakeButton.transform;
    self.retakeButton.transform = CGAffineTransformIdentity;
    [self.retakeButton sizeToFit];
    self.retakeButton.frame = CGRectMake(kToolbarButtonsMargin, (self.bounds.size.height - self.retakeButton.frame.size.height) / 2,
                                         self.retakeButton.frame.size.width, self.retakeButton.frame.size.height);
    self.retakeButton.hitTestEdgeInsets = GPEdgeInsetsMake(kButtonHitTestEdgeInset);
    self.retakeButton.transform = t;
    [self.retakeButton setNeedsDisplay];
    
    t = self.useButton.transform;
    self.useButton.transform = CGAffineTransformIdentity;
    [self.useButton sizeToFit];
    self.useButton.frame = CGRectMake(self.bounds.size.width - kToolbarButtonsMargin - self.useButton.frame.size.width,
                                      (self.bounds.size.height - self.useButton.frame.size.height) / 2,
                                      self.useButton.frame.size.width, self.useButton.frame.size.height);
    self.useButton.hitTestEdgeInsets = GPEdgeInsetsMake(kButtonHitTestEdgeInset);
    self.useButton.transform = t;
    [self.useButton setNeedsDisplay];
    
    self.takeButton.frame = CGRectMake((self.bounds.size.width - kTakeButtonSize) / 2, (self.bounds.size.height - kTakeButtonSize) / 2,
                                       kTakeButtonSize, kTakeButtonSize);
    self.takeButton.hitTestEdgeInsets = GPEdgeInsetsMake(kButtonHitTestEdgeInset);
    [self bringSubviewToFront:self.takeButton];
    [self.takeButton setNeedsDisplay];
    
    self.line.frame = self.bounds;
    [self.line setNeedsDisplay];
    
    [self setNeedsDisplay];
    
    GPLogOUT();
}

- (void)buttonTapped:(UIButton *)button
{
    GPLogIN();
    GPLog(@"%@", button);
    
    [self.delegate toolbar:self didSelectButton:(GPButton *)button];
    
    GPLogOUT();
}

- (void)setButtonsRotation:(CGFloat)angle animated:(BOOL)animated
{
    GPLogIN();
    
    if (angle != _buttonsRotationAngle)
    {
        NSTimeInterval duration = kButtonsRotationAnimationDuration;
        
        if (FloorValueWithTwoDecimals(fabsf(angle - _buttonsRotationAngle)) > M_PI_2)
        {
            duration = 2 * kButtonsRotationAnimationDuration;
        }
        
        _buttonsRotationAngle = angle;
        
        CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
        
        Block rotateButtons = ^{
            
            self.cancelButton.transform = rotation;
            self.retakeButton.transform = rotation;
            self.useButton.transform = rotation;
        };
        
        if (animated)
        {
            UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut;
            
            [UIView animateWithDuration:duration
                                  delay:0
                                options:options
                             animations:rotateButtons
                             completion:nil];
        }
        else
        {
            [UIView performWithoutAnimation:rotateButtons];
        }
    }
    
    GPLogOUT();
}

@end
