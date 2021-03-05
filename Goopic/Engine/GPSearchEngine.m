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

- (void)searchGoogleForPhoto:(GPPhoto *)photo
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
        
        NSString *searchURL =  SEARCH_BY_IMAGE_URL(storePhoto.link);
        GPLog(@"Search URL: %@", searchURL);
        
        [self openURLInBrowser:[NSURL URLWithString:searchURL]];
        
        GPLogOUT();
        return;
    }
    
    UIImage *image = [photo imageToUpload];
    NSString *imageName = [photo name];
    
    if (!image)
    {
        GPLogErr(@"Cannot upload image, image is nil.");
        
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
                           
                           // Open photo in browser for searching
                           NSString *searchURL =  SEARCH_BY_IMAGE_URL(link);
                           GPLog(@"Search URL: %@", searchURL);
                           
                           [self openURLInBrowser:[NSURL URLWithString:searchURL]];
                       }
                       else
                       {
                           GPLogErr(@"%@ %@", error, [error userInfo]);
                       }
                   }];
    
    GPLogOUT();
}

- (void)openURLInBrowser:(NSURL *)url
{
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
            return;
        }
        
        GPLog(@"Failed to open URL in Chrome: %@", url); // Fails if app in background
    }
    
    // Open in Safari (default browser)
    
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        GPLog(@"Cannot open URL: %@", url);
    }
}

@end
