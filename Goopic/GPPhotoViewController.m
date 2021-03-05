//
//  GPPhotoViewController.m
//  Goopic
//
//  Created by andrei.marincas on 27/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPPhotoViewController.h"
#import "GPRootViewController.h"

@implementation GPPhotoViewController

@synthesize photoView = _photoView;
@synthesize photoScrollView = _photoScrollView;

@synthesize rootViewController = _rootViewController;

- (instancetype)init
{
    GPLogIN();
    self = [super init];
    
    if (self)
    {
        // Custom initialization
        
        if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
            self.automaticallyAdjustsScrollViewInsets = NO;
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

- (void)viewDidLoad
{
    GPLogIN();
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = COLOR_DARK_BLACK;
    
    GPLogOUT();
}

- (UIScrollView *)photoScrollView
{
    if (!_photoScrollView)
    {
        UIScrollView *photoScrollView = [[UIScrollView alloc] init];
        photoScrollView.backgroundColor = COLOR_DARK_BLACK;
        photoScrollView.showsHorizontalScrollIndicator = NO;
        photoScrollView.showsVerticalScrollIndicator = NO;
        photoScrollView.minimumZoomScale = 1;
        photoScrollView.maximumZoomScale = 2;
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
        photoView.backgroundColor = COLOR_DARK_BLACK;
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
    
    [self.view setNeedsDisplay];
    
    GPLogOUT();
}

- (void)setPhoto:(GPPhoto *)photo
{
    GPLogIN();
    
    _photo = photo;
    
    self.photoView.image = photo.fullResolutionImage;
    [self updateUI];
    
    GPLogOUT();
}

- (GPToolbar *)topToolbar
{
    if (!_topToolbar)
    {
        GPToolbar *toolbar = [[GPToolbar alloc] initWithStyle:GPPositionTop];
        [toolbar setBackButtonType:GPToolbarButtonBackToPhotos];
        _topToolbar = toolbar;
    }
    
    return _topToolbar;
}

- (GPToolbar *)bottomToolbar
{
    if (!_bottomToolbar)
    {
        GPToolbar *toolbar = [[GPToolbar alloc] initWithStyle:GPPositionBottom];
        [toolbar setMiddleButtonType:GPToolbarButtonSearchGoogleForThisImage];
        _bottomToolbar = toolbar;
    }
    
    return _bottomToolbar;
}

#pragma mark - Scroll View Delegate

@end
