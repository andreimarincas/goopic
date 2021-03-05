//
//  GPCameraToPhotoTransition.m
//  Goopic
//
//  Created by andrei.marincas on 08/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPCameraToPhotoTransition.h"
#import "GPCameraViewController.h"
#import "GPPhotoViewController.h"
#import "GPAppDelegate.h"

@implementation GPCameraToPhotoTransition

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.presentationDuration = self.dismissalDuration = 0.45f;
    }
    
    return self;
}

- (void)executePresentationAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    GPPhotoViewController *photoViewController = (GPPhotoViewController *)
        [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    GPAppDelegate *appDelegate = (GPAppDelegate *)[[UIApplication sharedApplication] delegate];
    GPCameraViewController *cameraViewController = appDelegate.cameraViewController;
    
    UIView *container = [transitionContext containerView];
    [photoViewController.view moveToView:container];
    [cameraViewController.view moveToView:container];
    
    if (GPInterfaceOrientation() == UIInterfaceOrientationLandscapeRight)
    {
        cameraViewController.view.center = CGPointMake(container.bounds.size.width / 2, container.bounds.size.height / 2);
        cameraViewController.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    else if (GPInterfaceOrientation() == UIInterfaceOrientationLandscapeLeft)
    {
        cameraViewController.view.center = CGPointMake(container.bounds.size.width / 2, container.bounds.size.height / 2);
        cameraViewController.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    
    [photoViewController updateUI];
    
    photoViewController.view.hidden = NO;
    photoViewController.view.alpha = 1;
    
    [photoViewController.photoView setHidden:YES];
    [cameraViewController.cameraView setHidden:YES];
    
    UIImageView *transportedImageView = [[UIImageView alloc] init];
    transportedImageView.image = [photoViewController.photo largeImage];
    CGRect capturedImageViewFrameInContainer = [container convertRect:cameraViewController.capturedImageView.frame fromView:cameraViewController.view];
    transportedImageView.frame = capturedImageViewFrameInContainer;
    [container addSubview:transportedImageView];
    
    cameraViewController.capturedImageView.hidden = YES;
    
    CGRect actualImageFrame = [photoViewController.photoView frameThatFitsImageSize:[[photoViewController.photo largeImage] size]];
    CGRect toFrame = [container convertRect:actualImageFrame fromView:photoViewController.view];
    
    GPPhotoViewTopToolbar *topToolbar = photoViewController.topToolbar;
    GPPhotoViewBottomToolbar *bottomToolbar = photoViewController.bottomToolbar;
    
    [topToolbar moveToView:container];
    [bottomToolbar moveToView:container];
    
    topToolbar.alpha = 0;
    bottomToolbar.alpha = 0;
    
    [appDelegate.cameraViewSnapshot removeFromSuperview];
    
    CGFloat initialAnimationPercent = 0.25f; // (0,1)
    CGFloat scale = 1.1f;
    
    [UIView animateWithDuration:initialAnimationPercent * self.dismissalDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         transportedImageView.transform = CGAffineTransformMakeScale(scale, scale);
                         
                     } completion:nil];
    
    [UIView animateWithDuration:(1 - initialAnimationPercent) * self.dismissalDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         cameraViewController.view.alpha = 0;
                         transportedImageView.frame = toFrame;
                         
                         topToolbar.alpha = 1;
                         bottomToolbar.alpha = 1;
                         
                     } completion:^(BOOL finished) {
                         
                         [photoViewController.photoView setHidden:NO];
                         [transportedImageView removeFromSuperview];
                         
                         [topToolbar moveToView:photoViewController.view];
                         [bottomToolbar moveToView:photoViewController.view];
                         
                         [photoViewController updateUI];
                         
                         [transitionContext completeTransition:finished];
                     }];
}

- (void)executeDismissalAnimation:(id <UIViewControllerContextTransitioning>)transitionContext
{
    GPCameraViewController *fromViewController = (GPCameraViewController *)
        [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    GPPhotoViewController *toViewController = (GPPhotoViewController *)
        [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *container = [transitionContext containerView];
    [container insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    [toViewController updateUI];
    
    [toViewController.view setAlpha:1];
    [toViewController.view setHidden:NO];
    
    [toViewController.photoView setHidden:YES];
    [fromViewController.cameraView setHidden:YES];
    
    UIImageView *transportedImageView = [fromViewController capturedImageView];
    CGRect capturedImageViewFrameInContainer = [container convertRect:transportedImageView.frame fromView:fromViewController.view];
    [transportedImageView moveToView:container];
    transportedImageView.frame = capturedImageViewFrameInContainer;
    
    CGRect actualImageFrame = [toViewController.photoView frameThatFitsImageSize:[[toViewController.photo largeImage] size]];
    CGRect toFrame = [container convertRect:actualImageFrame fromView:toViewController.view];
    
    GPPhotoViewTopToolbar *topToolbar = toViewController.topToolbar;
    GPPhotoViewBottomToolbar *bottomToolbar = toViewController.bottomToolbar;
    
    [topToolbar moveToView:container];
    [bottomToolbar moveToView:container];
    
    topToolbar.alpha = 0;
    bottomToolbar.alpha = 0;
    
    if (toViewController.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        topToolbar.center = CGPointMake(container.bounds.size.width - topToolbar.frame.size.height / 2, container.bounds.size.height / 2);
        topToolbar.transform = CGAffineTransformMakeRotation(M_PI_2);
        
        bottomToolbar.center = CGPointMake(bottomToolbar.frame.size.height / 2, container.bounds.size.height / 2);
        bottomToolbar.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    else if (toViewController.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        topToolbar.center = CGPointMake(bottomToolbar.frame.size.height / 2, container.bounds.size.height / 2);
        topToolbar.transform = CGAffineTransformMakeRotation(-M_PI_2);
        
        bottomToolbar.center = CGPointMake(container.bounds.size.width - bottomToolbar.frame.size.height / 2, container.bounds.size.height / 2);
        bottomToolbar.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    
    CGFloat initialAnimationPercent = 0.25f; // (0,1)
    CGFloat scale = 1.1f;
    
    [UIView animateWithDuration:initialAnimationPercent * self.dismissalDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         transportedImageView.transform = CGAffineTransformMakeScale(scale, scale);
                         
                     } completion:nil];
    
    [UIView animateWithDuration:(1 - initialAnimationPercent) * self.dismissalDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         fromViewController.view.alpha = 0;
                         transportedImageView.frame = toFrame;
                         
                         topToolbar.alpha = 1;
                         bottomToolbar.alpha = 1;
                         
                     } completion:^(BOOL finished) {
                         
                         [toViewController.photoView setHidden:NO];
                         [transportedImageView removeFromSuperview];
                         
                         [topToolbar moveToView:toViewController.view];
                         [bottomToolbar moveToView:toViewController.view];
                         
                         topToolbar.transform = CGAffineTransformIdentity;
                         bottomToolbar.transform = CGAffineTransformIdentity;
                         [toViewController updateUI];
                         
                         [transitionContext completeTransition:finished];
                     }];
}

@end
