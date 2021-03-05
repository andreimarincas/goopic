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
#import "GPPhotosTableViewToolbar.h"
#import "GPPhotoViewToolbar.h"


#pragma mark - Table to Photo transition

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


#pragma mark - Interactive Table to Photo transition

static const CGFloat kPercentThreshold = 0.35f; // 0..1


@implementation GPInteractiveTableToPhotoTransition

@synthesize viewForInteraction = _viewForInteraction;

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}

- (void)setViewForInteraction:(UIView *)viewForInteraction
{
    if (viewForInteraction != _viewForInteraction)
    {
        if (_viewForInteraction != nil)
        {
            if (_panGestureRecognizer && [_viewForInteraction.gestureRecognizers containsObject:_panGestureRecognizer])
            {
                [_viewForInteraction removeGestureRecognizer:_panGestureRecognizer];
            }
        }
        
        _viewForInteraction = viewForInteraction;
        
        UIPanGestureRecognizer *panGr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanning:)];
        [viewForInteraction addGestureRecognizer:panGr];
        _panGestureRecognizer = panGr;
    }
}

- (void)handlePanning:(UIPanGestureRecognizer *)panGesture
{
    GPLogIN();
    
    GPLog(@"isInteractive: %@", NSStringFromBOOL([self isInteractive]));
    GPLog(@"_context: %@", _context);
    
    CGPoint location = [panGesture locationInView:_viewForInteraction];
    static CGPoint initialLocation;
    
    switch ([panGesture state])
    {
        case UIGestureRecognizerStateBegan:
        {
            GPLog(@"UIGestureRecognizerStateBegan");
            
            if (![self isInteractive])
            {
                _initialPanningLocation = location;
                
                self.reverse = YES;
                self.interactive = YES;
                
                _photoViewTopToolbar = [self.photoViewController topToolbar];
                
                _photosButton = _photoViewTopToolbar.photosButton;
                _photosButtonInitialCenter = _photosButton.center;
                _photoViewTopToolbar.photosButton = nil;
                
                self.photoViewController.topToolbar = nil;
                
                _photoViewBottomToolbar = [self.photoViewController bottomToolbar];
                self.photoViewController.bottomToolbar = nil;
                
                [self.photoViewController dismissViewControllerAnimated:YES completion:nil];
            }
            
            initialLocation = location;
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            GPLog(@"UIGestureRecognizerStateChanged");
            
            if ([self isInteractive] && _context)
            {
                CGFloat percent = [self percentForLocation:location];
                
                if ((percent > 0) && (percent < 1))
                {
                    [self updateWithPercent:percent];
                }
            }
            else
            {
                _initialPanningLocation = location;
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
            GPLog(@"UIGestureRecognizerStateEnded");
            // let it fall through to the next case
            
        case UIGestureRecognizerStateCancelled:
        {
            GPLog(@"UIGestureRecognizerStateCancelled");
            
            if ([self isInteractive] && _context)
            {
                _initialPanningLocation = initialLocation;
                
                CGFloat percent = [self percentForLocation:location];
                GPLog(@"percent: %f", percent);
                
                CGFloat finished = (percent > kPercentThreshold);
                
                [self stopInteractiveTransition:finished];
            }
        }
            break;
            
        default:
            break;
    }
    
    GPLogOUT();
}

- (CGFloat)percentForLocation:(CGPoint)location
{
    CGFloat offset = CGPointDistanceToCGPoint(location, _initialPanningLocation);
    CGFloat percent = 0;
    
    if (offset > 0)
    {
        percent = offset / fminf(_viewForInteraction.bounds.size.height, _viewForInteraction.bounds.size.width);
    }
    
    return percent;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    NSTimeInterval duration = [super transitionDuration:transitionContext];
    
    CGFloat finished = (_percentCompleted > kPercentThreshold);
    
    if (!finished) // we will have to animate back to original state
    {
        return _percentCompleted * (1 - kPercentThreshold) * duration;
    }
    
    return (1 - _percentCompleted) * (1 - kPercentThreshold) * duration;
}

- (CGFloat)completionSpeed
{
    return [self transitionDuration:_context];
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    self.interactive = NO;
}

// assumption: transitionContext is always valid here
- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    GPLogIN();
    
    GPLog(@"isInteractive: %@", NSStringFromBOOL([self isInteractive]));
    GPLog(@"_context: %@", _context);
    
    if (![self isInteractive]) // Caution measure
    {
        GPLog(@"Can't start interactive transition with transition context anymore, the transition is no longer interactive.");
        
        [transitionContext cancelInteractiveTransition];
        [transitionContext completeTransition:NO];
        
        GPLogOUT();
        return;
    }
    
    _context = transitionContext;
    
    _photoViewControllerInitialColor = self.photoViewController.view.backgroundColor;
    self.photoViewController.activityIndicatorView.hidden = YES;
    
    UIView *container = [transitionContext containerView];
    [container insertSubview:self.photosTableViewController.view belowSubview:self.photoViewController.view];
    
    self.photosTableViewController.view.frame = container.bounds; // will also updateUI
    
    _photoViewTopToolbarInitialColor = _photoViewTopToolbar.backgroundColor;
    _photoViewTopToolbar.backgroundColor = [UIColor clearColor];
    _photoViewTopToolbar.cameraButton.hidden = YES; // note: hide any other subviews except photosButton and its disclosure
    
    _photosTableViewToolbar = self.photosTableViewController.toolbar;
    self.photosTableViewController.toolbar = nil;
    [_photosTableViewToolbar updateUI];
    _titleLabel = _photosTableViewToolbar.titleLabel;
    _photosTableViewToolbar.titleLabel = nil;
    _titleLabelInitialCenter = _titleLabel.center;
    [_photosTableViewToolbar moveToView:container];
    
    [_photosButton moveToView:container];
    [_photoViewTopToolbar.disclosureButton moveToView:container];
    
    if (GPInterfaceOrientationIsPortrait())
    {
        _titleLabel.center = _photosButtonInitialCenter;
    }
    
    _titleLabel.alpha = 0;
    
    UIImageView *photoView = [[UIImageView alloc] init];
    photoView.contentMode = UIViewContentModeScaleAspectFill;
    photoView.backgroundColor = [UIColor blackColor];
    photoView.frame = [self.photosTableViewController frameForPhotoAtIndexPath:self.photosTableViewController.selectedIndexPath
                                                                    photoIndex:self.photosTableViewController.selectedPhotoIndex];
    CGSize originalSize = CGSizeMake(self.photoViewController.photo.width, self.photoViewController.photo.height);
    [photoView sizeToFitImageSize:originalSize];
    
    UIView *transportedView = [[UIView alloc] init];
    transportedView.layer.masksToBounds = YES;
    transportedView.backgroundColor = [UIColor blackColor];
    transportedView.frame = [self.photosTableViewController frameForPhotoAtIndexPath:self.photosTableViewController.selectedIndexPath
                                                                          photoIndex:self.photosTableViewController.selectedPhotoIndex];
    [transportedView addSubview:photoView];
    photoView.center = CGPointMake(transportedView.bounds.size.width / 2, transportedView.bounds.size.height / 2);
    
    _transportedViewToFrame = transportedView.frame;
    _photoViewToFrame = photoView.frame;
    
    transportedView.frame = [self.photoViewController.photoView frameThatFitsImageSize:originalSize];
    photoView.frame = transportedView.bounds;
    photoView.image = [self.photoViewController.photo largeImage];
    
    [self.photoViewController.view insertSubview:transportedView belowSubview:_photoViewTopToolbar];
    
    _photoView = photoView;
    _transportedView = transportedView;
    
    _photoViewInitialFrame = _photoView.frame;
    _transportedViewInitialFrame = _transportedView.frame;
    
    self.photoViewController.photoScrollView.hidden = YES;
    self.photoViewController.photoView.hidden = YES;
    
    [_photoViewBottomToolbar moveToView:container];
    _photoViewBottomToolbar.alpha = 1;
    
    UIView *blackOverlay = [[UIView alloc] init];
    blackOverlay.backgroundColor = [UIColor blackColor];
    blackOverlay.frame = container.bounds;
    [_transportedView.superview insertSubview:blackOverlay belowSubview:_transportedView];
    _blackOverlay = blackOverlay;
    
    _selectedCell = (GPPhotoCell *)[self.photosTableViewController selectedCell];
    _selectedPhotoIndex = self.photosTableViewController.selectedPhotoIndex;
    
    [_selectedCell setThumbnailHidden:YES atIndex:_selectedPhotoIndex];
    
    // TODO: Apply yOffset (status bar height is 40 - red when recording, green during phone call)
//    CGFloat yOffset = GPInterfaceOrientationIsPortrait() && (RealStatusBarHeight() > StatusBarHeight()) ? StatusBarHeight() : 0;
    
    GPLogOUT();
}

// percent: 0..1
// note: don't update geometry unless we have a _context already! it's safe to update opacity without this restriction, though.
// Important: Call this only if self.isInteractive && _context != NULL
//
- (void)updateWithPercent:(CGFloat)percent
{
    GPLogIN();
    GPLog(@"percent: %f", percent);
    GPLog(@"isInteractive: %@", NSStringFromBOOL([self isInteractive]));
    GPLog(@"_context: %@", _context);
    
    self.photoViewController.view.backgroundColor = [_photoViewControllerInitialColor colorWithAlphaComponent:1 - percent];
    
    if (GPInterfaceOrientationIsPortrait())
    {
        if (_context)
        {
            _photosButton.center = CGPointMake(_photosButtonInitialCenter.x + percent * (_titleLabelInitialCenter.x - _photosButtonInitialCenter.x),
                                               _photosButtonInitialCenter.y);
            _titleLabel.center = _photosButton.center;
        }
    }
    
    _titleLabel.alpha = percent;
    
    _photosButton.alpha =  1 - percent;
    _photoViewTopToolbar.disclosureButton.alpha = 1 - percent;
    
    _photoViewBottomToolbar.alpha = 1 - percent;
    
    if (_context)
    {
        CGSize transportedViewSize = CGSizeMake(_transportedViewInitialFrame.size.width - percent * (_transportedViewInitialFrame.size.width - _transportedViewToFrame.size.width),
                                                _transportedViewInitialFrame.size.height - percent * (_transportedViewInitialFrame.size.height - _transportedViewToFrame.size.height));
        
        CGPoint transportedViewInitialCenter = CenterOfFrame(_transportedViewInitialFrame);
        CGPoint transportedViewToCenter = CenterOfFrame(_transportedViewToFrame);
        
        CGPoint transportedViewCenter = CGPointMake(transportedViewInitialCenter.x + percent * (transportedViewToCenter.x - transportedViewInitialCenter.x),
                                                    transportedViewInitialCenter.y + percent * (transportedViewToCenter.y - transportedViewInitialCenter.y));
        
        _transportedView.frame = CGRectMake(transportedViewCenter.x - transportedViewSize.width / 2,
                                            transportedViewCenter.y - transportedViewSize.height / 2,
                                            transportedViewSize.width,
                                            transportedViewSize.height);
        
        CGSize photoViewSize = CGSizeMake(_photoViewInitialFrame.size.width - percent * (_photoViewInitialFrame.size.width - _photoViewToFrame.size.width),
                                          _photoViewInitialFrame.size.height - percent * (_photoViewInitialFrame.size.height - _photoViewToFrame.size.height));
        
        CGPoint photoViewInitialCenter = CenterOfFrame(_photoViewInitialFrame);
        CGPoint photoViewToCenter = CenterOfFrame(_photoViewToFrame);
        
        CGPoint photoViewCenter = CGPointMake(photoViewInitialCenter.x + percent * (photoViewToCenter.x - photoViewInitialCenter.x),
                                              photoViewInitialCenter.y + percent * (photoViewToCenter.y - photoViewInitialCenter.y));
        
        _photoView.frame = CGRectMake(photoViewCenter.x - photoViewSize.width / 2,
                                      photoViewCenter.y - photoViewSize.height / 2,
                                      photoViewSize.width,
                                      photoViewSize.height);
    }
    
    _blackOverlay.alpha = 1 - percent;
    
    if (_context)
    {
        [_context updateInteractiveTransition:percent];
    }
    
    _percentCompleted = percent;
    
    GPLogOUT();
}

// transitionFinished: YES if percent completed so far is beyond kPercentThreshold
// Important: Call this only if self.isInteractive && _context != NULL
//
- (void)stopInteractiveTransition:(BOOL)transitionFinished
{
    GPLogIN();
    GPLog(@"transitionFinished: %@", NSStringFromBOOL(transitionFinished));
    GPLog(@"isInteractive: %@", NSStringFromBOOL([self isInteractive]));
    GPLog(@"_context: %@", _context);
    
    UIView *container = [_context containerView];
    
    if (transitionFinished)
    {
        [UIView animateWithDuration: self.dismissalDuration
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             
                             self.photoViewController.view.backgroundColor = [_photoViewControllerInitialColor colorWithAlphaComponent:0];
                             
                             if (GPInterfaceOrientationIsPortrait())
                             {
                                 _photosButton.center = _titleLabelInitialCenter;
                                 _titleLabel.center = _titleLabelInitialCenter;
                             }
                             
                             _titleLabel.alpha = 1;
                             
                             _photosButton.alpha = 0;
                             _photoViewTopToolbar.disclosureButton.alpha = 0;
                             
                             _photoViewBottomToolbar.alpha = 0;
                             
                             _transportedView.frame = _transportedViewToFrame;
                             _photoView.frame = _photoViewToFrame;
                             
                             _blackOverlay.alpha = 0;
                             
                             [_context updateInteractiveTransition:0.99]; // crashes if 1
                             
                         } completion: ^(BOOL finished) {
                             
                             GPLog(@"transitionFinished and completion finished: %@ and %@",
                                   NSStringFromBOOL(transitionFinished), NSStringFromBOOL(finished));
                             
                             self.photoViewController.activityIndicatorView.hidden = NO;
                             
                             _photoViewTopToolbar = nil;
                             
                             [_photosButton removeFromSuperview];
                             _photosButton = nil;
                             
                             [_photoViewBottomToolbar removeFromSuperview];
                             _photoViewBottomToolbar = nil;
                             
                             _photosTableViewToolbar.titleLabel = _titleLabel;
                             _titleLabel = nil;
                             self.photosTableViewController.toolbar = _photosTableViewToolbar;
                             [_photosTableViewToolbar moveToView: self.photosTableViewController.view];
                             _photosTableViewToolbar = nil;
                             
                             [_transportedView removeFromSuperview];
                             _transportedView = nil;
                             _photoView = nil;
                             
                             [_blackOverlay removeFromSuperview];
                             _blackOverlay = nil;
                             
                             [_selectedCell setThumbnailHidden:NO atIndex:_selectedPhotoIndex];
                             _selectedCell = nil;
                             _selectedPhotoIndex = 0;
                             
                             [_context finishInteractiveTransition];
                             [_context completeTransition:YES];
                             
                             _context = nil;
                         }];
    }
    else // animate back to original state
    {
        [UIView animateWithDuration: self.dismissalDuration
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             
                             self.photoViewController.view.backgroundColor = _photoViewControllerInitialColor;
                             
                             if (GPInterfaceOrientationIsPortrait())
                             {
                                 _photosButton.center = _photosButtonInitialCenter;
                                 _titleLabel.center = _photosButtonInitialCenter;
                             }
                             
                             _titleLabel.alpha = 0;
                             
                             _photosButton.alpha = 1;
                             _photoViewTopToolbar.disclosureButton.alpha = 1;
                             
                             _photoViewBottomToolbar.alpha = 1;
                             
                             _transportedView.frame = _transportedViewInitialFrame;
                             _photoView.frame = _photoViewInitialFrame;
                             
                             _blackOverlay.alpha = 1;
                             
                         } completion:^(BOOL finished) {
                             
                             GPLog(@"transitionFinished and completion finished: %@ and %@",
                                   NSStringFromBOOL(transitionFinished), NSStringFromBOOL(finished));
                             
                             self.photoViewController.photoScrollView.hidden = NO;
                             self.photoViewController.photoView.hidden = NO;
                             self.photoViewController.activityIndicatorView.hidden = NO;
                             
                             [_photosButton moveToView:_photoViewTopToolbar];
                             _photoViewTopToolbar.photosButton = _photosButton;
                             _photosButton = nil;
                             [_photoViewTopToolbar.disclosureButton moveToView:_photoViewTopToolbar];
                             _photoViewTopToolbar.cameraButton.hidden = NO;
                             _photoViewTopToolbar.backgroundColor = _photoViewTopToolbarInitialColor;
                             self.photoViewController.topToolbar = _photoViewTopToolbar;
                             _photoViewTopToolbar = nil;
                             
                             [_photoViewBottomToolbar moveToView:self.photoViewController.view];
                             self.photoViewController.bottomToolbar = _photoViewBottomToolbar;
                             _photoViewBottomToolbar = nil;
                             
                             if (GPInterfaceOrientationIsPortrait())
                             {
                                 self.photoViewController.view.transform = CGAffineTransformIdentity;
                                 self.photoViewController.view.frame = container.bounds;
                             }
                             else // landscape
                             {
                                 if (GPInterfaceOrientation() == UIInterfaceOrientationLandscapeLeft)
                                 {
                                     self.photoViewController.view.transform = CGAffineTransformMake(0, -1, 1, 0, 0, 0);
                                     
                                 }
                                 else // landscape right
                                 {
                                     self.photoViewController.view.transform = CGAffineTransformMake(0, 1, -1, 0, 0, 0);
                                 }
                                 
                                 self.photoViewController.view.frame = CGRectMake(0, 0, container.bounds.size.height, container.bounds.size.width);
                             }
                             
                             [_transportedView removeFromSuperview];
                             _transportedView = nil;
                             _photoView = nil;
                             
                             [_blackOverlay removeFromSuperview];
                             _blackOverlay = nil;
                             
                             _photosTableViewToolbar.titleLabel = _titleLabel;
                             _titleLabel = nil;
                             self.photosTableViewController.toolbar = _photosTableViewToolbar;
                             [_photosTableViewToolbar moveToView: self.photosTableViewController.view];
                             _photosTableViewToolbar = nil;
                             
                             [_selectedCell setThumbnailHidden:NO atIndex:_selectedPhotoIndex];
                             _selectedCell = nil;
                             _selectedPhotoIndex = 0;
                             
                             [_context cancelInteractiveTransition];
                             [_context completeTransition:NO];
                             
                             _context = nil;
                         }];
    }
    
    GPLogOUT();
}

@end
