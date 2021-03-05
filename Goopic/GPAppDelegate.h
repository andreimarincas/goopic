//
//  GPAppDelegate.h
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImgurSession.h"
#import "GPRootViewController.h"

@interface GPAppDelegate : UIResponder <UIApplicationDelegate, IMGSessionDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) IMGSession *imgurSession;
@property (nonatomic, strong) GPRootViewController *rootViewController;

@end
