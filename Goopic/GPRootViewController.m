//
//  GPRootViewController.m
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPRootViewController.h"
#import "GPAppDelegate.h"
#import "GPImgurManager.h"
#import "OpenInChromeController.h"
#import "GPPersistentStoreManager.h"

@implementation GPRootViewController

@synthesize topToolbar = _topToolbar;
@synthesize bottomToolbar = _bottomToolbar;

@synthesize topViewController = _topViewController;

+ (instancetype)rootViewController
{
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)viewDidLoad
{
    GPLogIN();
    [super viewDidLoad];
    
    self.view.backgroundColor = COLOR_BLACK;
    
    GPPhotosTableViewController *photosTableViewController = [[GPPhotosTableViewController alloc] init];
    self.topViewController = photosTableViewController;
    self.photosTableViewController = photosTableViewController;
    
    GPLogOUT();
}

- (void)viewWillAppear:(BOOL)animated
{
    GPLogIN();
    [super viewWillAppear:animated];
    
    [self updateUI];
    
    GPLogOUT();
}

- (void)viewWillLayoutSubviews
{
    GPLogIN();
    [super viewWillLayoutSubviews];
    
    [self updateUI];
    
    GPLogOUT();
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    GPLogIN();
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (![self.photosTableViewController isTopViewController])
    {
        [self.photosTableViewController setNeedsReload];
    }
    
    GPLogOUT();
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    GPLogIN();
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self updateUI];
    
    GPLogOUT();
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    return YES;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods
{
    return YES;
}

- (void)updateUI
{
    GPLogIN();
    
    GPLog(@"root bounds: %@", NSStringFromCGRect(self.view.bounds));
    GPLog(@"root frame: %@", NSStringFromCGRect(self.view.frame));
    
    self.topViewController.view.frame = self.view.bounds;
    [self.topViewController updateUI];
    
    if (self.topToolbar)
    {
        self.topToolbar.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.topToolbar.preferredHeight);
        [self.topToolbar updateUI];
        [self.view bringSubviewToFront:self.topToolbar];
    }
    
    if (self.bottomToolbar)
    {
        self.bottomToolbar.frame = CGRectMake(0, self.view.bounds.size.height - self.bottomToolbar.preferredHeight,
                                              self.view.bounds.size.width, self.bottomToolbar.preferredHeight);
        [self.bottomToolbar updateUI];
        [self.view bringSubviewToFront:self.bottomToolbar];
    }
    
    [self.view setNeedsDisplay];
    
    GPLogOUT();
}

- (void)setTopToolbar:(GPToolbar *)toolbar
{
    if (toolbar != _topToolbar)
    {
        _topToolbar.delegate = nil;
        [_topToolbar removeFromSuperview];
        
        if (toolbar)
        {
            toolbar.delegate = self;
            [self.view addSubview:toolbar];
        }
        
        _topToolbar = toolbar;
    }
}

- (void)setBottomToolbar:(GPToolbar *)toolbar
{
    if (toolbar != _bottomToolbar)
    {
        _bottomToolbar.delegate = nil;
        [_bottomToolbar removeFromSuperview];
        
        if (toolbar)
        {
            toolbar.delegate = self;
            [self.view addSubview:toolbar];
        }
        
        _bottomToolbar = toolbar;
    }
}

- (void)setTopViewController:(UIViewController *)viewController
{
    if (viewController != _topViewController)
    {
        if (_topViewController)
        {
            [_topViewController.view removeFromSuperview];
            [_topViewController removeFromParentViewController];
            
            self.topToolbar = nil;
            self.bottomToolbar = nil;
        }
        
        _topViewController = viewController;
        
        if (viewController)
        {
            viewController.rootViewController = self;
            [viewController willMoveToParentViewController:self];
            [self addChildViewController:viewController];
            [self.view addSubview:viewController.view];
            
            self.topToolbar = viewController.topToolbar;
            self.bottomToolbar = viewController.bottomToolbar;
        }
        
        [self updateUI];
    }
}

- (void)presentPhotoViewControllerWithPhoto:(GPPhoto *)photo
{
    GPLogIN();
    
    if ([self.photoViewController isTopViewController])
    {
        GPLogErr(@"Cannot present photo view controller, already presented.");
        
        GPLogOUT();
        return;
    }
    
    self.view.userInteractionEnabled = NO;
    
    GPPhotoViewController *photoViewController = [[GPPhotoViewController alloc] init];
    photoViewController.photo = photo;
    self.photoViewController = photoViewController;
    
    self.topViewController = self.photoViewController;
    
    self.view.userInteractionEnabled = YES;
    
    GPLogOUT();
}

- (void)dismissPhotoViewController
{
    GPLogIN();
    
    if (![self.photoViewController isTopViewController])
    {
        GPLogErr(@"Photo view controller cannot be dismissed because it's nil.");
        
        GPLogOUT();
        return;
    }
    
    self.view.userInteractionEnabled = NO;
    
    self.photoViewController = nil;
    self.topViewController = self.photosTableViewController;
    
    self.view.userInteractionEnabled = YES;
    
    GPLogOUT();
}

- (void)searchGoogleForPhoto:(GPPhoto *)photo
{
    GPLogIN();
    
    GPPersistentStoreManager *persistentStoreManager = [GPPersistentStoreManager sharedManager];
    
    GPStorePhoto *storePhoto = [persistentStoreManager photoWithAssetURL:photo.url name:photo.name
                                                                   width:photo.width height:photo.height];
    
    if (storePhoto)
    {
        GPLog(@"Photo found in database, no need to upload again: %@", [storePhoto description]);
        GPLog(@"Store photo link: %@", storePhoto.link);
        GPLog(@"Store photo delete hash: %@", storePhoto.deleteHash);
        
        NSString *searchURL =  SEARCH_BY_IMAGE_URL(storePhoto.link);
        GPLog(@"Search URL: %@", searchURL);
        
        [self openURLInBrowser:[NSURL URLWithString:searchURL]];
        
        GPLogOUT();
        return;
    }
    
    UIImage *image = [photo imageToUpload];
    NSString *imageName = [photo name];
    
    if (!image)
    {
        GPLogErr(@"Cannot upload image, image is nil.");
        
        GPLogOUT();
        return;
    }
    
    if ([imageName length] == 0)
    {
        imageName = kPhotoDefaultNameForUpload;
    }
    
    GPImgurManager *imgurManager = [GPImgurManager sharedManager];
    
    [imgurManager uploadImage:image
                     withName:imageName
                   completion:^(NSString *link, NSString *deleteHash, NSError *error) {
                       
                       if (!error)
                       {
                           GPLog(@"Link: %@", link);
                           GPLog(@"Delete hash: %@", deleteHash);
                           
                           // Save photo in database
                           if (([photo.url length] > 0) && ([deleteHash length] > 0))
                           {
                               id photoData = @{ kStoreEntityPhotosKeyAssetURL    : photo.url,
                                                 kStoreEntityPhotosKeyAssetName   : imageName,
                                                 kStoreEntityPhotosKeyAssetWidth  : @(photo.width),
                                                 kStoreEntityPhotosKeyAssetHeight : @(photo.height),
                                                 kStoreEntityPhotosKeyLink        : link,
                                                 kStoreEntityPhotosKeyUploadDate  : [NSDate now],
                                                 kStoreEntityPhotosKeyDeleteHash  : deleteHash };
                               
                               [persistentStoreManager addPhotoWithData:photoData];
                           }
                           else
                           {
                               GPLogWarn(@"Could not save photo in database. url: %@, delete hash: %@", photo.url, deleteHash);
                           }
                           
                           // Open photo in browser for searching
                           NSString *searchURL =  SEARCH_BY_IMAGE_URL(link);
                           GPLog(@"Search URL: %@", searchURL);
                           
                           [self openURLInBrowser:[NSURL URLWithString:searchURL]];
                       }
                       else
                       {
                           GPLogErr(@"%@ %@", error, [error userInfo]);
                       }
                   }];
    
    GPLogOUT();
}

- (void)openURLInBrowser:(NSURL *)url
{
    // Try to open in Chrome first
    
    OpenInChromeController *chromeCtrl = [OpenInChromeController sharedInstance];
    
    if ([chromeCtrl isChromeInstalled])
    {
        NSURL *callbackURL = [NSURL URLWithString:GOOPIC_URL_SCHEME];
        
        BOOL success = [[OpenInChromeController sharedInstance] openInChrome:url
                                                             withCallbackURL:callbackURL
                                                                createNewTab:YES];
        if (success)
        {
            GPLog(@"Opened URL in Chrome: %@", url);
            return;
        }
        
        GPLog(@"Failed to open URL in Chrome: %@", url); // Fails if app in background
    }
    
    // Open in Safari (default browser)
    
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        GPLog(@"Cannot open URL: %@", url);
    }
}

#pragma mark - Toolbal Delegate

- (void)toolbar:(GPToolbar *)toolbar didSelectButtonWithType:(GPToolbarButtonType)type
{
    GPLogIN();
    GPLog(@"type: %@", NSStringFromGPToolbarButtonType(type));
    
    switch (type)
    {
        case GPToolbarButtonSearchGoogleForThisImage:
            [self searchGoogleForPhoto:self.photoViewController.photo];
            break;
            
        case GPToolbarButtonBackToPhotos:
            self.topViewController = self.photosTableViewController;
            break;
            
        default:
            break;
    }
    
    GPLogOUT();
}

- (void)toolbar:(GPToolbar *)toolbar didTapTitle:(UILabel *)titleLabel
{
    GPLogIN();
    GPLog(@"%@", titleLabel);
    
    if ((toolbar == self.topToolbar) && (titleLabel == self.topToolbar.titleLabel))
    {
        [self.photosTableViewController.photosTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                              atScrollPosition:UITableViewScrollPositionTop
                                                                      animated:YES];
    }
    
    GPLogOUT();
}

@end
