//
//  Phonebook.m
//  Ping Me
//
//  Created by lab on 11/22/12.
//  Copyright (c) 2012 magicpoint.us. All rights reserved.
//

#import "Phonebook.h"
#import "PlistManager.h"

NSString *const kMyDeviceToken =          @"myDeviceToken";
NSString *const kMyPhoneNumber =          @"myPhoneNumber";


@interface Phonebook ()
{
}
@property (nonatomic, retain) NSMutableDictionary *calledPhoneNumbers;
@property (nonatomic, retain) PlistManager *devicePlist;
@property (nonatomic, retain) PlistManager *calledNumbersPlist;
@end

@implementation Phonebook
@synthesize calledPhoneNumbers;
@synthesize currentDialedNumber;
@synthesize myPhoneNumber, myDeviceToken;
@synthesize devicePlist, calledNumbersPlist;

+ (instancetype)sharedInstance
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
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setPhoneNumber:(NSString*)phoneNumber withDeviceToken:(NSString*)deviceToken
{
    DEBUG_LOG(@"phoneNumber:%@, deviceToken:%@", phoneNumber, deviceToken);
    
    if (! calledPhoneNumbers) {
        NSMutableDictionary *newSet = [NSMutableDictionary dictionaryWithCapacity:20];
        [self setCalledPhoneNumbers:newSet];
    }
    [calledPhoneNumbers setValue:deviceToken forKey:phoneNumber];
}

- (BOOL)existsPhoneNumber:(NSString*)phoneNumber
{
    if (! calledPhoneNumbers) {
        NSMutableDictionary *newSet = [NSMutableDictionary dictionaryWithCapacity:20];
        [self setCalledPhoneNumbers:newSet];
    }
    id value = [calledPhoneNumbers valueForKey:phoneNumber];
    DEBUG_LOG(@"object:%@", value);
    return value != nil;
}

- (void)saveCalledPhoneNumbers
{
    if (! calledNumbersPlist) {
        PlistManager *plist = [PlistManager new];
        [self setCalledNumbersPlist:plist];
    }
    
    NSArray *array = [NSArray arrayWithObject:calledPhoneNumbers];
    DEBUG_LOG(@"array:%@", [array description]);
    [calledNumbersPlist savePlist:array withFilename:@"numbers.plist"];
}

- (void)loadCalledPhoneNumbers
{
    if (! calledNumbersPlist) {
        PlistManager *plist = [PlistManager new];
        [self setCalledNumbersPlist:plist];
    }
    
    NSArray *array = [calledNumbersPlist loadPlist:@"numbers.plist"];
    DEBUG_LOG(@"array:%@", [array description]);
    NSDictionary *dictionary = (NSDictionary*) [array lastObject];
    if (dictionary) {
        [self setCalledPhoneNumbers:[dictionary mutableCopy]];
    }
}


- (void)saveMyNumberAndToken
{
    if (! devicePlist) {
        PlistManager *plist = [PlistManager new];
        [self setDevicePlist:plist];
    }
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                myDeviceToken, kMyDeviceToken,
                                myPhoneNumber, kMyPhoneNumber,
                                nil];
    NSArray *array = [NSArray arrayWithObject:dictionary];
    DEBUG_LOG(@"array:%@", [array description]);
    
    
    [devicePlist savePlist:array withFilename:@"device.plist"];
}


- (void)loadMyNumberAndToken
{
    if (! devicePlist) {
        PlistManager *plist = [PlistManager new];
        [self setDevicePlist:plist];
    }
    
    NSArray *array = [devicePlist loadPlist:@"device.plist"];
    NSDictionary *dictionary = (NSDictionary*) [array lastObject];
    if (dictionary) {
        id deviceToken = [dictionary valueForKey:kMyDeviceToken];
        DEBUG_LOG(@"deviceToken:[%@]", [deviceToken description]);
        [self setMyDeviceToken:deviceToken];
        
        id phoneNumber = [dictionary valueForKey:kMyPhoneNumber];
        DEBUG_LOG(@"phoneNumber:[%@]", [phoneNumber description]);
        [self setMyPhoneNumber:phoneNumber];
    }
}


- (NSString*)generateKnownScope
{
    NSString *scope = @"st";
    if (currentDialedNumber) {
        NSUInteger scopeLenth = 4;
        NSRange range = {[currentDialedNumber length] - scopeLenth, scopeLenth};
        scope = [currentDialedNumber substringWithRange:range];
    }
    return scope;
}

- (NSString*)generateUnknownScope
{
    NSString *scope = @"st";
    if (myPhoneNumber) {
        NSUInteger scopeLenth = 4;
        NSRange range = {[myPhoneNumber length] - scopeLenth, scopeLenth};
        scope = [myPhoneNumber substringWithRange:range];
    }
    return scope;
}


- (unsigned char)generateKnownVariant
{
    unsigned char varient = 0x32;//0x0F, 0x32(50)
    if (currentDialedNumber) {
        int sigma = 0;
        for (NSUInteger index = 0; index < [currentDialedNumber length]; index++) {
            NSRange range = {index, 1};
            NSString *letter = [currentDialedNumber substringWithRange:range];
            int number = [letter intValue];
            sigma += number;
        }
        varient = sigma;
    }
    return varient;
}


- (unsigned char)generateUnknownVariant
{
    unsigned char varient = 0x32;//0x0F, 0x32(50)
    if (myPhoneNumber) {
        int sigma = 0;
        for (NSUInteger index = 0; index < [myPhoneNumber length]; index++) {
            NSRange range = {index, 1};
            NSString *letter = [myPhoneNumber substringWithRange:range];
            int number = [letter intValue];
            sigma += number;
        }
        varient = sigma;
    }
    return varient;
}

@end
