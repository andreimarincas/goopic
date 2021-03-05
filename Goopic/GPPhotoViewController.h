//
//  GPPhotoViewController.h
//  Goopic
//
//  Created by andrei.marincas on 27/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPPhoto.h"

@class GPRootViewController;

@interface GPPhotoViewController : UIViewController <UIScrollViewDelegate>
{
    GPToolbar *_topToolbar;
    GPToolbar *_bottomToolbar;
}

@property (nonatomic, weak) GPRootViewController *rootViewController;

@property (nonatomic, strong) GPPhoto *photo;

@property (nonatomic, strong) UIImageView *photoView;
@property (nonatomic, strong) UIScrollView *photoScrollView;

- (instancetype)init;

- (void)updateUI;

@end
