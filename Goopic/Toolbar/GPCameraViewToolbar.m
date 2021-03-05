//
//  GPCameraViewToolbar.m
//  Goopic
//
//  Created by andrei.marincas on 30/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPCameraViewToolbar.h"


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
        
        self.backgroundColor = GPCOLOR_DARK_BLACK;
        
        UIImage *flashIcon = [UIImage imageNamed:@"flash-icon.png"];
        UIImageView *flashImageView = [[UIImageView alloc] initWithImage:flashIcon];
        [self addSubview:flashImageView];
        self.flashImageView = flashImageView;
        
        GPButton *flashAuto = [[GPButton alloc] init];
        [flashAuto setTitleColor:GPCOLOR_BLUE forState:UIControlStateNormal];
        [flashAuto setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateHighlighted];
        [flashAuto setTitleColor:GPCOLOR_ORANGE_SELECTED forState:UIControlStateSelected];
        [flashAuto addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [flashAuto setTitle:@"Auto" forState:UIControlStateNormal];
        flashAuto.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kFlashButtonsFontSize];
        flashAuto.titleLabel.textAlignment = NSTextAlignmentCenter;
        flashAuto.forceHighlight = YES;
        [self addSubview:flashAuto];
        self.flashAutoButton = flashAuto;
        
        GPButton *flashOn = [[GPButton alloc] init];
        [flashOn setTitleColor:GPCOLOR_BLUE forState:UIControlStateNormal];
        [flashOn setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateHighlighted];
        [flashOn setTitleColor:GPCOLOR_ORANGE_SELECTED forState:UIControlStateSelected];
        [flashOn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [flashOn setTitle:@"On" forState:UIControlStateNormal];
        flashOn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kFlashButtonsFontSize];
        flashOn.titleLabel.textAlignment = NSTextAlignmentCenter;
        flashOn.forceHighlight = YES;
        [self addSubview:flashOn];
        self.flashOnButton = flashOn;
        
        GPButton *flashOff = [[GPButton alloc] init];
        [flashOff setTitleColor:GPCOLOR_BLUE forState:UIControlStateNormal];
        [flashOff setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateHighlighted];
        [flashOff setTitleColor:GPCOLOR_ORANGE_SELECTED forState:UIControlStateSelected];
        [flashOff addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [flashOff setTitle:@"Off" forState:UIControlStateNormal];
        flashOff.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kFlashButtonsFontSize];
        flashOff.titleLabel.textAlignment = NSTextAlignmentCenter;
        flashOff.forceHighlight = YES;
        [self addSubview:flashOff];
        self.flashOffButton = flashOff;
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
    
    CGSize flashIconSize = self.flashImageView.image.size;
    self.flashImageView.frame = CGRectMake(10, (self.bounds.size.height - flashIconSize.height) / 2,
                                           flashIconSize.width, flashIconSize.height);
    [self.flashImageView setNeedsDisplay];
    
    CGFloat x = self.flashImageView.frame.origin.x + self.flashImageView.frame.size.width;
    
    [self.flashAutoButton sizeToFit];
    self.flashAutoButton.frame = CGRectMake(x, (self.bounds.size.height - self.flashAutoButton.frame.size.height) / 2,
                                            self.flashAutoButton.frame.size.width, self.flashAutoButton.frame.size.height);
    self.flashAutoButton.hitTestEdgeInsets = GPEdgeInsetsMake(kFlashButtonsSpacing / 2);
    [self.flashAutoButton setNeedsDisplay];
    
    x = x + self.flashAutoButton.frame.size.width + kFlashButtonsSpacing;
    
    [self.flashOnButton sizeToFit];
    self.flashOnButton.frame = CGRectMake(x, (self.bounds.size.height - self.flashOnButton.frame.size.height) / 2,
                                          self.flashOnButton.frame.size.width, self.flashOnButton.frame.size.height);
    self.flashOnButton.hitTestEdgeInsets = GPEdgeInsetsMake(kFlashButtonsSpacing / 2);
    [self.flashOnButton setNeedsDisplay];
    
    x = x + self.flashOnButton.frame.size.width + kFlashButtonsSpacing;
    
    [self.flashOffButton sizeToFit];
    self.flashOffButton.frame = CGRectMake(x, (self.bounds.size.height - self.flashOffButton.frame.size.height) / 2,
                                           self.flashOffButton.frame.size.width, self.flashOffButton.frame.size.height);
    self.flashOffButton.hitTestEdgeInsets = GPEdgeInsetsMake(kFlashButtonsSpacing / 2);
    [self.flashOffButton setNeedsDisplay];
    
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
        
        if (button == self.flashAutoButton)
        {
            flashValue = kCameraFlashAutoValue;
        }
        else if (button == self.flashOnButton)
        {
            flashValue = kCameraFlashOnValue;
        }
        else if (button == self.flashOffButton)
        {
            flashValue = kCameraFlashOffValue;
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:flashValue forKey:kCameraFlashKey];
        [userDefaults synchronize];
        
        // TODO: self.delegate flash selection changed
    }
    
    GPLogOUT();
}

- (void)setButtonsRotation:(CGFloat)angle animated:(BOOL)animated
{
    GPLogIN();
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    
    Block rotateButtons = ^{
        
        self.flashAutoButton.transform = rotation;
        self.flashOnButton.transform = rotation;
        self.flashOffButton.transform = rotation;
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
        [takeButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:takeButton];
        self.takeButton = takeButton;
        
//        self.cancelButton.hidden = YES;
        self.retakeButton.hidden = YES;
        self.useButton.hidden = YES;
    }
    
    return self;
}

- (void)updateUI
{
    GPLogIN();
    
    [self.cancelButton sizeToFit];
    self.cancelButton.frame = CGRectMake(kToolbarButtonsMargin, (self.bounds.size.height - self.cancelButton.frame.size.height) / 2,
                                         self.cancelButton.frame.size.width, self.cancelButton.frame.size.height);
    self.cancelButton.hitTestEdgeInsets = GPEdgeInsetsMake(kButtonHitTestEdgeInset);
    [self.cancelButton setNeedsDisplay];
    
    [self.retakeButton sizeToFit];
    self.retakeButton.frame = CGRectMake(kToolbarButtonsMargin, (self.bounds.size.height - self.retakeButton.frame.size.height) / 2,
                                         self.retakeButton.frame.size.width, self.retakeButton.frame.size.height);
    self.retakeButton.hitTestEdgeInsets = GPEdgeInsetsMake(kButtonHitTestEdgeInset);
    [self.retakeButton setNeedsDisplay];
    
    [self.useButton sizeToFit];
    self.useButton.frame = CGRectMake(self.bounds.size.width - kToolbarButtonsMargin - self.useButton.frame.size.width,
                                      (self.bounds.size.height - self.useButton.frame.size.height) / 2,
                                      self.useButton.frame.size.width, self.useButton.frame.size.height);
    self.useButton.hitTestEdgeInsets = GPEdgeInsetsMake(kButtonHitTestEdgeInset);
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
