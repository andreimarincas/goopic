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
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:flags fromDate:self];
    
    return [calendar dateFromComponents:components];
}

- (NSString *)formattedDateForTitle
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSString *formattedDateString = [dateFormatter stringFromDate:self];
    return formattedDateString;
}

@end
