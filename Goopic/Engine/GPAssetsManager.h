//
//  GPAssetsManager.h
//  Goopic
//
//  Created by andrei.marincas on 25/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALAssetsLibrary;

@interface GPAssetsManager : NSObject
{
    ALAssetsLibrary *_assetsLibrary;
}

@property (nonatomic, readonly) ALAssetsLibrary *assetsLibrary;

+ (GPAssetsManager *)sharedManager;

- (void)addObserver;
- (void)removeObserver;

@end
