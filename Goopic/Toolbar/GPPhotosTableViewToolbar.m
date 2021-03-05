//
//  GPPhotosTableViewToolbar.m
//  Goopic
//
//  Created by andrei.marincas on 30/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPPhotosTableViewToolbar.h"


static const CGFloat kDateLabelMarginLeft       = 5.0f;
static const CGFloat kDateLabelMarginBottom     = 1.0f;

static const NSTimeInterval kDateFadingDuration = 0.2f;

static const CGFloat kTitleLabelTapPadding      = 80.0f;

static const CGFloat kHitTestEdgeInset          = 40.0f;

static const CGFloat kCameraButtonSize          = 30.0f;


@implementation GPPhotosTableViewToolbar

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        // Custom initialization
        
        self.backgroundColor = GPCOLOR_TRANSLUCENT_BLACK;
        
        GPLine *line = [[GPLine alloc] init];
        line.lineWidth = 0.25f;
        line.linePosition = LinePositionTop;
        line.lineStyle = LineStyleContinuous;
        line.lineColor = GPCOLOR_BLACK;
        [self insertSubview:line atIndex:0];
        self.line = line;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kToolbarButtonFontSize];
        titleLabel.text = @"Photos";
        titleLabel.textColor = GPCOLOR_WHITE_TITLE;
        titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self.titleLabel addGestureRecognizer:tapGr];
        self.titleLabel.userInteractionEnabled = YES;
        
        GPButton *cameraButton = [[GPButton alloc] init];
        [cameraButton setImage:[UIImage imageNamed:@"camera-button.png"] forState:UIControlStateNormal];
        [cameraButton setImage:[UIImage imageNamed:@"camera-button-highlight.png"] forState:UIControlStateHighlighted];
        [cameraButton setImage:[UIImage imageNamed:@"camera-button-highlight.png"] forState:UIControlStateDisabled];
        [cameraButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cameraButton];
        self.cameraButton = cameraButton;
        
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.textAlignment = NSTextAlignmentCenter;
        dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        dateLabel.textColor = GPCOLOR_WHITE_TITLE;
        dateLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:dateLabel];
        self.dateLabel = dateLabel;
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
        [self.delegate toolbarDidTapTitle:self];
    }
    
    GPLogOUT();
}

- (void)updateUI
{
    GPLogIN();
    
    CGFloat yOffset = StatusBarHeightForToolbar();
    
    self.cameraButton.frame = CGRectMake(self.bounds.size.width - kCameraButtonSize - kToolbarButtonsMargin,
                                         yOffset + (self.bounds.size.height - yOffset - kCameraButtonSize) / 2,
                                         kCameraButtonSize, kCameraButtonSize);
    [self bringSubviewToFront:self.cameraButton];
    self.cameraButton.hitTestEdgeInsets = UIEdgeInsetsMake((self.bounds.size.height - self.cameraButton.frame.size.height) / 2, kHitTestEdgeInset,
                                                           (self.bounds.size.height - self.cameraButton.frame.size.height) / 2, kHitTestEdgeInset);
    
    [self.dateLabel sizeToFit];
    self.dateLabel.center = CGPointMake(kDateLabelMarginLeft + _dateLabel.frame.size.width / 2,
                                        self.bounds.size.height - _dateLabel.frame.size.height / 2 - kDateLabelMarginBottom);
    [self bringSubviewToFront:self.dateLabel];
    
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectMake(0, 0, self.titleLabel.frame.size.width + kTitleLabelTapPadding, self.bounds.size.height - yOffset);
    self.titleLabel.center = CGPointMake(self.bounds.size.width / 2, yOffset + (self.bounds.size.height - yOffset) / 2);
    [self bringSubviewToFront:self.titleLabel];
    
    self.line.frame = self.bounds;
    [self.line setNeedsDisplay];
    
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

- (NSString *)date
{
    return [self.dateLabel.text copy];
}

- (void)setDate:(NSString *)dateStr
{
    if (![self.dateLabel.text isEqualToString:dateStr])
    {
        GPLog(@"new left title: %@", dateStr);
        self.dateLabel.text = [dateStr copy];
        [self updateUI];
    }
}

- (void)hideDate:(BOOL)animated
{
    Block hideDateBlock = ^{
        
        self.dateLabel.alpha = 0;
    };
    
    if (animated)
    {
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseInOut;
        
        [UIView animateWithDuration:kDateFadingDuration
                              delay:0
                            options:options
                         animations:hideDateBlock
                         completion:nil];
    }
    else
    {
        [UIView performWithoutAnimation:hideDateBlock];
    }
}

- (void)hideDateAnimated
{
    [self hideDate:YES];
}

- (void)showDate:(BOOL)animated
{
    Block showDateBlock = ^{
        
        self.dateLabel.alpha = 1;
    };
    
    if (animated)
    {
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseInOut;
        
        [UIView animateWithDuration:kDateFadingDuration
                              delay:0
                            options:options
                         animations:showDateBlock
                         completion:nil];
    }
    else
    {
        [UIView performWithoutAnimation:showDateBlock];
    }
}

@end
