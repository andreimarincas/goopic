//
//  GPRootViewController.h
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPToolbar.h"
#import "GPPhotosTableViewController.h"
#import "GPPhotoViewController.h"
#import "GPPhoto.h"

@interface GPRootViewController : UIViewController <GPToolbarDelegate>

@property (nonatomic, strong) GPToolbar *topToolbar;
@property (nonatomic, strong) GPToolbar *bottomToolbar;

@property (nonatomic, strong) GPPhotosTableViewController *photosTableViewController;
@property (nonatomic, strong) GPPhotoViewController *photoViewController;

@property (nonatomic, strong) UIViewController *topViewController;

+ (instancetype)rootViewController;

- (void)updateUI;

- (void)presentPhotoViewControllerWithPhoto:(GPPhoto *)photo;
- (void)dismissPhotoViewController;

@end
