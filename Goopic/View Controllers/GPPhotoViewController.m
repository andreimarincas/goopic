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
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleAppDidEnterBackground:)
                                                         name:UIApplicationDidEnterBackgroundNotification
                                                       object:nil];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
    
    [self setNeedsStatusBarAppearanceUpdate];
    
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
        photoView.image = [self.photo largeImage];
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
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateUI];
    [self setNeedsStatusBarAppearanceUpdate];
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
    return UIStatusBarAnimationSlide;
}

#pragma mark - Toolbar Delegate

- (void)toolbar:(id)toolbar didSelectButton:(UIButton *)button
{
    if (button == self.topToolbar.cameraButton)
    {
        GPCameraViewController *cameraViewController = [[GPCameraViewController alloc] init];
        cameraViewController.transitioningDelegate = self;
        
        button.enabled = NO;
        
        [self presentViewController:cameraViewController animated:YES completion:^{
            button.enabled = YES;
        }];
    }
    else if (button == self.topToolbar.photosButton || button == self.topToolbar.disclosureButton)
    {
        button.enabled = NO;
        
        [self dismissViewControllerAnimated:YES completion:^{
            button.enabled = YES;
        }];
    }
    else if (button == self.bottomToolbar.searchButton)
    {
        button.enabled = NO;
        
        [[GPSearchEngine searchEngine] searchGoogleForPhoto:self.photo completion:^(NSError *error) {
            
//            button.enabled = YES;
            
            // TODO: Handle erorr ?
        }];
    }
}

#pragma mark - Transitioning Delegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presentedController
                                                                   presentingController:(UIViewController *)presentingController
                                                                       sourceController:(UIViewController *)source
{
    GPLogIN();
    
    GPFadeTransition *transition = [[GPFadeTransition alloc] init];
    
    GPLogOUT();
    return transition;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissedController
{
    GPLogIN();
    
    GPFadeTransition *transition = [[GPFadeTransition alloc] init];
    transition.reverse = YES;
    
    GPLogOUT();
    return transition;
}

#pragma mark - Notifications

- (void)handleAppDidEnterBackground:(NSNotification *)notification
{
    self.bottomToolbar.searchButton.enabled = YES;
}

@end
