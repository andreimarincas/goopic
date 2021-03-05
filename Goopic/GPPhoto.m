//
//  GPPhoto.m
//  Goopic
//
//  Created by andrei.marincas on 25/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "GPPhoto.h"

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
//    UIImage *image = nil;
//    
//    if (self.name)
//    {
//        image = [UIImage imageNamed:self.name];
//    }
//    else if (self.asset)
//    {
//        image = [UIImage imageWithCGImage:[self.asset thumbnail]];
//    }
//    
//    return image;
    
    if (self.asset)
    {
        return [UIImage imageWithCGImage:[self.asset thumbnail]];
    }
    
    return nil;
}

- (UIImage *)fullResolutionImage
{
    if (self.asset)
    {
        ALAssetRepresentation *defaultRep = [self.asset defaultRepresentation];
        GPLog(@"asset orientation: %ld", [defaultRep orientation]);
        
        UIImage *image = [UIImage imageWithCGImage:[defaultRep fullResolutionImage]
                                             scale:[defaultRep scale]
                                       orientation:(UIImageOrientation)[defaultRep orientation]];
        
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
        GPLog(@"asset orientation: %ld", [defaultRep orientation]);
        
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

@end
