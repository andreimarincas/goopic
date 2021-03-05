//
//  GPPhotoViewController.h
//  Goopic
//
//  Created by andrei.marincas on 27/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPPhoto.h"
#import "GPPhotoViewToolbar.h"
#import "GPBaseViewController.h"
#import "GPSearchEngine.h"

@interface GPPhotoViewController : GPBaseViewController <UIScrollViewDelegate,
                                                         UIViewControllerTransitioningDelegate,
                                                         GPPhotoViewToolbarDelegate,
                                                         GPSearchEngineDelegate>

@property (nonatomic, strong) GPPhotoViewTopToolbar *topToolbar;
@property (nonatomic, strong) GPPhotoViewBottomToolbar *bottomToolbar;

@property (nonatomic, readonly) BOOL toolbarsAreHidden;

@property (nonatomic, strong) GPPhoto *photo;

@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) UIScrollView *photoScrollView;

- (instancetype)initWithPhoto:(GPPhoto *)photo;

- (void)updateUI;

@end
