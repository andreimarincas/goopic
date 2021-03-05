//
//  GPRootViewController.m
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPRootViewController.h"
#import "GPAppDelegate.h"

@implementation GPRootViewController

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
    
    GPToolbar *topToolbar = [[GPToolbar alloc] initWithStyle:GPPositionTop];
//    topToolbar.backgroundColor = [COLOR_BLACK colorWithAlphaComponent:0.9];
//    topToolbar.backgroundColor = [GP_COLOR_BLUE colorWithAlphaComponent:0.8];
//    topToolbar.line.lineColor = GP_COLOR_DARK_BLUE;
    
//    topToolbar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
//    topToolbar.backgroundColor = [UIColor colorWithWhite:0.05 alpha:0.5];
    topToolbar.backgroundColor = [COLOR_BLACK colorWithAlphaComponent:0.65];
    topToolbar.line.lineColor = COLOR_BLACK;
    
//    [topToolbar addButtonWithType:GPToolbarButtonCamera toLeftOrRight:GPPositionRight];
//    topToolbar.title = @"Photos";
    [self.view addSubview:topToolbar];
    self.topToolbar = topToolbar;
    
    [topToolbar hideLeftTitle:NO];
    
    GPPhotosTableViewController *photosCtrl = [[GPPhotosTableViewController alloc] init];
    photosCtrl.rootViewController = self;
    [photosCtrl willMoveToParentViewController:self];
    [self addChildViewController:photosCtrl];
    [self.view insertSubview:photosCtrl.view belowSubview:self.topToolbar];
    self.photosTableViewController = photosCtrl;
    
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
    
    [self.view bringSubviewToFront:self.topToolbar];
    self.topToolbar.frame = CGRectMake(0, 0, self.view.bounds.size.width, [GPToolbar preferredHeight]);
    [self.topToolbar updateUI];
    
    self.photosTableViewController.view.frame = self.view.bounds;
    [self.photosTableViewController updateUI];
    
    [self.view setNeedsDisplay];
    
    GPLogOUT();
}

@end
