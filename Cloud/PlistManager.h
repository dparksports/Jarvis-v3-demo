//
//  PlistManager.h
//  CallLocations
//
//  Created by lab on 11/6/12.
//  Copyright (c) 2012 magicpoint.us. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGDebug.h"

@interface PlistManager : NSObject {
}

@property (nonatomic, retain) NSMutableArray *items;

+ (id)sharedInstance;
+ (NSString*)formatTimestamp:(NSDate*)date;

- (void)emptyPlist;
- (NSArray*)loadPlist;
- (void)savePlist:(NSArray*)plist;
- (void)savePlist;
- (void)addTimestampedEvent:(NSString*)eventName;

- (void)savePlist:(NSArray*)plist withFilename:(NSString*)filename;
- (NSArray*)loadPlist:(NSString*)filename;

@end
