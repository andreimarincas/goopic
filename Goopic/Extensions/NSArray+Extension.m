//
//  NSArray+Extension.m
//  Goopic
//
//  Created by andrei.marincas on 03/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "NSArray+Extension.h"
#import "GPPhoto.h"

@implementation NSArray (Extension)

- (id)middleObject
{
    if ([self count] > 0)
    {
        return self[[self count] / 2];
    }
    
    return nil;
}

- (BOOL)containsViewWithTag:(NSInteger)tag
{
    for (id obj in self)
    {
        if ([obj isKindOfClass:[UIView class]] && ([obj tag] == tag))
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isEqualToArrayOfPhotos:(NSArray *)array
{
    if (array)
    {
        if ([self count] == [array count])
        {
            for (int i = 0; i < [self count]; i++)
            {
                if (![(GPPhoto *)self[i] isEqualToPhoto:(GPPhoto *)array[i]])
                {
                    return NO;
                }
            }
            
            return YES;
        }
    }
    
    return NO;
}

@end
