//
//  PlistManager.m
//  CallLocations
//
//  Created by lab on 11/6/12.
//  Copyright (c) 2012 magicpoint.us. All rights reserved.
//

#import "PlistManager.h"

@interface PlistManager () {
}
@end

@implementation PlistManager
@synthesize items;

+ (id)sharedInstance
{
    static id singleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [self.class new];
    });
    
    return singleton;
}

- (id)init
{
    DEBUG_LOG(@"");
    self = [super init];
    if (self) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:100];
        [self setItems:array];
//        [array release];
    }
    return self;
}

- (void)savePlist:(NSArray*)plist withFilename:(NSString*)filename
{
    DEBUG_LOG(@"");
    
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootPath = [directories objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:filename];
    
    NSError *error;
    NSPropertyListWriteOptions options = 0; // there is no option available.
    NSData *plistData = [NSPropertyListSerialization dataWithPropertyList:plist format:NSPropertyListBinaryFormat_v1_0 options:options error:&error];
    if (plistData) {
        BOOL succeeded = [plistData writeToFile:plistPath atomically:YES];
        if (! succeeded) {
            DEBUG_LOG(@"writeToFile error:%@", error);
        } else {
            DEBUG_LOG(@"succeeded:%d", succeeded);
        }
    } else {
        DEBUG_LOG(@"plistData empty: error: %@",error);
    }
}

- (void)savePlist:(NSArray*)plist
{
    NSString *filename = @"saved.plist";
    [self savePlist:plist withFilename:filename];
}

- (void)savePlist
{
    [self savePlist:items];
}

- (NSArray*)loadPlist:(NSString*)filename
{
    DEBUG_LOG(@"");
    
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *rootPath = [directories objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:filename];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        NSError *error;
        NSPropertyListFormat format;
        NSPropertyListReadOptions options = 0; // not in use.
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        NSArray *loadedArray = (NSArray *) [NSPropertyListSerialization propertyListWithData:plistXML options:options format:&format error:&error];
        
        [items removeAllObjects];
        [items addObjectsFromArray:loadedArray];
        return loadedArray;
    }
    return nil;
}

- (NSArray*)loadPlist
{
    NSString *filename = @"saved.plist";
    return [self loadPlist:filename];
}

+ (NSString*)formatTimestamp:(NSDate*)date
{
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterLongStyle];
    }
    
    NSString *timestamp = [formatter stringFromDate:date];
    return timestamp;
}

#define MAX_ITEMS 200
- (void)addEvent:(NSDictionary*)eventInfo
{
    DEBUG_LOG(@"items:%@, eventInfo:%@", items, eventInfo);
    [items insertObject:eventInfo atIndex:0];
    while ([items count] > MAX_ITEMS) {
        [items removeLastObject];
    }
}

- (void)addTimestampedEvent:(NSString*)eventName
{
    DEBUG_LOG(@"eventName:%@", eventName);
    NSDate *date = [NSDate date];
    NSDictionary *eventInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               [self.class formatTimestamp:date], eventName,
                               nil];
    
    [self addEvent:eventInfo];
}

- (void)emptyPlist
{
    DEBUG_LOG(@"");
    [items removeAllObjects];
    [self savePlist:items];
    [self addTimestampedEvent:@"emptyPlist"];
}

@end
