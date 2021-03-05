//
//  GPAppDelegate.h
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImgurSession.h"
#import "GPBaseViewController.h"

@interface GPAppDelegate : UIResponder <UIApplicationDelegate, IMGSessionDelegate>
{
    GPBaseViewController *_rootViewController;
}

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) IMGSession *imgurSession;
@property (nonatomic, readonly) GPBaseViewController *rootViewController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
