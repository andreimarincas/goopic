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

- (UIImage *)getImage
{
    UIImage *image = nil;
    
    if (self.name)
    {
        image = [UIImage imageNamed:self.name];
    }
    else if (self.asset)
    {
        image = [UIImage imageWithCGImage:[self.asset thumbnail]];
    }
    
    return image;
}

@end
