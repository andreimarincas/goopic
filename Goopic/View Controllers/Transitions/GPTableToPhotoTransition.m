//
//  GPTableToPhotoTransition.m
//  Goopic
//
//  Created by Andrei Marincas on 01/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPTableToPhotoTransition.h"
#import "GPPhotosTableViewController.h"
#import "GPPhotoViewController.h"

@implementation GPTableToPhotoTransition

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.presentationDuration = self.dismissalDuration = 0.25f;
    }
    
    return self;
}

- (void)executePresentationAnimation:(id <UIViewControllerContextTransitioning>)transitionContext
{
    GPPhotosTableViewController *fromViewController = (GPPhotosTableViewController *)
        [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    GPPhotoViewController *toViewController = (GPPhotoViewController *)
        [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *container = [transitionContext containerView];
    [container addSubview:toViewController.view];
    
    GPPhotosTableViewToolbar *fromToolbar = fromViewController.toolbar;
    [fromToolbar moveToView:container];
    
    GPPhotoViewTopToolbar *toTopToolbar = toViewController.topToolbar;
    GPButton *photosButton = toTopToolbar.photosButton;
    UILabel *fromTitleLabel = fromToolbar.titleLabel;
    CGPoint photosButtonInitialCenter = photosButton.center;
    [photosButton moveToView:fromToolbar];
    
    if (GPInterfaceOrientationIsPortrait())
    {
        photosButton.center = fromTitleLabel.center;
    }
    
    photosButton.alpha = 0;
    
    GPButton *toDisclosureButton = toTopToolbar.disclosureButton;
    [toDisclosureButton moveToView:fromToolbar];
    toDisclosureButton.alpha = 0;
    
    toViewController.view.alpha = 0;
    toTopToolbar.hidden = YES;
    
    UIImageView *toPhotoView = toViewController.photoView;
    toPhotoView.hidden = YES;
    
    UIImageView *photoView = [[UIImageView alloc] init];
    photoView.contentMode = UIViewContentModeScaleAspectFill;
    photoView.backgroundColor = [UIColor blackColor];
    photoView.image = [toViewController.photo largeImage];
    photoView.frame = [fromViewController frameForPhotoAtIndexPath:fromViewController.selectedIndexPath
                                                        photoIndex:fromViewController.selectedPhotoIndex];
    CGSize originalSize = CGSizeMake(toViewController.photo.width, toViewController.photo.height);
    [photoView sizeToFitImageSize:originalSize];
    
    UIView *transportedView = [[UIView alloc] init];
    transportedView.layer.masksToBounds = YES;
    transportedView.backgroundColor = [UIColor blackColor];
    transportedView.frame = [fromViewController frameForPhotoAtIndexPath:fromViewController.selectedIndexPath
                                                              photoIndex:fromViewController.selectedPhotoIndex];
    [transportedView addSubview:photoView];
    photoView.center = CGPointMake(transportedView.bounds.size.width / 2, transportedView.bounds.size.height / 2);
    
    [container addSubview:transportedView];
    
    CGRect transportedViewFrame = [toPhotoView frameThatFitsImageSize:originalSize];
    
    GPPhotoViewBottomToolbar *toBottomToolbar = toViewController.bottomToolbar;
    [toBottomToolbar moveToView:container];
    toBottomToolbar.alpha = 0;
    
    [container bringSubviewToFront:transportedView];
    [container bringSubviewToFront:fromToolbar];
    [container bringSubviewToFront:toBottomToolbar];
    
    GPPhotoCell *selectedCell = (GPPhotoCell *)[fromViewController selectedCell];
    NSInteger selectedPhotoIndex = fromViewController.selectedPhotoIndex;
    
    [selectedCell setThumbnailHidden:YES atIndex:selectedPhotoIndex];
    
    // Apply yOffset
    CGFloat yOffset = GPInterfaceOrientationIsPortrait() && (RealStatusBarHeight() > StatusBarHeight()) ? StatusBarHeight() : 0;
    
    fromToolbar.center = CGPointMake(fromToolbar.center.x, fromToolbar.center.y + yOffset);
    toBottomToolbar.center = CGPointMake(toBottomToolbar.center.x, toBottomToolbar.center.y + yOffset);
    transportedView.center = CGPointMake(transportedView.center.x, transportedView.center.y + yOffset);
    transportedViewFrame = CGRectMake(transportedViewFrame.origin.x, transportedViewFrame.origin.y + yOffset,
                                      transportedViewFrame.size.width, transportedViewFrame.size.height);
    
    [UIView animateWithDuration:self.presentationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         toViewController.view.alpha = 1;
                         
                         if (GPInterfaceOrientationIsPortrait())
                         {
                             fromTitleLabel.center = photosButtonInitialCenter;
                             photosButton.center = photosButtonInitialCenter;
                         }
                         
                         fromTitleLabel.alpha = 0;
                         photosButton.alpha = 1;
                         toDisclosureButton.alpha = 1;
                         toBottomToolbar.alpha = 1;
                         
                         transportedView.frame = transportedViewFrame;
                         photoView.frame = transportedView.bounds;
                         
                     } completion:^(BOOL finished) {
                         
                         [photosButton moveToView:toTopToolbar];
                         [toDisclosureButton moveToView:toTopToolbar];
                         [toTopToolbar updateUI];
                         toTopToolbar.hidden = NO;
                         toPhotoView.hidden = NO;
                         
                         [toBottomToolbar moveToView:toViewController.view];
                         toBottomToolbar.center = CGPointMake(toBottomToolbar.center.x, toBottomToolbar.center.y - yOffset);
                         
                         [fromToolbar moveToView:fromViewController.view];
                         fromTitleLabel.alpha = 1;
                         [fromToolbar updateUI];
                         
                         [selectedCell setThumbnailHidden:NO atIndex:selectedPhotoIndex];
                         
                         [transportedView removeFromSuperview];
                         
                         [transitionContext completeTransition:finished];
                     }];
}

- (void)executeDismissalAnimation:(id <UIViewControllerContextTransitioning>)transitionContext
{
    GPPhotoViewController *fromViewController = (GPPhotoViewController *)
        [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    GPPhotosTableViewController *toViewController = (GPPhotosTableViewController *)
        [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *container = [transitionContext containerView];
    [container insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    GPPhotoViewTopToolbar *fromTopToolbar = fromViewController.topToolbar;
    [fromTopToolbar moveToView:container];
    
    GPPhotosTableViewToolbar *toToolbar = toViewController.toolbar;
    toToolbar.hidden = YES;
    
    UILabel *toTitleLabel = toToolbar.titleLabel;
    CGPoint toTitleLabelInitialCenter = toTitleLabel.center;
    [toTitleLabel moveToView:fromTopToolbar];
    GPButton *fromPhotosButton = fromTopToolbar.photosButton;
    
    if (GPInterfaceOrientationIsPortrait())
    {
        toTitleLabel.center = fromPhotosButton.center;
    }
    
    toTitleLabel.alpha = 0;
    
    GPButton *fromDisclosureButton = fromTopToolbar.disclosureButton;
    
    UIImageView *fromPhotoView = fromViewController.photoView;
    fromPhotoView.hidden = YES;
    
    UIImageView *photoView = [[UIImageView alloc] init];
    photoView.contentMode = UIViewContentModeScaleAspectFill;
    photoView.backgroundColor = [UIColor blackColor];
    photoView.frame = [toViewController frameForPhotoAtIndexPath:toViewController.selectedIndexPath
                                                      photoIndex:toViewController.selectedPhotoIndex];
    CGSize originalSize = CGSizeMake(fromViewController.photo.width, fromViewController.photo.height);
    [photoView sizeToFitImageSize:originalSize];
    
    UIView *transportedView = [[UIView alloc] init];
    transportedView.layer.masksToBounds = YES;
    transportedView.backgroundColor = [UIColor blackColor];
    transportedView.frame = [toViewController frameForPhotoAtIndexPath:toViewController.selectedIndexPath
                                                            photoIndex:toViewController.selectedPhotoIndex];
    [transportedView addSubview:photoView];
    photoView.center = CGPointMake(transportedView.bounds.size.width / 2, transportedView.bounds.size.height / 2);
    
    CGRect transportedViewFrame = transportedView.frame;
    CGRect photoViewFrame = photoView.frame;
    
    transportedView.frame = [fromPhotoView frameThatFitsImageSize:originalSize];
    photoView.frame = transportedView.bounds;
    photoView.image = [fromViewController.photo largeImage];
    
    [container addSubview:transportedView];
    
    GPPhotoViewBottomToolbar *fromBottomToolbar = fromViewController.bottomToolbar;
    [fromBottomToolbar moveToView:container];
    fromBottomToolbar.alpha = 1;
    
    [container bringSubviewToFront:transportedView];
    [container bringSubviewToFront:fromTopToolbar];
    [container bringSubviewToFront:fromBottomToolbar];
    
    GPPhotoCell *selectedCell = (GPPhotoCell *)[toViewController selectedCell];
    NSInteger selectedPhotoIndex = toViewController.selectedPhotoIndex;
    
    [selectedCell setThumbnailHidden:YES atIndex:selectedPhotoIndex];
    
    // Apply yOffset (status bar height is 40 - red when recording, green during phone call)
    CGFloat yOffset = GPInterfaceOrientationIsPortrait() && (RealStatusBarHeight() > StatusBarHeight()) ? StatusBarHeight() : 0;
    
    fromViewController.view.center = CGPointMake(fromViewController.view.center.x, fromViewController.view.center.y + yOffset);
    fromTopToolbar.center = CGPointMake(fromTopToolbar.center.x, fromTopToolbar.center.y + yOffset);
    fromBottomToolbar.center = CGPointMake(fromBottomToolbar.center.x, fromBottomToolbar.center.y + yOffset);
    transportedView.center = CGPointMake(transportedView.center.x, transportedView.center.y + yOffset);
    transportedViewFrame = CGRectMake(transportedViewFrame.origin.x, transportedViewFrame.origin.y + yOffset,
                                      transportedViewFrame.size.width, transportedViewFrame.size.height);
    
    [UIView animateWithDuration:self.dismissalDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         fromViewController.view.alpha = 0;
                         
                         if (GPInterfaceOrientationIsPortrait())
                         {
                             toTitleLabel.center = toTitleLabelInitialCenter;
                             fromPhotosButton.center = toTitleLabelInitialCenter;
                         }
                         
                         toTitleLabel.alpha = 1;
                         fromPhotosButton.alpha = 0;
                         fromDisclosureButton.alpha = 0;
                         fromBottomToolbar.alpha = 0;
                         
                         transportedView.frame = transportedViewFrame;
                         photoView.frame = photoViewFrame;
                         
                     } completion:^(BOOL finished) {
                         
                         fromPhotosButton.alpha = 1;
                         fromDisclosureButton.alpha = 1;
                         fromPhotoView.hidden = NO;
                         [fromTopToolbar updateUI];
                         [fromTopToolbar moveToView:fromViewController.view];
                         [fromBottomToolbar moveToView:fromViewController.view];
                         
                         [toTitleLabel moveToView:toToolbar];
                         [toToolbar updateUI];
                         toToolbar.hidden = NO;
                         
                         [selectedCell setThumbnailHidden:NO atIndex:selectedPhotoIndex];
                         
                         [transportedView removeFromSuperview];
                         
                         [transitionContext completeTransition:finished];
                     }];
}

@end
