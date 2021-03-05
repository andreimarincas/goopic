//
//  GPBaseViewController.m
//  Goopic
//
//  Created by Andrei Marincas on 01/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPBaseViewController.h"


static const NSTimeInterval kStatusBarUpdateAnimationDuration = 0.2f;

static CGFloat _lastStatusBarHeightWhenVisible;


@interface GPBaseView (Private)

- (void)setBaseViewController:(GPBaseViewController *)baseViewController;

@end

@interface GPBaseViewController (Private)

- (void)updateBaseUI;

@end


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

#pragma mark - Base View Controller

- (void)setBaseViewController:(GPBaseViewController *)baseViewController
{
    _baseViewController = baseViewController;
}

#pragma mark - Geometry Updates

- (void)setBounds:(CGRect)bounds
{
    GPLogIN();
    
    if ([self.baseViewController isRotatingInterfaceOrientation])
    {
        [super setBounds:bounds];
    }
    else
    {
        [UIView performWithoutAnimation:^{
            [super setBounds:bounds];
            
            // Call updateUI only if NOT rotating interface orientation,
            // otherwise let the base view controller updateUI in the animation block for interface orientation change
            [self.baseViewController updateBaseUI];
        }];
    }
    
    GPLogOUT();
}

- (void)setFrame:(CGRect)frame
{
    GPLogIN();
    
    if ([self.baseViewController isRotatingInterfaceOrientation])
    {
        [super setFrame:frame];
    }
    else
    {
        [UIView performWithoutAnimation:^{
            [super setFrame:frame];
            
            // Call updateUI only if NOT rotating interface orientation,
            // otherwise let the base view controller updateUI in the animation block for interface orientation change
            [self.baseViewController updateBaseUI];
        }];
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
    GPLogIN();
    self = [super init];
    
    if (self)
    {
        // Custom initialization
    }
    
    GPLogOUT();
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
    
    // Ensure the updateUI is called because view's bounds may never change.
    // Also an assurance before any view controller transition.
    [self updateBaseUI];
    
    GPLogOUT();
}

- (void)viewDidDisappear:(BOOL)animated
{
    GPLogIN();
    [super viewDidDisappear:animated];
    
    // safety
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    GPLogOUT();
}

#pragma mark - Interface Orientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    _rotatingInterfaceOrientation = YES;
    
    if (![[UIApplication sharedApplication] isStatusBarHidden])
    {
        _lastStatusBarHeightWhenVisible = RealStatusBarHeight();
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    GPLogIN();
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self updateBaseUI];
    
    if (_lastStatusBarHeightWhenVisible == StatusBarHeight())
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    GPLogOUT();
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    _rotatingInterfaceOrientation = NO;
    
    if (_lastStatusBarHeightWhenVisible > StatusBarHeight()) // status bar height is 40 (red when recording, green during phone call)
    {
        [UIView animateWithDuration:kStatusBarUpdateAnimationDuration
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             [self setNeedsStatusBarAppearanceUpdate];
                             
                         } completion:nil];
    }
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
    {
        return YES;
    }
    
    return NO;
}

#pragma mark - Base View

- (GPBaseView *)baseView
{
    return (GPBaseView *)self.view;
}

#pragma mark - Interface Update

- (void)updateUI
{
    self.activityIndicatorView.frame = [self preferredActivityViewFrame];
    self.activityIndicatorView.backgroundColor = [self preferredActivityViewBackgroundColor];
    [self.activityIndicatorView setNeedsDisplay];
    
    [self.activityLabel sizeToFit];
    const CGFloat activityLabelOffsetY = 50.0f;
    self.activityLabel.center = CGPointMake(self.activityIndicatorView.center.x,
                                            self.activityIndicatorView.center.y - activityLabelOffsetY);
    [self.activityLabel setNeedsDisplay];
    
    [self.view setNeedsLayout];
    [self.view setNeedsDisplay];
}

- (void)updateBaseUI
{
    [self updateUI];
    [self bringActivityViewToFrontIfActivityInProgress];
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
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]
                                                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicatorView.hidesWhenStopped = NO;
        activityIndicatorView.userInteractionEnabled = NO;
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

- (CGRect)preferredActivityViewFrame
{
    return self.view.bounds;
}

- (UIColor *)preferredActivityViewBackgroundColor
{
    return GPCOLOR_TRANSLUCENT_DARK;
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
            self.activityLabel.text = @"Processing image..."; break;
            
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


#pragma mark -
#pragma mark - Base View Controller (Alert View)

@implementation GPBaseViewController (AlertView)

- (UIAlertView *)alertView
{
    return _alertView;
}

- (void)showAlert:(UIAlertView *)alertView
{
    if (!_alertView)
    {
        _alertView = alertView;
        
        alertView.delegate = self;
        
        // Display the alert view on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [alertView show];
        });
    }
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == _alertView)
    {
        _alertView = nil;
    }
}

@end


#pragma mark -
#pragma mark - Base View Controller (Notifications)

@implementation GPBaseViewController (Notifications)

- (void)appWillResignActive
{
    if ([self.presentedViewController isKindOfClass:[GPBaseViewController class]])
    {
        [(GPBaseViewController *)self.presentedViewController appWillResignActive];
    }
}

- (void)appDidBecomeActive
{
    if ([self.presentedViewController isKindOfClass:[GPBaseViewController class]])
    {
        [(GPBaseViewController *)self.presentedViewController appDidBecomeActive];
    }
    
    [UIView animateWithDuration:kStatusBarUpdateAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         
                         [self setNeedsStatusBarAppearanceUpdate];
                         
                     } completion:nil];
}

- (void)appDidEnterBackground
{
    if ([self.presentedViewController isKindOfClass:[GPBaseViewController class]])
    {
        [(GPBaseViewController *)self.presentedViewController appDidEnterBackground];
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)appWillEnterForeground
{
    if ([self.presentedViewController isKindOfClass:[GPBaseViewController class]])
    {
        [(GPBaseViewController *)self.presentedViewController appWillEnterForeground];
    }
}

@end
