//
//  NSArray+Extension.m
//  Goopic
//
//  Created by andrei.marincas on 03/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "NSArray+Extension.h"

@implementation NSArray (Extension)

- (id)middleObject
{
    if ([self count] > 0)
    {
        return [self objectAtIndex:[self count] / 2];
    }
    
    return nil;
}

@end
