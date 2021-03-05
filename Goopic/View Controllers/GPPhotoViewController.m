//
//  GPPhotoViewController.m
//  Goopic
//
//  Created by andrei.marincas on 27/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPPhotoViewController.h"
#import "GPCameraViewController.h"
#import "GPSearchEngine.h"
#import "GPFadeTransition.h"
#import "GPCameraToPhotoTransition.h"

@implementation GPPhotoViewController

@synthesize photoView = _photoView;
@synthesize photoScrollView = _photoScrollView;

#pragma mark - Init / Dealloc

- (instancetype)initWithPhoto:(GPPhoto *)photo
{
    GPLogIN();
    self = [super init];
    
    if (self)
    {
        // Custom initialization
        
        if (photo)
        {
            self.automaticallyAdjustsScrollViewInsets = NO;
            self.photo = photo;
        }
        else
        {
            self = nil;
        }
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

- (void)viewDidLoad
{
    GPLogIN();
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = GPCOLOR_DARK_BLACK;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    GPPhotoViewTopToolbar *topToolbar = [[GPPhotoViewTopToolbar alloc] init];
    topToolbar.delegate = self;
    [self.view addSubview:topToolbar];
    self.topToolbar = topToolbar;
    
    GPPhotoViewBottomToolbar *bottomToolbar = [[GPPhotoViewBottomToolbar alloc] init];
    bottomToolbar.delegate = self;
    [self.view addSubview:bottomToolbar];
    self.bottomToolbar = bottomToolbar;
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tapGr];
    
    GPLogOUT();
}

- (void)viewWillAppear:(BOOL)animated
{
    GPLogIN();
    [super viewWillAppear:animated];
    
    [self.photoView setImage:[self.photo largeImage]];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    GPLogOUT();
}

- (void)viewDidDisappear:(BOOL)animated
{
    GPLogIN();
    [super viewDidDisappear:animated];
    
    [self.photoView setImage:nil];
    
    GPLogOUT();
}

#pragma mark - User Interface

- (UIScrollView *)photoScrollView
{
    if (!_photoScrollView)
    {
        UIScrollView *photoScrollView = [[UIScrollView alloc] init];
        photoScrollView.backgroundColor = GPCOLOR_DARK_BLACK;
        photoScrollView.showsHorizontalScrollIndicator = NO;
        photoScrollView.showsVerticalScrollIndicator = NO;
        photoScrollView.minimumZoomScale = 1;
        photoScrollView.maximumZoomScale = 1;
        [self.view addSubview:photoScrollView];
        _photoScrollView = photoScrollView;
    }
    
    return _photoScrollView;
}

- (UIImageView *)photoView
{
    if (!_photoView)
    {
        UIImageView *photoView = [[UIImageView alloc] init];
        photoView.contentMode = UIViewContentModeScaleAspectFit;
        photoView.backgroundColor = GPCOLOR_DARK_BLACK;
        [self.photoScrollView addSubview:photoView];
        _photoView = photoView;
    }
    
    return _photoView;
}

- (void)updateUI
{
    GPLogIN();
    [super updateUI];
    
    self.photoScrollView.frame = self.view.bounds;
    [self.photoScrollView setNeedsDisplay];
    
    self.photoView.frame = self.photoScrollView.bounds;
    [self.photoView setNeedsDisplay];
    
    self.topToolbar.frame = CGRectMake(0, 0, self.view.bounds.size.width, ToolbarHeight());
    [self.view bringSubviewToFront:self.topToolbar];
    [self.topToolbar updateUI];
    
    self.bottomToolbar.frame = CGRectMake(0, self.view.bounds.size.height - ToolbarHeight(),
                                          self.view.bounds.size.width, ToolbarHeight());
    
    [self.view bringSubviewToFront:self.bottomToolbar];
    [self.bottomToolbar updateUI];
    
    [self.view setNeedsDisplay];
    
    GPLogOUT();
}

- (void)toggleToolbarsVisibilityAnimated:(BOOL)animated
{
    GPLogIN();
    
    static CGFloat _alpha = 0;
    CGFloat alpha = _alpha;
    
    if (animated)
    {
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState |
                                         UIViewAnimationOptionCurveEaseInOut;
        
        [UIView animateWithDuration:0.2
                              delay:0
                            options:options
                         animations:^{
                             
                             self.topToolbar.alpha = alpha;
                             self.bottomToolbar.alpha = alpha;
                             
                         } completion:nil];
    }
    else
    {
        [UIView performWithoutAnimation:^{
            
            self.topToolbar.alpha = alpha;
            self.bottomToolbar.alpha = alpha;
        }];
    }
    
    _alpha = 1 - alpha;
    
    GPLogOUT();
}

#pragma mark - Gestures Handling

- (void)handleTap:(UITapGestureRecognizer *)tapGr
{
    GPLogIN();
    
    [self toggleToolbarsVisibilityAnimated:YES];
    
    GPLogOUT();
}

#pragma mark - Interface Orientation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    GPLogIN();
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    GPLogOUT();
}

#pragma mark - Status Bar

- (BOOL)prefersStatusBarHidden
{
    return GPInterfaceOrientationIsLandscape();
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

#pragma mark - Toolbar Delegate

- (void)toolbar:(id)toolbar didSelectButton:(UIButton *)button
{
    button.enabled = NO;
    
    if (toolbar == self.topToolbar)
    {
        if (button == self.topToolbar.cameraButton)
        {
            GPCameraViewController *cameraViewController = [[GPCameraViewController alloc] init];
            cameraViewController.transitioningDelegate = self;
            
            [self presentViewController:cameraViewController animated:YES completion:^{
                button.enabled = YES;
            }];
        }
        else if (button == self.topToolbar.photosButton)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else // bottom toolbar
    {
        if (button == self.bottomToolbar.searchButton)
        {
            [[GPSearchEngine searchEngine] searchGoogleForPhoto:self.photo completion:nil];
        }
        else if (button == self.bottomToolbar.cancelButton)
        {
            [[GPSearchEngine searchEngine] cancelPhotoSearching];
        }
    }
}

#pragma mark - Transitioning Delegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presentedController
                                                                   presentingController:(UIViewController *)presentingController
                                                                       sourceController:(UIViewController *)source
{
    GPLogIN();
    
    GPBaseTransition *transition = nil;
    
    if ([presentedController isKindOfClass:[GPCameraViewController class]])
    {
        transition = [[GPFadeTransition alloc] init];
    }
    
    GPLogOUT();
    return transition;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissedController
{
    GPLogIN();
    
    GPBaseTransition *transition = nil;
    
    if ([dismissedController isKindOfClass:[GPCameraViewController class]])
    {
        GPCameraViewController *cameraViewController = (GPCameraViewController *)dismissedController;
        
        if ([cameraViewController capturedImage])
        {
            transition = [[GPCameraToPhotoTransition alloc] init];
        }
        else
        {
            transition = [[GPFadeTransition alloc] init];
        }
    }
    
    transition.reverse = YES;
    
    GPLogOUT();
    return transition;
}

#pragma mark - Activity View

- (CGRect)preferredActivityViewFrame
{
    return CGRectMake(0, self.topToolbar.frame.size.height,
                      self.view.bounds.size.width,
                      self.view.bounds.size.height - self.topToolbar.frame.size.height - self.bottomToolbar.frame.size.height);
}

#pragma mark - Search Engine Delegate

- (void)searchEngine:(GPSearchEngine *)searchEngine willBeginSearchingForPhoto:(GPPhoto *)photo
{
    GPLogIN();
    
    [self showActivity:GPActivityProcessingImage animated:YES];
    
    [UIView hideView:self.bottomToolbar.searchButton
       andRevealView:self.bottomToolbar.cancelButton animated:YES];
    
    GPLogOUT();
}

- (void)searchEngine:(GPSearchEngine *)searchEngine didBeginSearchingForPhoto:(GPPhoto *)photo
{
    GPLogIN();
    GPLog(@"Photo: %@", photo);
    
    self.bottomToolbar.cancelButton.enabled = YES;
    
    GPLogOUT();
}

- (void)searchEngine:(GPSearchEngine *)searchEngine willBeginSearchingForImageAt:(NSURL *)link
{
    GPLogIN();
    GPLog(@"link: %@", link);
    
    // No implementation needed
    
    GPLogOUT();
}

- (void)searchEngine:(GPSearchEngine *)searchEngine searchingCompletedWithError:(NSError *)error
{
    GPLogIN();
    
    [self hideActivityAnimated:YES];
    
    if (error)
    {
        GPLogErr(@"%@ %@", error, [error userInfo]);
        
        NSString *title = @"Error";
        NSString *message = @"An error has occurred, please try again.";
        
        BOOL showError = YES;
        
        switch (error.code)
        {
            case GPErrorNoInternetConnection:
            {
                title = @"No internet connection";
                message = @"The Internet connection appears to be offline.";
            }
                break;
            
            // Do NOT show any error message to the user
            case GPErrorImageUploadCancelled:
            default:
            {
                showError = NO;
            }
                break;
        }
        
        if (showError)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: title
                                                                message: message
                                                               delegate: nil
                                                      cancelButtonTitle: @"OK"
                                                      otherButtonTitles: nil];
            [self showAlert:alertView];
        }
    }
    
    self.bottomToolbar.searchButton.enabled = YES;
    
    [UIView hideView:self.bottomToolbar.cancelButton
       andRevealView:self.bottomToolbar.searchButton animated:YES];
    
    GPLogOUT();
}

- (void)searchEngineDidCancelSearching:(GPSearchEngine *)searchEngine
{
    GPLogIN();
    
    // No implementation needed
    
    GPLogOUT();
}

@end
