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

- (instancetype)init
{
    GPLogIN();
    self = [super init];
    
    if (self)
    {
        [self addObserver];
    }
    
    return self;
    GPLogOUT();
}

- (void)dealloc
{
    GPLogIN();
    
    [self removeObserver];
    
    GPLogOUT();
}

- (ALAssetsLibrary *)assetsLibrary
{
    if (!_assetsLibrary)
    {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    return _assetsLibrary;
}

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(assetsLibraryChanged:)
                                                 name: ALAssetsLibraryChangedNotification
                                               object: self.assetsLibrary];
}

- (void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: ALAssetsLibraryChangedNotification
                                                  object: nil];
}

- (void)assetsLibraryChanged:(NSNotification *)notification
{
    GPLogIN();
    GPLog(@"notification: %@", notification);
    
    NSSet *groups = notification.userInfo[ALAssetLibraryUpdatedAssetGroupsKey];
    
    for (NSURL *groupURL in groups)
    {
        [_assetsLibrary groupForURL:groupURL
                        resultBlock:^(ALAssetsGroup *group) {
                            
                            if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos)
                            {
                                GPAppDelegate *appDelegate = (GPAppDelegate *)[[UIApplication sharedApplication] delegate];
                                GPPhotosTableViewController *photosTableViewController = (GPPhotosTableViewController *)[appDelegate rootViewController];
                                
                                [photosTableViewController reloadPhotosFromLibrary];
                            }
                            
                        } failureBlock:nil];
    }
    
    GPLogOUT();
}

@end
