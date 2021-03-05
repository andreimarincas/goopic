//
//  GPPersistentStoreManager.h
//  Goopic
//
//  Created by andrei.marincas on 28/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPStorePhoto.h"

@interface GPPersistentStoreManager : NSObject
{
    NSTimer *_contextSaveTimer;
}

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

+ (GPPersistentStoreManager *)sharedManager;

// data : dictionary with values for all properties
- (void)addPhotoWithData:(id)data;

- (GPStorePhoto *)photoWithAssetURL:(NSString *)url name:(NSString *)name
                              width:(NSInteger)width height:(NSInteger)height;

- (void)purgeStore;

@end
