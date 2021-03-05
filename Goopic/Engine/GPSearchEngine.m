//
//  GPSearchEngine.m
//  Goopic
//
//  Created by andrei.marincas on 30/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "GPSearchEngine.h"
#import "GPImgurManager.h"
#import "OpenInChromeController.h"
#import "GPPersistentStoreManager.h"
#import "GPAppDelegate.h"

@implementation GPSearchEngine

+ (GPSearchEngine *)searchEngine
{
    static dispatch_once_t once = 0;
    static GPSearchEngine *engine = nil;
    
    dispatch_once(&once, ^{
        engine = [[GPSearchEngine alloc] init];
    });
    
    return engine;
}

- (void)searchGoogleForPhoto:(GPPhoto *)photo completion:(CompletionBlock)completion
{
    GPLogIN();
    
    GPPersistentStoreManager *persistentStoreManager = [GPPersistentStoreManager sharedManager];
    
    GPStorePhoto *storePhoto = [persistentStoreManager photoWithAssetURL:photo.url name:photo.name
                                                                   width:photo.width height:photo.height];
    
    if (storePhoto)
    {
        GPLog(@"Photo found in database, no need to upload again: %@", [storePhoto description]);
        GPLog(@"Store photo link: %@", storePhoto.link);
        GPLog(@"Store photo delete hash: %@", storePhoto.deleteHash);
        
        [self.delegate searchEngine:self willBeginSearchingForImageAt:[NSURL URLWithString:storePhoto.link]];
        
        NSString *searchURL =  SEARCH_BY_IMAGE_URL(storePhoto.link);
        GPLog(@"Search URL: %@", searchURL);
        
        NSError *openBrowserError = nil;
        [self openURLInBrowser:[NSURL URLWithString:searchURL] error:&openBrowserError];
        
        if (completion)
        {
            completion(openBrowserError);
        }
        
        [self.delegate searchEngine:self searchingCompletedWithError:openBrowserError];
        
        GPLogOUT();
        return;
    }
    
    [self.delegate searchEngine:self willBeginSearchingForPhoto:photo];
    
    UIImage *image = [photo imageToUpload];
    NSString *imageName = [photo name];
    
    if (!image)
    {
        GPLogErr(@"Cannot upload image, image is nil.");
        
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:GPErrorBadImage
                                         userInfo:@{ NSLocalizedDescriptionKey : @"Cannot upload image." }];
        
        if (completion)
        {
            completion(error);
        }
        
        [self.delegate searchEngine:self searchingCompletedWithError:error];
        
        GPLogOUT();
        return;
    }
    
    if ([imageName length] == 0)
    {
        imageName = kPhotoDefaultNameForUpload;
    }
    
    GPImgurManager *imgurManager = [GPImgurManager sharedManager];
    
    [imgurManager uploadImage:image
                     withName:imageName
                   completion:^(NSString *link, NSString *deleteHash, NSError *error) {
                       
                       if (!error)
                       {
                           GPLog(@"Link: %@", link);
                           GPLog(@"Delete hash: %@", deleteHash);
                           
                           // Save photo in database
                           if (([photo.url length] > 0) && ([deleteHash length] > 0))
                           {
                               id photoData = @{ kStoreEntityPhotosKeyAssetURL    : photo.url,
                                                 kStoreEntityPhotosKeyAssetName   : imageName,
                                                 kStoreEntityPhotosKeyAssetWidth  : @(photo.width),
                                                 kStoreEntityPhotosKeyAssetHeight : @(photo.height),
                                                 kStoreEntityPhotosKeyLink        : link,
                                                 kStoreEntityPhotosKeyUploadDate  : [NSDate now],
                                                 kStoreEntityPhotosKeyDeleteHash  : deleteHash };
                               
                               [persistentStoreManager addPhotoWithData:photoData];
                           }
                           else
                           {
                               GPLogWarn(@"Could not save photo in database. url: %@, delete hash: %@", photo.url, deleteHash);
                           }
                           
                           [self.delegate searchEngine:self willBeginSearchingForImageAt:[NSURL URLWithString:link]];
                           
                           // Open browser to search for image
                           NSString *searchURL =  SEARCH_BY_IMAGE_URL(link);
                           GPLog(@"Search URL: %@", searchURL);
                           
                           NSError *openBrowserError = nil;
                           [self openURLInBrowser:[NSURL URLWithString:searchURL] error:&openBrowserError];
                           
                           if (completion)
                           {
                               completion(openBrowserError);
                           }
                           
                           [self.delegate searchEngine:self searchingCompletedWithError:openBrowserError];
                       }
                       else // failed / cancelled
                       {
                           GPLogErr(@"%@ %@", error, [error userInfo]);
                           
                           if (completion)
                           {
                               completion(error);
                           }
                           
                           [self.delegate searchEngine:self searchingCompletedWithError:error];
                           
                           if (error.code == GPErrorImageUploadCancelled)
                           {
                               [self.delegate searchEngineDidCancelSearching:self];
                           }
                       }
                   }];
    
    [self.delegate searchEngine:self didBeginSearchingForPhoto:photo];
    
    GPLogOUT();
}

- (void)openURLInBrowser:(NSURL *)url error:(NSError **)error
{
    GPLogIN();
    
    GPAppDelegate *appDelegate = (GPAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (![appDelegate.imgurSession.imgurReachability isReachable])
    {
        GPLogErr(@"Network not reachable.");
        
        *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:GPErrorNoInternetConnection
                                 userInfo:@{ NSLocalizedDescriptionKey : @"No internet connection." }];
        
        GPLogOUT();
        return;
    }
    
    // Try to open in Chrome first
    OpenInChromeController *chromeCtrl = [OpenInChromeController sharedInstance];
    
    if ([chromeCtrl isChromeInstalled])
    {
        NSURL *callbackURL = [NSURL URLWithString:GOOPIC_URL_SCHEME];
        
        BOOL success = [[OpenInChromeController sharedInstance] openInChrome:url
                                                             withCallbackURL:callbackURL
                                                                createNewTab:YES];
        if (success)
        {
            GPLog(@"Opened URL in Chrome: %@", url);
            
            GPLogOUT();
            return;
        }
        
        GPLog(@"Failed to open URL in Chrome: %@", url); // Fails if app in background
    }
    
    // Open in default browser (safari)
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
        
        GPLog(@"Opened URL in default browser (Safari): %@", url);
        
        GPLogOUT();
        return;
    }
    
    GPLog(@"Cannot open URL: %@", url);
    
    *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:GPErrorCannotLaunchBrowser
                             userInfo:@{ NSLocalizedDescriptionKey : @"Cannot launch browser for searching." }];
}

- (void)cancelPhotoSearching
{
    GPLogIN();
    
    [[GPImgurManager sharedManager] cancelImageUpload];
    
    GPLogOUT();
}

@end
