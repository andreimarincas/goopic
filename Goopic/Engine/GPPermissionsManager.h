//
//  GPPermissionsManager.h
//  Goopic
//
//  Created by andrei.marincas on 14/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPPermissionsManager : NSObject
{
    BOOL _canAccessAssetsLibrary;
    BOOL _canAccessCamera;
}

@property (nonatomic, readonly) BOOL canAccessAssetsLibrary;
@property (nonatomic, readonly) BOOL canAccessCamera;

+ (GPPermissionsManager *)sharedManager;

- (void)requestAccessToAssetsLibrary:(PermissionBlock)completion;

- (void)requestAccessToCamera:(PermissionBlock)completion;

@end
