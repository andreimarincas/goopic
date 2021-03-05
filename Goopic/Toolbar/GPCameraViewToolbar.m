//
//  GPCameraViewToolbar.m
//  Goopic
//
//  Created by andrei.marincas on 30/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPCameraViewToolbar.h"


static const CGFloat kFlashIconSize = 20.0f;
static const CGFloat kFlashMargin = 5.0f;
static const CGFloat kFlashIconOverlap = 3.0f;

static const CGFloat kFlashButtonsFontSize = 13.0f;
static const CGFloat kFlashButtonsSpacing = 20.0f;

static const CGFloat kTakeButtonSize = 50.0f;
static const CGFloat kButtonHitTestEdgeInset = 40.0f;


#pragma mark -
#pragma mark - Camera View Top Toolbar

@implementation GPCameraViewTopToolbar

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        // Custom initialization
        
        GPButton *flashAutoButton = [[GPButton alloc] init];
        [flashAutoButton setTitleColor:GPCOLOR_BLUE forState:UIControlStateNormal];
        [flashAutoButton setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateHighlighted];
        [flashAutoButton setTitleColor:GPCOLOR_ORANGE_SELECTED forState:UIControlStateSelected];
        [flashAutoButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [flashAutoButton setTitle:@"Auto" forState:UIControlStateNormal];
        flashAutoButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kFlashButtonsFontSize];
        flashAutoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        flashAutoButton.forceHighlight = YES;
        [self addSubview:flashAutoButton];
        self.flashAutoButton = flashAutoButton;
        
        UIImageView *flashAutoIcon = [[UIImageView alloc] init];
        flashAutoIcon.image = [UIImage imageNamed:@"flash-icon.png"];
        [self addSubview:flashAutoIcon];
        self.flashAutoIcon = flashAutoIcon;
        
        GPButton *flashOnButton = [[GPButton alloc] init];
        [flashOnButton setTitleColor:GPCOLOR_BLUE forState:UIControlStateNormal];
        [flashOnButton setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateHighlighted];
        [flashOnButton setTitleColor:GPCOLOR_ORANGE_SELECTED forState:UIControlStateSelected];
        [flashOnButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [flashOnButton setTitle:@"On" forState:UIControlStateNormal];
        flashOnButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kFlashButtonsFontSize];
        flashOnButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        flashOnButton.forceHighlight = YES;
        [self addSubview:flashOnButton];
        self.flashOnButton = flashOnButton;
        
        UIImageView *flashOnIcon = [[UIImageView alloc] init];
        flashOnIcon.image = [UIImage imageNamed:@"flash-icon.png"];
        [self addSubview:flashOnIcon];
        self.flashOnIcon = flashOnIcon;
        
        GPButton *flashOffButton = [[GPButton alloc] init];
        [flashOffButton setTitleColor:GPCOLOR_BLUE forState:UIControlStateNormal];
        [flashOffButton setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateHighlighted];
        [flashOffButton setTitleColor:GPCOLOR_ORANGE_SELECTED forState:UIControlStateSelected];
        [flashOffButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [flashOffButton setTitle:@"Off" forState:UIControlStateNormal];
        flashOffButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kFlashButtonsFontSize];
        flashOffButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        flashOffButton.forceHighlight = YES;
        [self addSubview:flashOffButton];
        self.flashOffButton = flashOffButton;
        
        UIImageView *flashOffIcon = [[UIImageView alloc] init];
        flashOffIcon.image = [UIImage imageNamed:@"flash-icon.png"];
        [self addSubview:flashOffIcon];
        self.flashOffIcon = flashOffIcon;
    }
    
    return self;
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

- (void)updateUI
{
    GPLogIN();
    
    CGFloat x = kFlashMargin;
    
    self.flashAutoIcon.frame = CGRectMake(x, (self.bounds.size.height - kFlashIconSize) / 2, kFlashIconSize, kFlashIconSize);
    [self.flashAutoIcon setNeedsDisplay];
    
    x = self.flashAutoIcon.frame.origin.x + kFlashIconSize - kFlashIconOverlap;
    
    if (_buttonsRotationAngle != 0) x -= 5;
    
    CGAffineTransform t = self.flashAutoButton.transform;
    self.flashAutoButton.transform = CGAffineTransformIdentity;
    [self.flashAutoButton sizeToFit];
    self.flashAutoButton.frame = CGRectMake(x, (self.bounds.size.height - self.flashAutoButton.frame.size.height) / 2,
                                            self.flashAutoButton.frame.size.width, self.flashAutoButton.frame.size.height);
    self.flashAutoButton.hitTestEdgeInsets = UIEdgeInsetsMake(kFlashButtonsSpacing / 2, kFlashButtonsSpacing / 2 + kFlashIconSize,
                                                              kFlashButtonsSpacing / 2, kFlashButtonsSpacing / 2);
    self.flashAutoButton.transform = t;
    [self.flashAutoButton setNeedsDisplay];
    
    x = x + self.flashAutoButton.frame.size.width + kFlashButtonsSpacing;
    
    if (_buttonsRotationAngle != 0) x -= 5;
    
    self.flashOnIcon.frame = CGRectMake(x, (self.bounds.size.height - kFlashIconSize) / 2, kFlashIconSize, kFlashIconSize);
    [self.flashOnIcon setNeedsDisplay];
    
    x = x + kFlashIconSize - kFlashIconOverlap - 5;
    
    t = self.flashOnButton.transform;
    self.flashOnButton.transform = CGAffineTransformIdentity;
    [self.flashOnButton sizeToFit];
    self.flashOnButton.frame = CGRectMake(x, (self.bounds.size.height - self.flashOnButton.frame.size.height) / 2,
                                          self.flashOnButton.frame.size.width, self.flashOnButton.frame.size.height);
    self.flashOnButton.hitTestEdgeInsets = UIEdgeInsetsMake(kFlashButtonsSpacing / 2, kFlashButtonsSpacing / 2 + kFlashIconSize,
                                                            kFlashButtonsSpacing / 2, kFlashButtonsSpacing / 2);
    self.flashOnButton.transform = t;
    [self.flashOnButton setNeedsDisplay];
    
    x = x + self.flashOnButton.frame.size.width + kFlashButtonsSpacing - 5;
    
    self.flashOffIcon.frame = CGRectMake(x, (self.bounds.size.height - kFlashIconSize) / 2, kFlashIconSize, kFlashIconSize);
    [self.flashOffIcon setNeedsDisplay];
    
    x = x + kFlashIconSize - kFlashIconOverlap - 5;
    
    t = self.flashOffButton.transform;
    self.flashOffButton.transform = CGAffineTransformIdentity;
    [self.flashOffButton sizeToFit];
    self.flashOffButton.frame = CGRectMake(x, (self.bounds.size.height - self.flashOffButton.frame.size.height) / 2,
                                           self.flashOffButton.frame.size.width, self.flashOffButton.frame.size.height);
    self.flashOffButton.hitTestEdgeInsets = UIEdgeInsetsMake(kFlashButtonsSpacing / 2, kFlashButtonsSpacing / 2 + kFlashIconSize,
                                                             kFlashButtonsSpacing / 2, kFlashButtonsSpacing / 2);
    self.flashOffButton.transform = t;
    [self.flashOffButton setNeedsDisplay];
    
    [self bringSubviewToFront:self.flashAutoIcon];
    [self bringSubviewToFront:self.flashOnIcon];
    [self bringSubviewToFront:self.flashOffIcon];
    
    [self bringSubviewToFront:self.flashAutoButton];
    [self bringSubviewToFront:self.flashOnButton];
    [self bringSubviewToFront:self.flashOffButton];
    
    [self setNeedsDisplay];
    
    GPLogOUT();
}

- (void)buttonTapped:(UIButton *)button
{
    GPLogIN();
    GPLog(@"%@", button);
    
    if (!button.isSelected)
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
        
        [self.delegate toolbar:self didSelectButton:button];
    }
    
    GPLogOUT();
}

- (void)setButtonsRotation:(CGFloat)angle animated:(BOOL)animated
{
    GPLogIN();
    
    if (angle != _buttonsRotationAngle)
    {
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
            [UIView animateWithDuration:0.3f delay:0 options:options animations:rotateButtons completion:nil];
        }
        else
        {
            [UIView performWithoutAnimation:rotateButtons];
        }
    }
    
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
        
        self.backgroundColor = GPCOLOR_DARK_BLACK;
        
        GPButton *cancelButton = [[GPButton alloc] init];
        [cancelButton setTitleColor:GPCOLOR_BLUE forState:UIControlStateNormal];
        [cancelButton setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateHighlighted];
        [cancelButton setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateDisabled];
        [cancelButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kToolbarButtonFontSize];
        cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:cancelButton];
        self.cancelButton = cancelButton;
        
        GPButton *retakeButton = [[GPButton alloc] init];
        [retakeButton setTitleColor:GPCOLOR_BLUE forState:UIControlStateNormal];
        [retakeButton setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateHighlighted];
        [retakeButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [retakeButton setTitle:@"Retake" forState:UIControlStateNormal];
        retakeButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kToolbarButtonFontSize];
        retakeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:retakeButton];
        self.retakeButton = retakeButton;
        
        GPButton *useButton = [[GPButton alloc] init];
        [useButton setTitleColor:GPCOLOR_BLUE forState:UIControlStateNormal];
        [useButton setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateHighlighted];
        [useButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [useButton setTitle:@"Use" forState:UIControlStateNormal];
        useButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kToolbarButtonFontSize];
        useButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:useButton];
        self.useButton = useButton;
        
        GPButton *takeButton = [[GPButton alloc] init];
        [takeButton setImage:[UIImage imageNamed:@"take-button.png"] forState:UIControlStateNormal];
        [takeButton setImage:[UIImage imageNamed:@"take-button-highlight.png"] forState:UIControlStateHighlighted];
        [takeButton setImage:[UIImage imageNamed:@"take-button-highlight.png"] forState:UIControlStateDisabled];
        [takeButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:takeButton];
        self.takeButton = takeButton;
        
//        self.cancelButton.hidden = YES;
        self.retakeButton.hidden = YES;
        self.useButton.hidden = YES;
        
        // TODO: states
    }
    
    return self;
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
    
    [self setNeedsDisplay];
    
    GPLogOUT();
}

- (void)buttonTapped:(UIButton *)button
{
    GPLogIN();
    GPLog(@"%@", button);
    
    [self.delegate toolbar:self didSelectButton:button];
    
    GPLogOUT();
}

- (void)setButtonsRotation:(CGFloat)angle animated:(BOOL)animated
{
    GPLogIN();
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    
    if (animated)
    {
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut;
        
        [UIView animateWithDuration:0.3f
                              delay:0
                            options:options
                         animations:^{
                             
                             self.cancelButton.transform = rotation;
                             
                         } completion:nil];
    }
    else
    {
        [UIView performWithoutAnimation:^{
            self.cancelButton.transform = rotation;
        }];
    }
    
    GPLogOUT();
}

@end
