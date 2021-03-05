//
//  GPPhotoViewToolbar.m
//  Goopic
//
//  Created by andrei.marincas on 30/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPPhotoViewToolbar.h"


static const CGFloat kDisclosureButtonSize = 25.0f;
static const CGFloat kHitTestEdgeInset = 60.0f;


#pragma mark -
#pragma mark - Top Toolbar

@implementation GPPhotoViewTopToolbar

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        // Custom initialization
        
        self.backgroundColor = GPCOLOR_TOOLBAR_BLACK;
        
        GPLine *line = [[GPLine alloc] init];
        line.lineWidth = 0.25f;
        line.linePosition = LinePositionTop;
        line.lineStyle = LineStyleContinuous;
        line.lineColor = GPCOLOR_BLACK;
        [self insertSubview:line atIndex:0];
        self.line = line;
        
        GPButton *photosButton = [[GPButton alloc] init];
        [photosButton setTitle:@"Photos" forState:UIControlStateNormal];
        [photosButton setTitleColor:GPCOLOR_BLUE forState:UIControlStateNormal];
        [photosButton setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateHighlighted];
        [photosButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        photosButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kToolbarButtonFontSize];
        photosButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:photosButton];
        self.photosButton = photosButton;
        
        GPButton *disclosureButton = [[GPButton alloc] init];
        [disclosureButton setImage:[UIImage imageNamed:@"disclosure-button.png"] forState:UIControlStateNormal];
        [disclosureButton setImage:[UIImage imageNamed:@"disclosure-button-highlight.png"] forState:UIControlStateHighlighted];
        [disclosureButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:disclosureButton];
        self.disclosureButton = disclosureButton;
        
        [self.disclosureButton connectTo:self.photosButton];
        
        GPButton *cameraButton = [[GPButton alloc] init];
        [cameraButton setTitle:@"Camera" forState:UIControlStateNormal];
        [cameraButton setTitleColor:GPCOLOR_BLUE forState:UIControlStateNormal];
        [cameraButton setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateHighlighted];
        [cameraButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cameraButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kToolbarButtonFontSize];
        cameraButton.titleLabel.textAlignment = NSTextAlignmentCenter;
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
    
    [self.cameraButton sizeToFit];
    self.cameraButton.frame = CGRectMake(self.bounds.size.width - self.cameraButton.frame.size.width - kToolbarButtonsMargin,
                                         yOffset + (self.bounds.size.height - yOffset - self.cameraButton.frame.size.height) / 2,
                                         self.cameraButton.frame.size.width, self.cameraButton.frame.size.height);
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
        
        self.backgroundColor = GPCOLOR_TOOLBAR_BLACK;
        
        GPLine *line = [[GPLine alloc] init];
        line.lineWidth = 0.25f;
        line.linePosition = LinePositionBottom;
        line.lineStyle = LineStyleContinuous;
        line.lineColor = GPCOLOR_BLACK;
        [self insertSubview:line atIndex:0];
        self.line = line;
        
        GPButton *searchButton = [[GPButton alloc] init];
        [searchButton setTitle:@"Search Google For This Image" forState:UIControlStateNormal];
        [searchButton setTitleColor:GPCOLOR_BLUE forState:UIControlStateNormal];
        [searchButton setTitleColor:GPCOLOR_BLUE_HIGHLIGHT forState:UIControlStateHighlighted];
        [searchButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        searchButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kToolbarButtonFontSize];
        searchButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        searchButton.forceHighlight = YES;
        [self addSubview:searchButton];
        self.searchButton = searchButton;
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
