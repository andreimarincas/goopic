//
//  NSDate+Extension.h
//  Goopic
//
//  Created by andrei.marincas on 26/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extension)

+ (NSDate *)now;

- (NSDate *)dateWithYearMonthAndDayOnly;

- (NSString *)dateStringForTitleFormat;
- (NSString *)dateStringLongStyle;

- (BOOL)earlierThan:(NSDate *)date;
- (BOOL)laterThan:(NSDate *)date;

@end
