//
//  GPBaseViewController.h
//  Goopic
//
//  Created by Andrei Marincas on 01/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>


@class GPBaseViewController;


#pragma mark - Base View Controller's view

@interface GPBaseView : UIView
{
    __weak GPBaseViewController *_baseViewController;
}

@property (nonatomic, weak, readonly) GPBaseViewController *baseViewController;

/** Designated Initializer */

- (instancetype)init;

@end


#pragma mark - Base View Controller

@interface GPBaseViewController : UIViewController
{
    BOOL _rotatingInterfaceOrientation;
    
    UIActivityIndicatorView *_activityIndicatorView;
    UILabel *_activityLabel;
    
    BOOL _activityInProgress;
}

@property (nonatomic, readonly, getter = isRotatingInterfaceOrientation) BOOL rotatingInterfaceOrientation;

@property (nonatomic, readonly) GPBaseView *baseView;

/** Designated Initializer */

- (instancetype)init;

/** Methods */

/**
 * Override
 *
 * NOTES:
 *
 * Override this method to set the subviews geometry. Not intended for heavy duty as this gets called pretty often, so don't reload resources and stuff like that, keep it light.
 * If you want to reload/unload resources to refresh the UI then do it in viewWillAppear:/viewDidDisappear: methods, not here.
 *
 * It will be called whenever the view's bounds change, and also before any transition (TO or FROM this view controller).
 */
- (void)updateUI;

@end

@interface GPBaseViewController (ActivityView)

@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, readonly) UILabel *activityLabel;

@property (nonatomic, readonly) BOOL activityInProgress;

// Override. Default value is view's bounds.
- (CGRect)preferredFrameForActivityView;

- (void)showActivity:(GPActivity)activity animated:(BOOL)animated;

// Hide the activity currently in progress
- (void)hideActivityAnimated:(BOOL)animated;

- (void)bringActivityViewToFrontIfActivityInProgress;

@end
