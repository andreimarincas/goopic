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

- (NSDate *)dateTaken
{
    if (self.asset)
    {
        return [self.asset valueForProperty:ALAssetPropertyDate];
    }
    
    return nil;
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
