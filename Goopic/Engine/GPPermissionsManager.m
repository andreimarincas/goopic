//
//  GPPermissionsManager.m
//  Goopic
//
//  Created by andrei.marincas on 14/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "GPPermissionsManager.h"
#import "GPAssetsManager.h"

@implementation GPPermissionsManager

@synthesize canAccessAssetsLibrary = _canAccessAssetsLibrary;

+ (GPPermissionsManager *)sharedManager
{
    static dispatch_once_t once = 0;
    static GPPermissionsManager *_sharedManager = nil;
    
    dispatch_once(&once, ^{
        _sharedManager = [[GPPermissionsManager alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init
{
    GPLogIN();
    self = [super init];
    
    if (self)
    {
        self.canAccessAssetsLibrary = YES;
        self.canAccessCamera = YES;
    }
    
    return self;
    GPLogOUT();
}

// TODO: Use [ALAssetsLibrary authorizationStatus]
- (void)setCanAccessAssetsLibrary:(BOOL)canAccessAssetsLibrary
{
    if (_canAccessAssetsLibrary != canAccessAssetsLibrary)
    {
        _canAccessAssetsLibrary = canAccessAssetsLibrary;
    }
}

- (void)requestAccessToAssetsLibrary:(PermissionBlock)completion
{
    ALAssetsLibrary *library = [[GPAssetsManager sharedManager] assetsLibrary];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL granted = YES;
            GPLog(@"granted: %@", NSStringFromBOOL(granted));
            
            self.canAccessAssetsLibrary = granted;
            
            if (completion)
            {
                completion(granted);
            }
        });
        
    } failureBlock:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL granted = YES;
            
            if ((error.code == ALAssetsLibraryAccessUserDeniedError) /*|| (error.code == ALAssetsLibraryAccessGloballyDeniedError)*/)
            {
                granted = NO;
            }
            
            GPLog(@"granted: %@", NSStringFromBOOL(granted));
            
            self.canAccessAssetsLibrary = granted;
            
            if (completion)
            {
                completion(granted);
            }
        });
    }];
}

- (void)setCanAccessCamera:(BOOL)canAccessCamera
{
    if (_canAccessCamera != canAccessCamera)
    {
        _canAccessCamera = canAccessCamera;
    }
}

// Note: In iOS7 an app can access either camera without requesting the user's permission
// TODO: However, as of iOS 8, apps do need to request access to the cameras.
- (void)requestAccessToCamera:(PermissionBlock)completion
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted) {
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     
                                     GPLog(@"granted: %@", NSStringFromBOOL(granted));
                                     self.canAccessCamera = granted;
                                     
                                     if (completion)
                                     {
                                         completion(granted);
                                     }
                                 });
                             }];
}

@end
