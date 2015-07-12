//
//  TMS_Debug.h
//  Dialog
//
//  Created by Dan Park on 8/16/12.
//  Copyright (c) 2012 MagicPoint.US All rights reserved.
//

#import <Foundation/Foundation.h>

//#define DEBUG
#ifdef DEBUG
#define DEBUG_LOG(...)    NSLog(@"%s[%d] %@", __PRETTY_FUNCTION__,  __LINE__, [NSString stringWithFormat:__VA_ARGS__])
#else
#define DEBUG_LOG(...)
#endif

@interface MGDebug : NSObject

+ (void)inspectURLResponse:(NSURLResponse*)response;
+ (void)traceMemoryUsage;
+ (void)traceMemoryUsage:(NSString*)logPrefix, ... NS_REQUIRES_NIL_TERMINATION;

@end


