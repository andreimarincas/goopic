//
//  GPAssetsManager.m
//  Goopic
//
//  Created by andrei.marincas on 25/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "GPAssetsManager.h"
#import "GPAppDelegate.h"
#import "GPPhotosTableViewController.h"

@implementation GPAssetsManager

@synthesize assetsLibrary = _assetsLibrary;

+ (GPAssetsManager *)sharedManager
{
    static dispatch_once_t once = 0;
    static GPAssetsManager *_sharedManager = nil;
    
    dispatch_once(&once, ^{
        _sharedManager = [[GPAssetsManager alloc] init];
    });
    
    return _sharedManager;
}

- (void)dealloc
{
    GPLogIN();
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: ALAssetsLibraryChangedNotification
                                                  object: nil];
    
    GPLogOUT();
}

- (ALAssetsLibrary *)assetsLibrary
{
    if (!_assetsLibrary)
    {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(assetsLibraryChanged:)
                                                     name: ALAssetsLibraryChangedNotification
                                                   object: _assetsLibrary];
    }
    
    return _assetsLibrary;
}

- (void)assetsLibraryChanged:(NSNotification *)notification
{
    GPLogIN();
    GPLog(@"notification: %@", notification);
    
    GPAppDelegate *appDelegate = (GPAppDelegate *)[[UIApplication sharedApplication] delegate];
    GPPhotosTableViewController *photosTableViewController = (GPPhotosTableViewController *)[appDelegate rootViewController];
    
    [photosTableViewController reloadPhotosFromLibrary];
    
    GPLogOUT();
}

@end
