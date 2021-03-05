//
//  GPPhoto.m
//  Goopic
//
//  Created by andrei.marincas on 25/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "GPPhoto.h"
#import "GPAssetsManager.h"

@implementation GPPhoto

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        // Initialization code
    }
    
    return self;
}

- (void)dealloc
{
    // Dealloc code
}

- (NSString *)description
{
    return [self.asset description];
}

- (UIImage *)thumbnailImage
{
    if (self.asset)
    {
        return [UIImage imageWithCGImage:[self.asset thumbnail]];
    }
    
    return nil;
}

- (UIImage *)largeImage
{
    if (self.asset)
    {
        ALAssetRepresentation *defaultRep = [self.asset defaultRepresentation];
        GPLog(@"asset orientation: %ld", (long int)[defaultRep orientation]);
        GPLog(@"[defaultRep scale]: %f", [defaultRep scale]);
        
        UIImage *image = nil;
        
        if (iOS_8_or_higher())
        {
            image = [UIImage imageWithCGImage: [defaultRep fullResolutionImage]
                                        scale: [defaultRep scale]
                                  orientation: (UIImageOrientation)[defaultRep orientation]];
        }
        else // iOS 7.1
        {
            image = [UIImage imageWithCGImage: [defaultRep fullScreenImage]
                                        scale: [defaultRep scale]
                                  orientation: UIImageOrientationUp];
        }
        
        GPLog(@"full resolution image size: %@", NSStringFromCGSize(image.size));
        
        return image;
    }
    
    return nil;
}

- (UIImage *)imageToUpload
{
    if (self.asset)
    {
        ALAssetRepresentation *defaultRep = [self.asset defaultRepresentation];
        GPLog(@"asset orientation: %ld", (long int)[defaultRep orientation]);
        
        UIImage *image = [UIImage imageWithCGImage:[defaultRep fullScreenImage]
                                             scale:[defaultRep scale]
                                       orientation:UIImageOrientationUp];
        
        GPLog(@"screen image size: %@", NSStringFromCGSize(image.size));
        
        CGFloat scale = ScaleFactorForUploadingImageWithSize(image.size);
        GPLog(@"scale factor: %f", scale);
        
        UIImage *scaledImage = [UIImage imageWithImage:image scale:scale];
        GPLog(@"scaled image size: %@", NSStringFromCGSize(scaledImage.size));
        
        return scaledImage;
    }
    
    return nil;
}

- (NSDate *)dateTaken
{
    if (self.asset)
    {
        return [self.asset valueForProperty:ALAssetPropertyDate];
    }
    
    return nil;
}

- (NSString *)url
{
    if (self.asset)
    {
        return [[self.asset valueForProperty:ALAssetPropertyAssetURL] absoluteString];
    }
    
    return @"";
}

- (NSString *)name
{
    if (self.asset)
    {
        NSString *fileName = [[self.asset defaultRepresentation] filename];
        NSString *photoName = [[fileName stringByDeletingPathExtension] lastPathComponent];
        GPLog(@"photo name: %@", photoName);
        
        return photoName;
    }
    
    return @"";
}

- (NSInteger)width
{
    if (self.asset)
    {
        CGSize photoSize = [[self.asset defaultRepresentation] dimensions];
        return (int)photoSize.width;
    }
    
    return 0;
}

- (NSInteger)height
{
    if (self.asset)
    {
        CGSize photoSize = [[self.asset defaultRepresentation] dimensions];
        return (int)photoSize.height;
    }
    
    return 0;
}

- (NSComparisonResult)compare:(id)photo
{
    if ([photo isKindOfClass:[GPPhoto class]])
    {
        NSDate *selfDateTaken = self.dateTaken;
        NSDate *photoDateTaken = [photo dateTaken];
        
        if (selfDateTaken && photoDateTaken)
        {
            NSComparisonResult dateCompare = [selfDateTaken compare:photoDateTaken];
            
            if (dateCompare == NSOrderedAscending)
            {
                return NSOrderedDescending;
            }
            
            if (dateCompare == NSOrderedDescending)
            {
                return NSOrderedAscending;
            }
        }
        
        return NSOrderedSame;
    }
    
    return NSOrderedAscending; // default
}

- (BOOL)isEqualToPhoto:(GPPhoto *)photo
{
    if (photo)
    {
        NSString *selfURL = [self url];
        NSString *photoURL = [photo url];
        
        if ([selfURL length] > 0 && [photoURL length] > 0)
        {
            return [selfURL isEqualToString:photoURL];
        }
    }
    
    return NO;
}

- (void)checkIfExists:(AssetExistsBlock)completion
{
    ALAssetsLibrary *assetsLibrary = [[GPAssetsManager sharedManager] assetsLibrary];
    
    [assetsLibrary assetForURL:[NSURL URLWithString:[self url]] resultBlock:^(ALAsset *asset) {
        
        if (completion)
        {
            completion(asset != nil);
        }
        
    } failureBlock:^(NSError *error) {
        
        if (completion)
        {
            completion(NO);
        }
    }];
}

@end
