//
//  NSDate+Extension.m
//  Goopic
//
//  Created by andrei.marincas on 26/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

+ (NSDate *)now
{
    return [NSDate date];
}

- (NSDate *)dateWithYearMonthAndDayOnly
{
    unsigned int flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:flags fromDate:self];
    
    return [calendar dateFromComponents:components];
}

- (NSString *)dateStringForTitleFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:self];
    return formattedDateString;
}

- (NSString *)dateStringLongStyle
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:self];
    return formattedDateString;
}

- (BOOL)earlierThan:(NSDate *)date
{
    return ([self compare:date] == NSOrderedAscending);
}

- (BOOL)laterThan:(NSDate *)date
{
    return ([self compare:date] == NSOrderedDescending);
}

@end
