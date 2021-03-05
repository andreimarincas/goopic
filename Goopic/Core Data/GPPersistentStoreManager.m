//
//  GPPersistentStoreManager.m
//  Goopic
//
//  Created by andrei.marincas on 28/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPPersistentStoreManager.h"
#import "GPAppDelegate.h"
#import "GPImgurManager.h"


static const NSTimeInterval kSaveContextDelay = 5.0f;


@interface GPPersistentStoreManager ()

@property (atomic) NSTimer *contextSaveTimer;
@property (atomic) BOOL purgingInProgress;

@end


@implementation GPPersistentStoreManager

+ (GPPersistentStoreManager *)sharedManager
{
    static dispatch_once_t once = 0;
    static GPPersistentStoreManager *_storeManager = nil;
    
    dispatch_once(&once, ^{
        _storeManager = [[GPPersistentStoreManager alloc] init];
    });
    
    return _storeManager;
}

- (NSManagedObjectContext *)managedObjectContext
{
    GPAppDelegate *appDelegate = (GPAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate managedObjectContext];
}

- (void)addPhotoWithData:(id)data
{
    GPLogIN();
    GPLog(@"photo data: %@", [data description]);
    
    GPStorePhoto *photo = [NSEntityDescription insertNewObjectForEntityForName:kStoreEntityPhotos
                                                        inManagedObjectContext:self.managedObjectContext];
    
    photo.assetURL    = data[kStoreEntityPhotosKeyAssetURL];
    photo.assetName   = data[kStoreEntityPhotosKeyAssetName];
    photo.assetWidth  = data[kStoreEntityPhotosKeyAssetWidth];
    photo.assetHeight = data[kStoreEntityPhotosKeyAssetHeight];
    photo.link        = data[kStoreEntityPhotosKeyLink];
    photo.uploadDate  = data[kStoreEntityPhotosKeyUploadDate];
    photo.deleteHash  = data[kStoreEntityPhotosKeyDeleteHash];
    
    if (![self saveContext])
    {
        GPLogErr(@"Could not save photo, see previous logs.");
    }
    
    GPLogOUT();
}

- (GPStorePhoto *)photoWithAssetURL:(NSString *)url name:(NSString *)name
                              width:(NSInteger)width height:(NSInteger)height
{
    GPLogIN();
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:kStoreEntityPhotos
                                                  inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *predURL    = [NSPredicate predicateWithFormat:@"(%K = %@)", kStoreEntityPhotosKeyAssetURL, url];
    NSPredicate *predName   = [NSPredicate predicateWithFormat:@"(%K = %@)", kStoreEntityPhotosKeyAssetName, name];
    NSPredicate *predWidth  = [NSPredicate predicateWithFormat:@"(%K == %d)", kStoreEntityPhotosKeyAssetWidth, width];
    NSPredicate *predHeight = [NSPredicate predicateWithFormat:@"(%K == %d)", kStoreEntityPhotosKeyAssetHeight, height];
    
    NSPredicate *pred = [NSCompoundPredicate andPredicateWithSubpredicates:@[ predURL, predName, predWidth, predHeight ]];
    [request setPredicate:pred];
    
    GPLog(@"Search for photo predicate: %@", pred);
    
    NSError *error = nil;
    NSArray *photos = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!error)
    {
        if ([photos count] > 0)
        {
            GPLog(@"Fetched photos: %@", [photos description]);
            
            GPLogOUT();
            return (GPStorePhoto *)[photos firstObject];
        }
        else
        {
            GPLog(@"Photo not found in store: %@", pred);
        }
    }
    else
    {
        GPLogErr(@"%@, %@", error, [error userInfo]);
    }
    
    GPLogOUT();
    return nil;
}

- (void)purgeStore
{
    GPLogIN();
    
    if (!self.purgingInProgress)
    {
        self.purgingInProgress = YES;
        [self performSelectorInBackground:@selector(doPurgeStore:) withObject:self.managedObjectContext];
    }
    else
    {
        GPLog(@"Cannot purge store, purging already in progress.");
    }
    
    GPLogOUT();
}

- (void)doPurgeStore:(NSManagedObjectContext *)managedObjectContext
{
    GPLogIN();
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:kStoreEntityPhotos
                                                  inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSDate *expirationDate = [[NSDate now] dateByAddingTimeInterval:-kPhotoLocalExpirationInterval];
    GPLog(@"current date: %@", [[NSDate now] dateStringLongStyle]);
    GPLog(@"expiration date: %@", [expirationDate dateStringLongStyle]);
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(%K <= %@)", kStoreEntityPhotosKeyUploadDate, expirationDate];
    [request setPredicate:pred];
    
    GPLog(@"Search photos to purge: %@", pred);
    
    NSError *error = nil;
    NSArray *photos = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!error)
    {
        GPLog(@"Photos to purge: %@", photos);
        
        if ([photos count] > 0)
        {
            NSDate *imgurExpirationDate = [[NSDate now] dateByAddingTimeInterval:-kPhotoImgurExpirationInterval];
            BOOL delayedPurge = NO;
            BOOL needsContextSave = NO;
            
            for (GPStorePhoto *photo in photos)
            {
                if ([photo.uploadDate laterDate:imgurExpirationDate])
                {
                    // Try to delete the photo from Imgur and delete from database only if remote deletion succeeded
                    [[GPImgurManager sharedManager] deleteImageWithHash:photo.deleteHash completion:^(NSError *error) {
                        
                        if (!error || (error.code == GPErrorIMGImageNotFound))
                        {
                            [managedObjectContext deleteObject:photo];
                            [self setNeedsContextSave];
                        }
                    }];
                    
                    delayedPurge = YES;
                }
                else // The photo is ancient
                {
                    // Try to delete the photo from Imgur one last time and delete from database whatever the response
                    [[GPImgurManager sharedManager] deleteImageWithHash:photo.deleteHash completion:nil];
                    [managedObjectContext deleteObject:photo];
                    
                    needsContextSave = YES;
                }
            }
            
            if (delayedPurge)
            {
                GPLog(@"Purge completion might be delayed because of networking.");
            }
            
            if (needsContextSave)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([self saveContext])
                    {
                        if (!delayedPurge)
                        {
                            GPLog(@"Purge complete.");
                        }
                        else
                        {
                            GPLogErr(@"Purge incomplete, see previous logs.");
                        }
                    }
                });
            }
        }
        else
        {
            GPLog(@"No photos to purge.");
        }
    }
    else
    {
        GPLogErr(@"%@, %@", error, [error userInfo]);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.purgingInProgress = NO;
    });
    
    GPLogOUT();
}

- (BOOL)saveContext
{
    GPLogIN();
    
    [self.contextSaveTimer invalidate];
    self.contextSaveTimer = nil;
    
    if (!self.managedObjectContext)
    {
        GPLogErr(@"Context is nil.");
        
        GPLogOUT();
        return NO;
    }
    
    if ([self.managedObjectContext hasChanges])
    {
        NSError *error = nil;
        BOOL ok = [self.managedObjectContext save:&error];
        
        if (!ok || error)
        {
            if (!ok)
            {
                GPLogErr(@"Failed to save context.");
            }
            
            if (error)
            {
                GPLogErr(@"%@ %@", error, [error userInfo]);
            }
            
            // TODO: Handle context saving failure. abort()?
            
            GPLogOUT();
            return NO;
        }
        else
        {
            GPLog(@"Context saved successfully.");
        }
    }
    else
    {
        GPLog(@"No changes in the context.");
        
        GPLogOUT();
        return NO;
    }
    
    return YES;
    GPLogOUT();
}

- (void)setNeedsContextSave
{
    GPLogIN();
    
    [self.contextSaveTimer invalidate];
    self.contextSaveTimer = [NSTimer scheduledTimerWithTimeInterval:kSaveContextDelay target:self
                                                           selector:@selector(saveContext) userInfo:nil repeats:NO];
    
    GPLogOUT();
}

@end
