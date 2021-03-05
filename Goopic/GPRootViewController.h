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

@interface GPRootViewController : UIViewController

@property (nonatomic, strong) GPToolbar *topToolbar;

@property (nonatomic, strong) GPPhotosTableViewController *photosTableViewController;

+ (instancetype)rootViewController;

- (void)updateUI;

@end
