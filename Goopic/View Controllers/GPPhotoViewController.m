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
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateUI];
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

- (void)toggleToolbarsVisibility
{
    GPLogIN();
    
    BOOL toolbarsAreVisible = (self.topToolbar.alpha > 0);
    
    if (!toolbarsAreVisible)
    {
        self.topToolbar.hidden = NO;
        self.bottomToolbar.hidden = NO;
    }
    
    UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut;
    
    [UIView animateWithDuration:0.25
                          delay:0
                        options:options
                     animations:^{
                         
                         self.topToolbar.alpha = toolbarsAreVisible ? 0 : 1;
                         self.bottomToolbar.alpha = toolbarsAreVisible ? 0 : 1;
                         
                     } completion:^(BOOL finished) {
                         
                         if (toolbarsAreVisible)
                         {
                             self.topToolbar.hidden = YES;
                             self.bottomToolbar.hidden = YES;
                         }
                     }];
    
    GPLogOUT();
}

#pragma mark - Gestures Handling

- (void)handleTap:(UITapGestureRecognizer *)tapGr
{
    GPLogIN();
    
    [self toggleToolbarsVisibility];
    
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

#pragma mark - Toolbar Delegate

- (void)toolbar:(id)toolbar didSelectButton:(UIButton *)button
{
    if (button == self.topToolbar.cameraButton)
    {
        GPCameraViewController *cameraViewController = [[GPCameraViewController alloc] init];
        [self presentViewController:cameraViewController animated:NO completion:nil];
    }
    else if (button == self.topToolbar.photosButton || button == self.topToolbar.disclosureButton)
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else if (button == self.bottomToolbar.searchButton)
    {
        [[GPSearchEngine searchEngine] searchGoogleForPhoto:self.photo];
    }
}

@end
