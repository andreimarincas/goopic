//
//  GPPhotoViewToolbar.m
//  Goopic
//
//  Created by andrei.marincas on 30/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPPhotoViewToolbar.h"


static const CGFloat kDisclosureButtonSize = 25.0f;
static const CGFloat kHitTestEdgeInset     = 60.0f;

static const CGFloat kCameraButtonSize     = 30.0f;


#pragma mark -
#pragma mark - Top Toolbar

@implementation GPPhotoViewTopToolbar

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        // Custom initialization
        
        self.backgroundColor = GPTOOLBAR_BACKGROUND_COLOR;
        
        GPLine *line = [[GPLine alloc] init];
        line.lineWidth = 0.25f;
        line.linePosition = LinePositionBottom;
        line.lineStyle = LineStyleContinuous;
        line.lineColor = GPTOOLBAR_LINE_COLOR;
        [self insertSubview:line atIndex:0];
        self.line = line;
        
        GPButton *photosButton = [GPButton buttonWithTitle:@"Photos" target:self action:@selector(buttonTapped:)];
        [self addSubview:photosButton];
        self.photosButton = photosButton;
        
        GPButton *disclosureButton = [GPButton buttonWithImageName:@"disclosure-button.png" target:self action:@selector(buttonTapped:)];
        [self addSubview:disclosureButton];
        self.disclosureButton = disclosureButton;
        
        [self.disclosureButton connectTo:self.photosButton];
        
        GPButton *cameraButton = [GPButton buttonWithImageName:@"camera-button.png" target:self action:@selector(buttonTapped:)];
        [self addSubview:cameraButton];
        self.cameraButton = cameraButton;
    }
    
    return self;
}

- (void)updateUI
{
    GPLogIN();
    
    CGFloat yOffset = StatusBarHeightForToolbar();
    
    self.disclosureButton.frame = CGRectMake(0, yOffset + (self.bounds.size.height - yOffset - kDisclosureButtonSize) / 2,
                                             kDisclosureButtonSize, kDisclosureButtonSize);
    self.disclosureButton.hitTestEdgeInsets = UIEdgeInsetsMake((self.bounds.size.height - kDisclosureButtonSize) / 2, kHitTestEdgeInset,
                                                               (self.bounds.size.height - kDisclosureButtonSize) / 2, kHitTestEdgeInset);
    [self.disclosureButton setNeedsDisplay];
    
    [self.photosButton sizeToFit];
    const CGFloat disclosureOverlap = 0.0f;
    self.photosButton.frame = CGRectMake(self.disclosureButton.frame.origin.x + self.disclosureButton.frame.size.width - disclosureOverlap,
                                         yOffset + (self.bounds.size.height - yOffset - self.photosButton.frame.size.height) / 2,
                                         self.photosButton.frame.size.width, self.photosButton.frame.size.height);
    [self bringSubviewToFront:self.photosButton];
    self.photosButton.hitTestEdgeInsets = UIEdgeInsetsMake((self.bounds.size.height - self.photosButton.frame.size.height) / 2, kHitTestEdgeInset,
                                                           (self.bounds.size.height - self.photosButton.frame.size.height) / 2, kHitTestEdgeInset);
    [self.photosButton setNeedsDisplay];
    
    self.cameraButton.frame = CGRectMake(self.bounds.size.width - kCameraButtonSize - kToolbarButtonsMargin,
                                         yOffset + (self.bounds.size.height - yOffset - kCameraButtonSize) / 2,
                                         kCameraButtonSize, kCameraButtonSize);
    [self bringSubviewToFront:self.cameraButton];
    self.cameraButton.hitTestEdgeInsets = UIEdgeInsetsMake((self.bounds.size.height - self.cameraButton.frame.size.height) / 2, kHitTestEdgeInset,
                                                           (self.bounds.size.height - self.cameraButton.frame.size.height) / 2, kHitTestEdgeInset);
    [self.cameraButton setNeedsDisplay];
    
    self.line.frame = self.bounds;
    [self.line setNeedsDisplay];
    
    [self bringSubviewToFront:self.disclosureButton];
    
    [self setNeedsDisplay];
    
    GPLogOUT();
}

- (void)buttonTapped:(UIButton *)button
{
    GPLogIN();
    GPLog(@"%@", button);
    
    if (button == self.disclosureButton)
    {
        button = self.disclosureButton.connectedButton; // photos button
    }
    
    [self.delegate toolbar:self didSelectButton:button];
    
    GPLogOUT();
}

@end


#pragma mark -
#pragma mark - Bottom Toolbar

@implementation GPPhotoViewBottomToolbar

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        // Custom initialization
        
        self.backgroundColor = GPTOOLBAR_BACKGROUND_COLOR;
        
        GPLine *line = [[GPLine alloc] init];
        line.lineWidth = 0.25f;
        line.linePosition = LinePositionTop;
        line.lineStyle = LineStyleContinuous;
        line.lineColor = GPTOOLBAR_LINE_COLOR;
        [self insertSubview:line atIndex:0];
        self.line = line;
        
        GPButton *searchButton = [GPButton buttonWithTitle:@"Search Google For This Image" target:self action:@selector(buttonTapped:)];
        searchButton.forceHighlight = YES;
        [self addSubview:searchButton];
        self.searchButton = searchButton;
        
        GPButton *cancelButton = [GPButton buttonWithTitle:@"Cancel" target:self action:@selector(buttonTapped:)];
        cancelButton.forceHighlight = YES;
        cancelButton.alpha = 0;
        [self addSubview:cancelButton];
        self.cancelButton = cancelButton;
    }
    
    return self;
}

- (void)updateUI
{
    GPLogIN();
    
    [self.searchButton sizeToFit];
    self.searchButton.frame = self.bounds;
    [self bringSubviewToFront:self.searchButton];
    [self.searchButton setNeedsDisplay];
    
    [self.cancelButton sizeToFit];
    self.cancelButton.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    self.cancelButton.hitTestEdgeInsets = UIEdgeInsetsMake((self.bounds.size.height - self.cancelButton.frame.size.height) / 2, kHitTestEdgeInset,
                                                           (self.bounds.size.height - self.cancelButton.frame.size.height) / 2, kHitTestEdgeInset);
    [self.cancelButton setNeedsDisplay];
    
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

@end
