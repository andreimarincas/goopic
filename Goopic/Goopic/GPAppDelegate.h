//
//  GPAppDelegate.h
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImgurSession.h"

@interface GPAppDelegate : UIResponder <UIApplicationDelegate, IMGSessionDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IMGSession *imgurSession;

@end
