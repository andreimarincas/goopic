//
//  GPAppDelegate.m
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPAppDelegate.h"
#import "GPPersistentStoreManager.h"
#import "GPPhotosTableViewController.h"
#import "GPCameraViewController.h"
#import "GPPhotoViewController.h"
#import "GPPermissionsManager.h"

@implementation GPAppDelegate

@synthesize rootViewController = _rootViewController;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Application Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[GPPermissionsManager sharedManager] requestAccessToAssetsLibrary:nil];
    [[GPPermissionsManager sharedManager] requestAccessToCamera:nil];
    
    NSDictionary *appDefaults = @{ kCameraFlashKey         : kCameraFlashAutoValue,
                                   kBrowserForSearchingKey : kBrowserForSearchingChrome,
                                   kOpenInNewTabKey        : @(YES) };
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    IMGSession *imgSession = [IMGSession anonymousSessionWithClientID:IMGUR_CLIENT_ID withDelegate:self];
    [imgSession.imgurReachability startMonitoring];
    self.imgurSession = imgSession;
    
    self.window.rootViewController = self.rootViewController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // Purge photos store
    [[GPPersistentStoreManager sharedManager] purgeStore];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    GPLogIN();
    
    GPLog(@"openURL: %@", url);
    
    GPLogOUT();
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // Forward method
    [self.rootViewController appWillResignActive];
    
    __block UIBackgroundTaskIdentifier backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
        
        [self.imgurSession.operationQueue cancelAllOperations];
        [application endBackgroundTask:backgroundTaskIdentifier];
    }];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // Forward method
    [self.rootViewController appDidEnterBackground];
    
    // Saves changes in the application's managed object context before the user quits the application.
    [[GPPersistentStoreManager sharedManager] saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    GPLogIN();
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // Forward method
    [self.rootViewController appWillEnterForeground];
    
    // Purge photos store
    [[GPPersistentStoreManager sharedManager] purgeStore];
    
    GPLogOUT();
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Forward method
    [self.rootViewController appDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    GPLogIN();
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // Saves changes in the application's managed object context before the application terminates.
    [[GPPersistentStoreManager sharedManager] saveContext];
    
    // Stop monitoring network reachability
    [self.imgurSession.imgurReachability stopMonitoring];
    
    GPLogOUT();
}

- (GPBaseViewController *)rootViewController
{
    if (!_rootViewController)
    {
        GPPhotosTableViewController *photosTableViewController = [[GPPhotosTableViewController alloc] init];
        _rootViewController = photosTableViewController;
    }
    
    return _rootViewController;
}

- (void)dismissCameraViewController:(GPCameraViewController *)cameraViewController withPhoto:(GPPhoto *)photo
{
    GPLogIN();
    
    GPPhotosTableViewController *photosTableViewController = (GPPhotosTableViewController *)[self rootViewController];
    
    if ([[cameraViewController presentingViewController] isKindOfClass:[GPPhotoViewController class]])
    {
        GPPhotoViewController *photoViewController = (GPPhotoViewController *)[cameraViewController presentingViewController];
        [photoViewController setPhoto:photo];
        [cameraViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else if ([cameraViewController presentingViewController] == photosTableViewController)
    {
        self.cameraViewController = cameraViewController;
        
        UIView *snapshot = [cameraViewController.view snapshotViewAfterScreenUpdates:NO];
        [self.window addSubview:snapshot];
        self.cameraViewSnapshot = snapshot;
        
        [cameraViewController dismissViewControllerAnimated:NO completion:^{
            
            GPPhotoViewController *photoViewController = [[GPPhotoViewController alloc] initWithPhoto:photo];
            photoViewController.transitioningDelegate = photosTableViewController;
            photosTableViewController.interactiveTransition.photoViewController = photoViewController;
            
            [[GPSearchEngine searchEngine] setDelegate:photoViewController];
            
            [photosTableViewController presentViewController:photoViewController animated:YES completion:^{
                
                photosTableViewController.interactiveTransition.viewForInteraction = photoViewController.view;
                
                [self.cameraViewSnapshot removeFromSuperview];
                self.cameraViewSnapshot = nil;
                
                self.cameraViewController = nil;
            }];
        }];
    }
    
    GPLogOUT();
}

- (BOOL)isPresentingPhotoViewControllerFromCameraViewController
{
    return (self.cameraViewController != nil);
}

#pragma mark - Core Data

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kGoopicModel withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kGoopicStore];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        GPLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            GPLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
