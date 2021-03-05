//
//  GPLogs.h
//  Goopic
//
//  Created by andrei.marincas on 24/08/14.
//  Copyright (c) 2014 JUPITER. All rights reserved.
//

#if (LOGS_ENABLED)

    #define GPLogIN()             NSLog(@"%@ IN",          [NSString stringWithCString:__FUNCTION__ encoding:NSUTF8StringEncoding])
    #define GPLogOUT()            NSLog(@"%@ OUT",         [NSString stringWithCString:__FUNCTION__ encoding:NSUTF8StringEncoding])
    #define GPLog(format,...)     NSLog(@"%@ %@",          [NSString stringWithCString:__FUNCTION__ encoding:NSUTF8StringEncoding], [NSString stringWithFormat:(format), ##__VA_ARGS__])
    #define GPLogWarn(format,...) NSLog(@"WARNING: %@ %@", [NSString stringWithCString:__FUNCTION__ encoding:NSUTF8StringEncoding], [NSString stringWithFormat:(format), ##__VA_ARGS__])
    #define GPLogErr(format,...)  NSLog(@"ERROR: %@ %@",   [NSString stringWithCString:__FUNCTION__ encoding:NSUTF8StringEncoding], [NSString stringWithFormat:(format), ##__VA_ARGS__])

    #define GPLogv(format, args)  NSLogv(format, args)

    #define GPLogRet(value, s)    NSLog( [NSString stringWithFormat:@"%%@ OUT %@", s], [NSString stringWithCString:__FUNCTION__ encoding:NSUTF8StringEncoding], value); return value

#else

    #define GPLogIN()
    #define GpLogOUT()
    #define GPLog(format,...)
    #define GPLogWarn(format,...)
    #define GPLogErr(format,...)
    #define GPLogv(format,args)
    #define GPLogRet(value, s) return value

#endif

void redirectLogsToFile(NSString *fileName);
