//
//  TMS_Debug.m
//  Dialog
//
//  Created by Dan Park on 8/16/12.
//  Copyright (c) 2012 MagicPoint.US All rights reserved.
//

#import "MGDebug.h"
#import "mach/mach.h"

@implementation MGDebug

+ (void)inspectURLResponse:(NSURLResponse*)response
{
	if ([response isKindOfClass:[NSHTTPURLResponse self]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        DEBUG_LOG(@"[httpResponse statusCode]:%ld", (long)[httpResponse statusCode]);
    }
    
	long long contentLength = [response expectedContentLength];
    DEBUG_LOG(@"contentLength:%qi", contentLength);
    DEBUG_LOG(@"[response MIMEType]:%@", [response MIMEType]);
    DEBUG_LOG(@"[response suggestedFilename]:%@", [response suggestedFilename]);
    DEBUG_LOG(@"[response textEncodingName]:%@", [response textEncodingName]);
    NSLog(@"absoluteURL:%@", response.URL.absoluteString);
    NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
    DEBUG_LOG(@"allHeaderFields:%@", headers);
}

+ (void)traceMemoryUsage:(NSString*)logPrefix, ...NS_REQUIRES_NIL_TERMINATION
{
#define EnableMemoryUsageTrace
#ifdef EnableMemoryUsageTrace
    
    va_list arguments;
    va_start(arguments, logPrefix);
    
    NSString *composite = [[NSString alloc] initWithFormat:logPrefix arguments:arguments];
//    DEBUG_LOG(@"composite:%@", composite);
    va_end(arguments);
    
    
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        float_t memoryInMB = info.resident_size / 1024.0 / 1024.0;
        NSLog(@"%@: ram: %4.2f MB", composite, memoryInMB);
    } else {
        NSLog(@"%@: ram: %s", composite, mach_error_string(kerr));
    }
#endif
}

+ (void)traceMemoryUsage
{
    [self.class traceMemoryUsage:@"ECO", nil];
}
@end