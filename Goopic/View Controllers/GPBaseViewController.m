//
//  GPBaseViewController.m
//  Goopic
//
//  Created by Andrei Marincas on 01/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPBaseViewController.h"
#import "GPBaseViewController+Private.h"

#pragma mark -
#pragma mark - Base Controller's View

@implementation GPBaseView

#pragma mark - Init / Dealloc

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self initialize];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self initialize];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    GPLogIN();
    
    // Custom initialization
    
    GPLogOUT();
}

- (void)dealloc
{
    GPLogIN();
    
    // Dealloc code
    
    GPLogOUT();
}

#pragma mark - Geometry Updates

- (void)setBounds:(CGRect)bounds
{
    GPLogIN();
    [super setBounds:bounds];
    
    // Call updateUI if NOT rotating interface orientation, otherwise let the base view controller updateUI in the animation block
    if (!self.baseViewController.isRotatingInterfaceOrientation)
    {
        [self.baseViewController updateBaseUI];
    }
    
    GPLogOUT();
}

- (void)setFrame:(CGRect)frame
{
    GPLogIN();
    [super setFrame:frame];
    
    // Call updateUI if NOT rotating interface orientation, otherwise let the base view controller updateUI in the animation block
    if (!self.baseViewController.isRotatingInterfaceOrientation)
    {
        [self.baseViewController updateBaseUI];
    }
    
    GPLogOUT();
}

@end


#pragma mark -
#pragma mark - Base View Controller

@implementation GPBaseViewController

#pragma mark - Init / Dealloc

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}

- (void)dealloc
{
    GPLogIN();
    
    // Dealloc code
    
    GPLogOUT();
}

#pragma mark - View Lifecycle

- (void)loadView
{
    GPLogIN();
    [super loadView];
    
    GPBaseView *baseView = [[GPBaseView alloc] init];
    baseView.frame = [[UIScreen mainScreen] bounds];
    baseView.baseViewController = self;
    self.view = baseView;
    
    GPLogOUT();
}

- (void)viewWillAppear:(BOOL)animated
{
    GPLogIN();
    GPLog(@"%@", [self description]);
    
    // Ensure the updateUI is called because view's bounds may never change
    [self updateBaseUI];
    
    GPLogOUT();
}

#pragma mark - Interface Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    _rotatingInterfaceOrientation = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self updateBaseUI];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    _rotatingInterfaceOrientation = NO;
}

#pragma mark - Base View

- (GPBaseView *)baseView
{
    return (GPBaseView *)self.view;
}

#pragma mark - Interface Update

- (void)updateUI
{
    self.activityIndicatorView.frame = [self preferredFrameForActivityView];
    [self.activityIndicatorView setNeedsDisplay];
    
    [self.activityLabel sizeToFit];
    const CGFloat activityLabelOffsetY = 50.0f;
    self.activityLabel.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2 - activityLabelOffsetY);
    [self.activityLabel setNeedsDisplay];
    
    [self.view setNeedsLayout];
    [self.view setNeedsDisplay];
}

@end


#pragma mark -
#pragma mark - Base View Controller (Activity View)

static const NSTimeInterval kActivityViewAnimationDuration = 0.2f;

@implementation GPBaseViewController (ActivityView)

- (UIActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView)
    {
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicatorView.hidesWhenStopped = NO;
        activityIndicatorView.userInteractionEnabled = NO;
        activityIndicatorView.backgroundColor = GPCOLOR_TRANSLUCENT_BLACK;
        activityIndicatorView.alpha = 0;
        [self.view addSubview:activityIndicatorView];
        _activityIndicatorView = activityIndicatorView;
    }
    
    return _activityIndicatorView;
}

- (UILabel *)activityLabel
{
    if (!_activityLabel)
    {
        UILabel *activityLabel = [[UILabel alloc] init];
        activityLabel.userInteractionEnabled = NO;
        activityLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
        activityLabel.textColor = GPCOLOR_WHITE_TITLE;
        activityLabel.textAlignment = NSTextAlignmentCenter;
        activityLabel.alpha = 0;
        [self.view addSubview:activityLabel];
        _activityLabel = activityLabel;
    }
    
    return _activityLabel;
}

- (CGRect)preferredFrameForActivityView
{
    return self.view.bounds;
}

- (BOOL)activityInProgress
{
    return _activityInProgress;
}

- (void)setActivityInProgress:(BOOL)activityInProgress animated:(BOOL)animated
{
    if (_activityInProgress != activityInProgress)
    {
        _activityInProgress = activityInProgress;
        
        [self updateBaseUI];
        
        if (activityInProgress)
        {
            [self.activityIndicatorView startAnimating];
        }
        else
        {
            [self.activityIndicatorView stopAnimating];
        }
        
        Block showActivityBlock = ^{
            
            self.activityIndicatorView.alpha = activityInProgress ? 1 : 0;
            self.activityLabel.alpha = activityInProgress ? 1 : 0;
        };
        
        if (animated)
        {
            UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear;
            
            [UIView animateWithDuration:kActivityViewAnimationDuration
                                  delay:0
                                options:options
                             animations:showActivityBlock
                             completion:nil];
        }
        else
        {
            [UIView performWithoutAnimation:showActivityBlock];
        }
    }
}

- (void)showActivity:(GPActivity)activity animated:(BOOL)animated
{
    GPLogIN();
    
    switch (activity)
    {
        case GPActivityProcessingImage:
        {
            self.activityLabel.text = @"Processing image...";
        }
            break;
            
        default:
        {
            self.activityLabel.text = @"";
        }
            break;
    }
    
    [self setActivityInProgress:YES animated:animated];
    
    GPLogOUT();
}

// Hide the activity currently in progress
- (void)hideActivityAnimated:(BOOL)animated
{
    GPLogIN();
    
    [self setActivityInProgress:NO animated:animated];
    
    GPLogOUT();
}

- (void)bringActivityViewToFrontIfActivityInProgress
{
    if (self.activityInProgress)
    {
        [self.view bringSubviewToFront:self.activityIndicatorView];
        [self.view bringSubviewToFront:self.activityLabel];
    }
}

@end
