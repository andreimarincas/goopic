//
//  NSNull+Extension.m
//  Goopic
//
//  Created by andrei.marincas on 19/09/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "NSNull+Extension.h"

@implementation NSNull (Extension)

- (NSUInteger)length { return 0; }

- (NSInteger)integerValue { return 0; };

- (float)floatValue { return 0; };

- (NSString *)description { return @"0(NSNull)"; }

- (NSArray *)componentsSeparatedByString:(NSString *)separator { return @[]; }

- (id)objectForKey:(id)key { return nil; }

- (BOOL)boolValue { return NO; }

@end
