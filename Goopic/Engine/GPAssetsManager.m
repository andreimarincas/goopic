//
//  GPAssetsManager.m
//  Goopic
//
//  Created by andrei.marincas on 25/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "GPAssetsManager.h"

@implementation GPAssetsManager

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t once = 0;
    static ALAssetsLibrary *library = nil;
    
    dispatch_once(&once, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    
    return library;
}

@end
